import 'package:flutter/material.dart';
import '../../models/contact.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class ContactTable extends StatelessWidget {
  final List<String> columns;
  final List<Contact> filteredContacts;
  final List<Contact> allContacts;
  final Map<String, double> columnWidths;
  final bool isFilteringActive;
  final String? sortColumn;
  final bool sortAscending;
  final Function(String) onSort;
  final Function(int, int) onReorder;
  final Function(Contact) onTap;
  final Color Function(String) getGroupColor;

  const ContactTable({
    super.key,
    required this.columns,
    required this.filteredContacts,
    required this.allContacts,
    required this.columnWidths,
    required this.isFilteringActive,
    this.sortColumn,
    this.sortAscending = true,
    required this.onSort,
    required this.onReorder,
    required this.onTap,
    required this.getGroupColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (allContacts.isEmpty) {
      return Center(
        child: Text(l10n.contactListEmpty, style: const TextStyle(fontSize: 18)),
      );
    }

    if (columns.isEmpty) {
      return Center(
        child: Text(
          l10n.selectAtLeastOneColumn,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (filteredContacts.isEmpty) {
      return Center(
        child: Text(l10n.noResultsFound, style: const TextStyle(fontSize: 18)),
      );
    }

    double totalWidth = 50.0;
    for (String colName in columns) {
      totalWidth += columnWidths[colName] ?? 0.0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth,
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Table Header
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      ...columns.map((colName) => SizedBox(
                            width: columnWidths[colName],
                            child: InkWell(
                              onTap: () => onSort(colName),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppKeys.getLocalizedLabel(colName, l10n),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (sortColumn == colName)
                                      Icon(
                                        sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                      const SizedBox(width: 48), // Space for reorder handle placeholder
                    ],
                  ),
                ),
                // Table Body
                Expanded(
                  child: ReorderableListView(
                    buildDefaultDragHandles: !isFilteringActive,
                    onReorderItem: (oldIndex, newIndex) {
                      if (isFilteringActive) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.reorderingDisabledWhileFiltering)),
                        );
                        return;
                      }
                      onReorder(oldIndex, newIndex);
                    },
                    children: filteredContacts.map((contact) {
                      return InkWell(
                        key: ValueKey(contact.id),
                        onTap: () => onTap(contact),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              ...columns.map((colName) {
                                final rawValue = contact.fields[colName];
                                String value;

                                if (rawValue is Map) {
                                  value = rawValue['date']?.toString() ?? '';
                                } else {
                                  value = rawValue?.toString() ?? '';
                                }
                                
                                if (value.endsWith('.0000')) {
                                  value = value.substring(0, 5);
                                }

                                Widget cellContent;

                                if (colName == AppKeys.groups && value.isNotEmpty) {
                                  List<String> groups = Contact.parseGroups(value);
                                  cellContent = SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: groups.map((g) {
                                        final color = getGroupColor(g);
                                        return Container(
                                          margin: const EdgeInsets.only(right: 6.0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(8.0),
                                            border: Border.all(color: color.withValues(alpha: 0.6)),
                                          ),
                                          child: Text(
                                            g,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                } else if (value.toLowerCase() == 'true') {
                                  cellContent = const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  );
                                } else if (value.toLowerCase() == 'false') {
                                  cellContent = const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.cancel, color: Colors.red, size: 20),
                                  );
                                } else {
                                  cellContent = Text(
                                    value,
                                    style: colName == AppKeys.name
                                        ? const TextStyle(fontWeight: FontWeight.bold)
                                        : null,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }

                                return SizedBox(
                                  width: columnWidths[colName],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: cellContent,
                                  ),
                                );
                              }),
                              const SizedBox(width: 48), // Match header spacer for reorder handle
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
