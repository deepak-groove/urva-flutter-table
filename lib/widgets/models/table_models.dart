import 'package:flutter/material.dart';

/// Direction of sorting applied to a column.
enum SortDirection { ascending, descending }

/// Represents the active sort state of the table.
class SortState {
  const SortState({required this.columnIndex, required this.direction});

  final int columnIndex;
  final SortDirection direction;
}

/// Styling applied to a single cell.
class TableCellStyle {
  const TableCellStyle({
    this.backgroundColor,
    this.textColor,
    this.bold = false,
    this.italic = false,
    this.textAlign = TextAlign.start,
    this.padding,
  });

  final Color? backgroundColor;
  final Color? textColor;
  final bool bold;
  final bool italic;
  final TextAlign textAlign;
  final EdgeInsets? padding;
}

/// Data displayed in a single cell.
class TableCellData {
  const TableCellData({
    required this.text,
    this.value,
    this.style,
  });

  /// Text shown to the user.
  final String text;

  /// Value used for sorting; falls back to [text] if null.
  final dynamic value;

  /// Optional styling information for the cell.
  final TableCellStyle? style;
}

/// Column definition used by [StickySortableDataTable].
class TableColumnDef {
  const TableColumnDef({
    required this.title,
    this.width,
    this.sortable = true,
    this.comparator,
    this.alignment = TextAlign.start,
  });

  final String title;
  final double? width;
  final bool sortable;
  final int Function(TableRowData a, TableRowData b)? comparator;
  final TextAlign alignment;
}

/// Row data used by [StickySortableDataTable].
class TableRowData {
  const TableRowData({required this.cells});

  final List<TableCellData> cells;
}
