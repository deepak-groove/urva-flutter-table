import 'package:flutter/material.dart';

import 'models/table_models.dart';

/// A scrollable table with sticky header and sticky first columns that supports
/// sorting and per-cell styling.
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
  });

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
  late List<TableRowData> _sortedRows;
  SortState? _sortState;

  final ScrollController _verticalScrollableController = ScrollController();
  final ScrollController _verticalStickyController = ScrollController();
  final ScrollController _horizontalScrollableController = ScrollController();
  final ScrollController _horizontalHeaderController = ScrollController();

  bool _isSyncingVertical = false;
  bool _isSyncingHorizontal = false;

  @override
  void initState() {
    super.initState();
    _sortedRows = List<TableRowData>.from(widget.rows);
    _sortState = widget.initialSort;
    if (_sortState != null && !widget.externallySorted) {
      _applySort(_sortState!);
    }
    _verticalScrollableController.addListener(() {
      _syncVertical(_verticalScrollableController, _verticalStickyController);
    });
    _verticalStickyController.addListener(() {
      _syncVertical(_verticalStickyController, _verticalScrollableController);
    });
    _horizontalScrollableController.addListener(() {
      _syncHorizontal(
        _horizontalScrollableController,
        _horizontalHeaderController,
      );
    });
    _horizontalHeaderController.addListener(() {
      _syncHorizontal(
        _horizontalHeaderController,
        _horizontalScrollableController,
      );
    });
  }

  @override
  void didUpdateWidget(covariant StickySortableDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows || oldWidget.externallySorted != widget.externallySorted) {
      _sortedRows = List<TableRowData>.from(widget.rows);
      if (_sortState != null && !widget.externallySorted) {
        _applySort(_sortState!);
      }
    }
  }

  @override
  void dispose() {
    _verticalScrollableController.dispose();
    _verticalStickyController.dispose();
    _horizontalScrollableController.dispose();
    _horizontalHeaderController.dispose();
    super.dispose();
  }

  void _syncVertical(ScrollController source, ScrollController target) {
    if (_isSyncingVertical || !target.hasClients) return;
    _isSyncingVertical = true;
    target.jumpTo(source.offset);
    _isSyncingVertical = false;
  }

  void _syncHorizontal(ScrollController source, ScrollController target) {
    if (_isSyncingHorizontal || !target.hasClients) return;
    _isSyncingHorizontal = true;
    target.jumpTo(source.offset);
    _isSyncingHorizontal = false;
  }

  void _onHeaderTap(int columnIndex) {
    final TableColumnDef column = widget.columns[columnIndex];
    if (!column.sortable) return;

    SortDirection nextDirection;
    if (_sortState == null || _sortState!.columnIndex != columnIndex) {
      nextDirection = SortDirection.ascending;
    } else {
      nextDirection = _sortState!.direction == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending;
    }

    final SortState newState = SortState(columnIndex: columnIndex, direction: nextDirection);
    setState(() {
      _sortState = newState;
      if (!widget.externallySorted) {
        _applySort(newState);
      }
    });

    widget.onSortChanged?.call(newState);
  }

  void _applySort(SortState state) {
    final comparator = widget.columns[state.columnIndex].comparator ??
        (TableRowData a, TableRowData b) {
          final TableCellData? cellA = a.cells.length > state.columnIndex ? a.cells[state.columnIndex] : null;
          final TableCellData? cellB = b.cells.length > state.columnIndex ? b.cells[state.columnIndex] : null;
          final dynamic valueA = cellA?.value ?? cellA?.text;
          final dynamic valueB = cellB?.value ?? cellB?.text;

          int compare(dynamic left, dynamic right) {
            if (left == null && right == null) return 0;
            if (left == null) return -1;
            if (right == null) return 1;
            if (left is num && right is num) {
              return left.compareTo(right);
            }
            return left.toString().toLowerCase().compareTo(right.toString().toLowerCase());
          }

          return compare(valueA, valueB);
        };

    _sortedRows.sort((a, b) {
      final result = comparator(a, b);
      return state.direction == SortDirection.ascending ? result : -result;
    });
  }

  double _columnWidth(int index) {
    return widget.columns[index].width ?? widget.defaultColumnWidth;
  }

  Widget _buildHeaderCell(int index) {
    final column = widget.columns[index];
    final isSortedColumn = _sortState?.columnIndex == index;
    final icon = isSortedColumn
        ? (_sortState!.direction == SortDirection.ascending
            ? Icons.arrow_upward
            : Icons.arrow_downward)
        : null;

    final Widget label = Row(
      mainAxisAlignment: _alignmentFromTextAlign(column.alignment),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            column.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 4),
          Icon(icon, size: 16),
        ],
      ],
    );

    final border = Border(
      right: widget.showVerticalDividers
          ? BorderSide(color: widget.gridBorderColor ?? Colors.grey.shade300)
          : BorderSide.none,
      bottom: BorderSide(color: widget.gridBorderColor ?? Colors.grey.shade300),
    );

    return GestureDetector(
      onTap: column.sortable ? () => _onHeaderTap(index) : null,
      child: Container(
        height: widget.headerHeight,
        width: _columnWidth(index),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: border,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: label,
      ),
    );
  }

  Widget _buildCell(TableCellData cell, TableColumnDef column) {
    final style = cell.style;
    final textStyle = TextStyle(
      color: style?.textColor,
      fontWeight: style?.bold == true ? FontWeight.bold : FontWeight.normal,
      fontStyle: style?.italic == true ? FontStyle.italic : FontStyle.normal,
    );
    final border = Border(
      right: widget.showVerticalDividers
          ? BorderSide(color: widget.gridBorderColor ?? Colors.grey.shade300)
          : BorderSide.none,
      bottom: widget.showHorizontalDividers
          ? BorderSide(color: widget.gridBorderColor ?? Colors.grey.shade200)
          : BorderSide.none,
    );

    return Container(
      height: widget.rowHeight,
      width: _columnWidth(widget.columns.indexOf(column)),
      decoration: BoxDecoration(
        color: style?.backgroundColor,
        border: border,
      ),
      padding: style?.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: _alignmentFromTextAlign(style?.textAlign ?? column.alignment) == MainAxisAlignment.start
          ? Alignment.centerLeft
          : _alignmentFromTextAlign(style?.textAlign ?? column.alignment) == MainAxisAlignment.end
              ? Alignment.centerRight
              : Alignment.center,
      child: Text(
        cell.text,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
        textAlign: style?.textAlign ?? column.alignment,
      ),
    );
  }

  MainAxisAlignment _alignmentFromTextAlign(TextAlign align) {
    switch (align) {
      case TextAlign.right:
      case TextAlign.end:
        return MainAxisAlignment.end;
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.left:
      case TextAlign.start:
      default:
        return MainAxisAlignment.start;
    }
  }

  List<TableColumnDef> get _stickyColumns =>
      widget.columns.take(widget.stickyColumnCount.clamp(0, widget.columns.length)).toList();

  List<TableColumnDef> get _scrollableColumns => widget.columns.skip(_stickyColumns.length).toList();

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (widget.rows.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('No data'));
    }

    return Padding(
      padding: widget.tablePadding ?? EdgeInsets.zero,
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 2),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        SizedBox(
          width: _stickyColumns.fold<double>(0, (sum, c) => sum + _columnWidth(widget.columns.indexOf(c))),
          child: Row(
            key: const Key('sticky_header_row'),
            children: [
              for (final column in _stickyColumns) _buildHeaderCell(widget.columns.indexOf(column)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: const Key('scrollable_header_row'),
            controller: _horizontalHeaderController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final column in _scrollableColumns) _buildHeaderCell(widget.columns.indexOf(column)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _stickyColumns.fold<double>(0, (sum, c) => sum + _columnWidth(widget.columns.indexOf(c))),
          child: ListView.builder(
            key: const Key('sticky_column_list'),
            controller: _verticalStickyController,
            itemCount: _sortedRows.length,
            itemBuilder: (context, rowIndex) {
              final row = _sortedRows[rowIndex];
              return Row(
                children: [
                  for (final column in _stickyColumns)
                    _buildCell(
                      row.cells[widget.columns.indexOf(column)],
                      column,
                    ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _horizontalScrollableController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _scrollableColumns.fold<double>(0, (sum, c) => sum + _columnWidth(widget.columns.indexOf(c))),
              child: ListView.builder(
                key: const Key('scrollable_rows_list'),
                controller: _verticalScrollableController,
                itemCount: _sortedRows.length,
                itemBuilder: (context, rowIndex) {
                  final row = _sortedRows[rowIndex];
                  return Row(
                    children: [
                      for (final column in _scrollableColumns)
                        _buildCell(
                          row.cells[widget.columns.indexOf(column)],
                          column,
                        ),
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
}
