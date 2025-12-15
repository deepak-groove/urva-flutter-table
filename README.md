# StickySortableDataTable (Flutter – Pure Flutter, OSS Only)

## Objective
Build a reusable **Flutter table component** for **Android and iOS** with advanced table capabilities, implemented using **pure Flutter**.

### Constraints (Mandatory)
- **Pure Flutter implementation**
- **Only open-source packages are allowed**
- **NO proprietary / paid / commercial packages**
- **NO platform-specific (Android/iOS) native code**
- Component must work identically on Android and iOS

---

## Required Features

### Core Capabilities
- Sorting on **column header click**
- **Horizontal scrolling** for wide tables
- **Vertical scrolling** for large datasets
- **Sticky / frozen header row**
- **Sticky / frozen first column**
- Per-cell styling:
  - dynamic **background color**
  - dynamic **text color**
  - **bold**
  - **italic**

---

## Deliverables
Create the following files:

1. `lib/widgets/sticky_sortable_data_table.dart`
2. `lib/widgets/models/table_models.dart`
3. *(Optional but recommended)*  
   `lib/screens/table_demo_screen.dart`
4. *(Optional)*  
   `test/sticky_sortable_data_table_test.dart`

---

## Component Name
`StickySortableDataTable`

---

## Scrolling Requirements

### Vertical Scroll
- Scrolls table rows.
- Header row must remain **sticky**.
- Smooth scrolling with large datasets (1000+ rows).

### Horizontal Scroll
- Scrolls table columns.
- First column must remain **sticky**.
- Header and body must stay perfectly aligned.

### Alignment Rules
- No visual drift between:
  - sticky header and body columns
  - sticky first column and scrollable rows
- Row heights and column widths must be deterministic.

---

## Sorting Requirements
- Sorting triggers on **header tap** if column is sortable.
- Toggle behavior:
  - `asc → desc → asc`
  - or `none → asc → desc → asc` (document choice)
- Single-column sorting only.
- Active sort indicator must be visible in header.
- Must support strings, numbers, and custom comparators.

---

## Styling Requirements (Cell Level)

Each cell must support:
- `backgroundColor`
- `textColor`
- `bold`
- `italic`

Optional:
- `textAlign`
- `padding`

---

## Performance Requirements
- Must handle **20+ columns** and **1000+ rows**
- Use lazy builders (`ListView.builder`)
- Avoid eager rendering

---

## Public API

```dart
StickySortableDataTable({
  required List<TableColumnDef> columns,
  required List<TableRowData> rows,
  int stickyColumnCount = 1,
  double headerHeight = 48,
  double rowHeight = 44,
  double defaultColumnWidth = 140,
  SortState? initialSort,
  void Function(SortState sort)? onSortChanged,
  bool externallySorted = false,
  EdgeInsets? tablePadding,
  Color? gridBorderColor,
  bool showVerticalDividers = true,
  bool showHorizontalDividers = true,
  bool isLoading = false,
  Widget? loadingWidget,
  Widget? emptyWidget,
})
```

---

## Package Policy
- Only **open-source** packages (MIT / Apache / BSD)
- Flutter SDK widgets allowed
- NO proprietary or closed-source libraries

---

## Acceptance Criteria
1. Sticky header works
2. Sticky first column works
3. Sorting works correctly
4. Styling works per cell
5. No misalignment
6. Android + iOS compatible
7. Pure Flutter + OSS only
