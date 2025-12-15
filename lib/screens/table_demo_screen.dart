import 'package:flutter/material.dart';

import '../widgets/models/table_models.dart';
import '../widgets/sticky_sortable_data_table.dart';

class TableDemoScreen extends StatefulWidget {
  const TableDemoScreen({super.key});

  @override
  State<TableDemoScreen> createState() => _TableDemoScreenState();
}

class _TableDemoScreenState extends State<TableDemoScreen> {
  late List<TableRowData> _rows;
  SortState? _sortState;

  @override
  void initState() {
    super.initState();
    _rows = List<TableRowData>.generate(50, (index) {
      final score = 50 + (index * 3) % 40;
      return TableRowData(cells: [
        TableCellData(text: '${index + 1}', value: index + 1),
        TableCellData(text: 'Person ${index + 1}'),
        TableCellData(text: '$score', value: score),
        TableCellData(
          text: index.isEven ? 'Active' : 'Pending',
          style: TableCellStyle(
            backgroundColor: index.isEven ? Colors.green.shade50 : Colors.orange.shade50,
            textColor: index.isEven ? Colors.green.shade800 : Colors.orange.shade800,
            bold: index.isEven,
          ),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      const TableColumnDef(title: 'ID', width: 72, alignment: TextAlign.center),
      const TableColumnDef(title: 'Name', width: 180),
      const TableColumnDef(title: 'Score', width: 120, alignment: TextAlign.end),
      const TableColumnDef(title: 'Status', width: 140),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Sticky Sortable Data Table')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StickySortableDataTable(
          columns: columns,
          rows: _rows,
          stickyColumnCount: 1,
          onSortChanged: (sort) {
            setState(() {
              _sortState = sort;
              _rows = _applySort(_rows, sort);
            });
          },
          externallySorted: true,
          initialSort: _sortState,
        ),
      ),
    );
  }

  List<TableRowData> _applySort(List<TableRowData> rows, SortState sort) {
    final sorted = List<TableRowData>.from(rows);
    sorted.sort((a, b) {
      final cellA = a.cells[sort.columnIndex];
      final cellB = b.cells[sort.columnIndex];
      final valueA = cellA.value ?? cellA.text;
      final valueB = cellB.value ?? cellB.text;
      final int base;
      if (valueA is num && valueB is num) {
        base = valueA.compareTo(valueB);
      } else {
        base = valueA.toString().compareTo(valueB.toString());
      }
      return sort.direction == SortDirection.asc ? base : -base;
    });
    return sorted;
  }
}
