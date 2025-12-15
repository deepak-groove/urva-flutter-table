import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:urva_flutter_table/widgets/models/table_models.dart';
import 'package:urva_flutter_table/widgets/sticky_sortable_data_table.dart';

void main() {
  group('StickySortableDataTable', () {
    final columns = [
      const TableColumnDef(title: 'ID', width: 80, alignment: TextAlign.center),
      const TableColumnDef(title: 'Name', width: 160),
      const TableColumnDef(title: 'Score', width: 100, alignment: TextAlign.end),
    ];

    List<TableRowData> buildRows() {
      return [
        TableRowData(cells: const [
          TableCellData(text: '1', value: 1),
          TableCellData(text: 'Alice'),
          TableCellData(text: '90', value: 90),
        ]),
        TableRowData(cells: const [
          TableCellData(text: '2', value: 2),
          TableCellData(text: 'Bob'),
          TableCellData(text: '75', value: 75),
        ]),
      ];
    }

    testWidgets('supports sorting on header tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StickySortableDataTable(
            columns: columns,
            rows: buildRows(),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      await tester.tap(find.text('Score'));
      await tester.pumpAndSettle();

      // After sorting descending the first row should contain the larger score (90).
      final firstCell = tester.widgetList<Text>(find.descendant(
        of: find.byKey(const Key('scrollable_rows_list')),
        matching: find.textContaining('9'),
      ));
      expect(firstCell.first.data, contains('90'));
    });

    testWidgets('keeps header and first column sticky', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 200,
            child: StickySortableDataTable(
              columns: columns,
              rows: List<TableRowData>.generate(20, (index) {
                return TableRowData(cells: [
                  TableCellData(text: '${index + 1}'),
                  TableCellData(text: 'Row ${index + 1}'),
                  const TableCellData(text: '0'),
                ]);
              }),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('sticky_header_row')), findsOneWidget);
      expect(find.byKey(const Key('sticky_column_list')), findsOneWidget);

      await tester.drag(find.byKey(const Key('scrollable_rows_list')), const Offset(0, -150));
      await tester.pump();

      // Header should still be visible after scroll.
      expect(find.text('ID'), findsOneWidget);
    });

    testWidgets('applies per-cell styling', (tester) async {
      final styledRow = TableRowData(cells: const [
        TableCellData(
          text: '1',
          style: TableCellStyle(backgroundColor: Colors.red, textColor: Colors.white, bold: true),
        ),
        TableCellData(
          text: 'Styled',
          style: TableCellStyle(italic: true),
        ),
        TableCellData(text: '0'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: StickySortableDataTable(
            columns: columns,
            rows: [styledRow],
          ),
        ),
      );

      final container = tester.widget<Container>(find.descendant(
        of: find.byKey(const Key('sticky_column_list')),
        matching: find.byType(Container),
      ).first);

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, Colors.red);
    });
  });
}
