import 'package:flutter/material.dart';

import 'models/table_models.dart';

/// Sticky sortable data table with frozen header row and first column.
class StickySortableDataTable extends StatefulWidget {
  const StickySortableDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.stickyColumnCount = 1,
    this.headerHeight = 48,
    this.rowHeight = 44,
    this.defaultColumnWidth = 140,
    this.initialSort,
    this.onSortChanged,
    this.externallySorted = false,
    this.tablePadding,
    this.gridBorderColor,
    this.showVerticalDividers = true,
    this.showHorizontalDividers = true,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyWidget,
  }) : assert(stickyColumnCount >= 0);

  final List<TableColumnDef> columns;
  final List<TableRowData> rows;
  final int stickyColumnCount;
  final double headerHeight;
  final double rowHeight;
  final double defaultColumnWidth;
  final SortState? initialSort;
  final void Function(SortState sort)? onSortChanged;
  final bool externallySorted;
  final EdgeInsets? tablePadding;
  final Color? gridBorderColor;
  final bool showVerticalDividers;
  final bool showHorizontalDividers;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;

  @override
  State<StickySortableDataTable> createState() => _StickySortableDataTableState();
}

class _StickySortableDataTableState extends State<StickySortableDataTable> {
  late SortState? _sortState = widget.initialSort;
  late List<TableRowData> _visibleRows = _initialRows();

  final ScrollController _verticalScrollableController = ScrollController();
  final ScrollController _verticalStickyController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  bool _syncingVerticalScroll = false;

  int get _stickyCount => widget.stickyColumnCount.clamp(0, widget.columns.length);

  @override
  void initState() {
    super.initState();
    _attachVerticalListeners();
  }

  @override
  void didUpdateWidget(covariant StickySortableDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rows != oldWidget.rows || widget.initialSort != oldWidget.initialSort) {
      _sortState = widget.initialSort ?? _sortState;
      _visibleRows = widget.externallySorted
          ? List<TableRowData>.from(widget.rows)
          : _sortedRows(widget.rows, _sortState);
    }
  }

  List<TableRowData> _initialRows() {
    if (widget.externallySorted) {
      return List<TableRowData>.from(widget.rows);
    }
    return _sortedRows(widget.rows, _sortState);
  }

  void _attachVerticalListeners() {
    _verticalScrollableController.addListener(() {
      if (_syncingVerticalScroll) return;
      _syncingVerticalScroll = true;
      if (_verticalStickyController.hasClients) {
        _verticalStickyController.jumpTo(_verticalScrollableController.offset);
      }
      _syncingVerticalScroll = false;
    });

    _verticalStickyController.addListener(() {
      if (_syncingVerticalScroll) return;
      _syncingVerticalScroll = true;
      if (_verticalScrollableController.hasClients) {
        _verticalScrollableController.jumpTo(_verticalStickyController.offset);
      }
      _syncingVerticalScroll = false;
    });
  }

  List<TableRowData> _sortedRows(List<TableRowData> rows, SortState? sort) {
    if (sort == null) return List<TableRowData>.from(rows);
    final sorted = List<TableRowData>.from(rows);
    sorted.sort((a, b) {
      final cellA = a.cells[sort.columnIndex];
      final cellB = b.cells[sort.columnIndex];
      final comparator = widget.columns[sort.columnIndex].comparator;
      final int result;
      if (comparator != null) {
        result = comparator(cellA, cellB);
      } else {
        result = _compareDynamic(cellA.value ?? cellA.text, cellB.value ?? cellB.text);
      }
      return sort.direction == SortDirection.asc ? result : -result;
    });
    return sorted;
  }

  int _compareDynamic(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) {
      return a.compareTo(b);
    }
    return a.toString().compareTo(b.toString());
  }

  void _onHeaderTap(int columnIndex) {
    final column = widget.columns[columnIndex];
    if (!column.sortable) return;

    SortDirection nextDirection;
    if (_sortState == null || _sortState?.columnIndex != columnIndex) {
      nextDirection = SortDirection.desc;
    } else {
      nextDirection = _sortState!.direction == SortDirection.desc ? SortDirection.asc : SortDirection.desc;
    }

    final nextSort = SortState(columnIndex: columnIndex, direction: nextDirection);
    setState(() {
      _sortState = nextSort;
      if (!widget.externallySorted) {
        _visibleRows = _sortedRows(widget.rows, nextSort);
      }
    });

    widget.onSortChanged?.call(nextSort);
  }

  double _columnWidth(TableColumnDef column) => column.width ?? widget.defaultColumnWidth;

  double _stickyWidth() {
    final stickyColumns = widget.columns.take(_stickyCount);
    return stickyColumns.fold<double>(0, (sum, col) => sum + _columnWidth(col));
  }

  Widget _buildHeaderCell(TableColumnDef column, int index) {
    final isSortedColumn = _sortState?.columnIndex == index;
    final sortIcon = isSortedColumn
        ? Icon(
            _sortState?.direction == SortDirection.desc ? Icons.arrow_downward : Icons.arrow_upward,
            size: 14,
          )
        : null;

    return InkWell(
      onTap: () => _onHeaderTap(index),
      child: Container(
        alignment: _alignmentFor(column.alignment),
        width: _columnWidth(column),
        height: widget.headerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _cellDecoration(isHeader: true),
        child: Row(
          mainAxisAlignment: _mainAxisFor(column.alignment),
          children: [
            Flexible(
              child: Text(
                column.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (sortIcon != null) ...[
              const SizedBox(width: 4),
              sortIcon,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBodyCell(TableCellData cell, TableColumnDef column) {
    final style = cell.style;
    final textStyle = TextStyle(
      color: style?.textColor,
      fontWeight: style?.bold == true ? FontWeight.bold : FontWeight.normal,
      fontStyle: style?.italic == true ? FontStyle.italic : FontStyle.normal,
    );

    return Container(
      alignment: _alignmentFor(style?.textAlign ?? column.alignment),
      width: _columnWidth(column),
      height: widget.rowHeight,
      padding: style?.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: _cellDecoration(background: style?.backgroundColor),
      child: Text(
        cell.text,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
    );
  }

  Alignment _alignmentFor(TextAlign? align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.start:
        return Alignment.centerLeft;
      default:
        return Alignment.centerLeft;
    }
  }

  MainAxisAlignment _mainAxisFor(TextAlign? align) {
    switch (align) {
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.end:
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }

  BoxDecoration _cellDecoration({bool isHeader = false, Color? background}) {
    return BoxDecoration(
      color: background ?? (isHeader ? Colors.grey.shade200 : null),
      border: Border(
        right: widget.showVerticalDividers
            ? BorderSide(color: widget.gridBorderColor ?? Colors.grey.shade300, width: 0.8)
            : BorderSide.none,
        bottom: widget.showHorizontalDividers
            ? BorderSide(color: widget.gridBorderColor ?? Colors.grey.shade300, width: 0.8)
            : BorderSide.none,
      ),
    );
  }

  Widget _buildHeaderRow() {
    final stickyColumns = widget.columns.take(_stickyCount).toList();
    final scrollableColumns = widget.columns.skip(_stickyCount).toList();

    return Row(
      key: const Key('sticky_header_row'),
      children: [
        if (stickyColumns.isNotEmpty)
          SizedBox(
            width: _stickyWidth(),
            child: Row(
              children: [
                for (var i = 0; i < stickyColumns.length; i++) _buildHeaderCell(stickyColumns[i], i),
              ],
            ),
          ),
        if (scrollableColumns.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < scrollableColumns.length; i++)
                    _buildHeaderCell(scrollableColumns[i], i + _stickyCount),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBodyRows() {
    final stickyColumns = widget.columns.take(_stickyCount).toList();
    final scrollableColumns = widget.columns.skip(_stickyCount).toList();

    if (widget.isLoading) {
      return Center(child: widget.loadingWidget ?? const CircularProgressIndicator());
    }

    if (_visibleRows.isEmpty) {
      return Center(child: widget.emptyWidget ?? const Text('No data'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stickyColumns.isNotEmpty)
          SizedBox(
            key: const Key('sticky_column_list'),
            width: _stickyWidth(),
            child: ListView.builder(
              controller: _verticalStickyController,
              itemCount: _visibleRows.length,
              itemBuilder: (context, rowIndex) {
                final row = _visibleRows[rowIndex];
                final cells = row.cells.take(stickyColumns.length).toList();
                return Row(
                  children: [
                    for (var i = 0; i < cells.length; i++) _buildBodyCell(cells[i], stickyColumns[i]),
                  ],
                );
              },
            ),
          ),
        if (scrollableColumns.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: scrollableColumns.fold<double>(0, (sum, col) => sum + _columnWidth(col)),
                child: ListView.builder(
                  key: const Key('scrollable_rows_list'),
                  controller: _verticalScrollableController,
                  itemCount: _visibleRows.length,
                  itemBuilder: (context, rowIndex) {
                    final row = _visibleRows[rowIndex];
                    final cells = row.cells.skip(stickyColumns.length).toList();
                    return Row(
                      children: [
                        for (var i = 0; i < cells.length; i++) _buildBodyCell(cells[i], scrollableColumns[i]),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _verticalScrollableController.dispose();
    _verticalStickyController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.tablePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 4),
          Expanded(child: _buildBodyRows()),
        ],
      ),
    );
  }
}
