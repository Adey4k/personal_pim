import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class ColumnSettingsSheet extends StatelessWidget {
  final Set<String> allKeys;
  final List<String> columns;
  final Function(int, int) onReorder;
  final Function(int) onRemove;
  final Function(String) onAdd;
  final VoidCallback onSave;

  const ColumnSettingsSheet({
    super.key,
    required this.allKeys,
    required this.columns,
    required this.onReorder,
    required this.onRemove,
    required this.onAdd,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StatefulBuilder(
      builder: (context, setModalState) {
        List<String> unselectedKeys = allKeys.difference(columns.toSet()).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.configureTable,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.columnReorderInstruction),
              const SizedBox(height: 16),
              Expanded(
                child: ReorderableListView(
                  onReorderItem: (oldIndex, newIndex) {
                    setModalState(() {
                      onReorder(oldIndex, newIndex);
                    });
                    onSave();
                  },
                  children: [
                    for (int index = 0; index < columns.length; index += 1)
                      ListTile(
                        key: ValueKey(columns[index]),
                        title: Text(AppKeys.getLocalizedLabel(columns[index], l10n)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  onRemove(index);
                                });
                                onSave();
                              },
                            ),
                            const Icon(Icons.drag_handle),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 32, thickness: 2),
              Text(
                l10n.availableFieldsToAdd,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unselectedKeys.map((key) {
                  return ActionChip(
                    label: Text('+ ${AppKeys.getLocalizedLabel(key, l10n)}'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () {
                      setModalState(() {
                        onAdd(key);
                      });
                      onSave();
                    },
                  );
                }).toList(),
              ),
              if (unselectedKeys.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    l10n.allFieldsAlreadyInTable,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
