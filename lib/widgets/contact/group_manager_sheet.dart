import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class GroupManagerSheet extends StatelessWidget {
  final Set<String> availableGroups;
  final List<String> selectedGroups;
  final TextEditingController groupInputController;
  final Function(String, StateSetter) onAddGroup;
  final Function(String, bool, StateSetter) onToggleGroup;
  final Function(String, StateSetter) onEditGroup;
  final Color Function(String) getGroupColor;

  const GroupManagerSheet({
    super.key,
    required this.availableGroups,
    required this.selectedGroups,
    required this.groupInputController,
    required this.onAddGroup,
    required this.onToggleGroup,
    required this.onEditGroup,
    required this.getGroupColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.manageGroups,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: groupInputController,
                      maxLength: 64,
                      decoration: InputDecoration(
                        hintText: l10n.createNewGroup,
                        counterText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onSubmitted: (val) => onAddGroup(val, setModalState),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 36,
                    ),
                    onPressed: () =>
                        onAddGroup(groupInputController.text, setModalState),
                  ),
                ],
              ),
              const Divider(height: 24),
              if (availableGroups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    l10n.noGroupsYet,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableGroups.length,
                  itemBuilder: (context, index) {
                    final group = availableGroups.elementAt(index);
                    final isSelected = selectedGroups.contains(group);
                    final color = getGroupColor(group);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: isSelected,
                        activeColor: color,
                        onChanged: (bool? val) {
                          onToggleGroup(group, val ?? false, setModalState);
                        },
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: color.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              group,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        tooltip: l10n.configure,
                        onPressed: () => onEditGroup(group, setModalState),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
