import 'package:flutter/material.dart';

import 'screens/table_demo_screen.dart';

void main() {
  runApp(const StickyTableDemoApp());
}

class StickyTableDemoApp extends StatelessWidget {
  const StickyTableDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Sortable Data Table',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const TableDemoScreen(),
    );
  }
}
