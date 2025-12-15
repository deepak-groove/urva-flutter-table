import 'package:flutter/material.dart';

/// Describes a column in the sticky sortable data table.
class TableColumnDef {
  const TableColumnDef({
    required this.title,
    this.width,
    this.alignment,
    this.sortable = true,
    this.comparator,
  });

  /// Header label for the column.
  final String title;

  /// Fixed width for the column. Falls back to the table default when null.
  final double? width;

  /// Text alignment for the column cells.
  final TextAlign? alignment;

  /// Whether the column supports sorting.
  final bool sortable;

  /// Optional comparator for custom sorting.
  ///
  /// When omitted the table will attempt to sort using [TableCellData.value]
  /// first and fall back to the [TableCellData.text] string.
  final int Function(TableCellData a, TableCellData b)? comparator;
}

/// Visual styling for a table cell.
class TableCellStyle {
  const TableCellStyle({
    this.backgroundColor,
    this.textColor,
    this.bold = false,
    this.italic = false,
    this.textAlign,
    this.padding,
  });

  final Color? backgroundColor;
  final Color? textColor;
  final bool bold;
  final bool italic;
  final TextAlign? textAlign;
  final EdgeInsets? padding;
}

/// Represents the content of an individual cell.
class TableCellData {
  const TableCellData({
    required this.text,
    this.value,
    this.style,
  });

  /// Human-readable text shown in the cell.
  final String text;

  /// Optional raw value used for sorting.
  final dynamic value;

  /// Style for the cell.
  final TableCellStyle? style;
}

/// Represents a row of cells.
class TableRowData {
  TableRowData({
    required this.cells,
  });

  final List<TableCellData> cells;
}

/// Sorting direction for a column.
enum SortDirection { asc, desc }

/// Represents the current sorting state.
class SortState {
  const SortState({required this.columnIndex, required this.direction});

  final int columnIndex;
  final SortDirection direction;
}
