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
    _rows = _generateRows();
  }

  List<TableRowData> _generateRows() {
    return List<TableRowData>.generate(50, (index) {
      final isEven = index % 2 == 0;
      return TableRowData(cells: [
        TableCellData(
          text: '#${index + 1}',
          value: index,
          style: TableCellStyle(
            backgroundColor: isEven ? Colors.blue.shade50 : Colors.white,
            bold: true,
          ),
        ),
        TableCellData(
          text: 'Item ${index + 1}',
          style: TableCellStyle(
            backgroundColor: isEven ? Colors.blue.shade50 : Colors.white,
          ),
        ),
        TableCellData(
          text: '${(index * 3) % 100}',
          value: (index * 3) % 100,
          style: TableCellStyle(
            backgroundColor: isEven ? Colors.blue.shade50 : Colors.white,
            textAlign: TextAlign.end,
          ),
        ),
        TableCellData(
          text: index % 3 == 0 ? 'High' : 'Low',
          value: index % 3 == 0 ? 1 : 0,
          style: TableCellStyle(
            backgroundColor: isEven ? Colors.blue.shade50 : Colors.white,
            textColor: index % 3 == 0 ? Colors.red : Colors.green,
            italic: index % 3 == 0,
          ),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      const TableColumnDef(title: 'ID', width: 90, alignment: TextAlign.center),
      const TableColumnDef(title: 'Name', width: 180),
      const TableColumnDef(title: 'Score', width: 120, alignment: TextAlign.end),
      const TableColumnDef(title: 'Priority', width: 140),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sticky Sortable Data Table Demo'),
      ),
      body: StickySortableDataTable(
        columns: columns,
        rows: _rows,
        initialSort: _sortState,
        onSortChanged: (state) {
          setState(() {
            _sortState = state;
          });
        },
        stickyColumnCount: 1,
        headerHeight: 48,
        rowHeight: 44,
        defaultColumnWidth: 140,
        tablePadding: const EdgeInsets.all(8),
      ),
    );
  }
}
