import 'package:flutter/material.dart';
import '../../models/contact.dart';
import '../../pages/contact_page.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class DynamicFieldWidget extends StatelessWidget {
  final DynamicField field;
  final VoidCallback onTapField;
  final VoidCallback onManageGroups;
  final Color Function(String) getGroupColor;
  final IconData Function(FieldType) getIconForType;
  final Function(DateTime) onDatePicked;
  final Function(bool) onBooleanChanged;
  final Function(bool) onRemindYearlyChanged;
  final Function(bool) onWithoutYearChanged;
  final Function(List<String>) onRemindBeforeChanged;
  final VoidCallback onRevertAiChange;
  final VoidCallback onValueChanged;

  const DynamicFieldWidget({
    super.key,
    required this.field,
    required this.onTapField,
    required this.onManageGroups,
    required this.getGroupColor,
    required this.getIconForType,
    required this.onDatePicked,
    required this.onBooleanChanged,
    required this.onRemindYearlyChanged,
    required this.onWithoutYearChanged,
    required this.onRemindBeforeChanged,
    required this.onRevertAiChange,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: field.isAiGenerated
          ? Theme.of(
              context,
            ).colorScheme.tertiaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: onTapField,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Icon(
                              field.keyController.text == AppKeys.groups
                                  ? Icons.label_outline
                                  : getIconForType(field.type),
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              field.keyController.text.isEmpty
                                  ? l10n.newField
                                  : AppKeys.getLocalizedLabel(
                                      field.keyController.text,
                                      l10n,
                                    ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: field.isAiGenerated ? 36.0 : 0.0,
                    ),
                    child: _buildInput(context, l10n),
                  ),
                ),
              ],
            ),
            if (field.isAiGenerated)
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox.square(
                  dimension: 32,
                  child: IconButton(
                    tooltip: l10n.cancel,
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: onRevertAiChange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, AppLocalizations l10n) {
    if (field.keyController.text == AppKeys.groups) {
      final List<String> selectedGroups = Contact.parseGroups(
        field.valueController.text,
      );
      return InkWell(
        onTap: onManageGroups,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: selectedGroups.isEmpty
              ? Text(
                  l10n.tapToSelect,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                )
              : Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: selectedGroups.map((group) {
                    final color = getGroupColor(group);
                    return Chip(
                      label: Text(
                        group,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      backgroundColor: color.withValues(alpha: 0.3),
                      side: BorderSide(color: color.withValues(alpha: 0.6)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 0.0,
                      ),
                    );
                  }).toList(),
                ),
        ),
      );
    }

    switch (field.type) {
      case FieldType.number:
        return TextField(
          controller: field.valueController,
          keyboardType: TextInputType.phone,
          maxLength: 13,
          onChanged: (_) => onValueChanged(),
          decoration: const InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
            counterText: "",
          ),
        );
      case FieldType.date:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  onDatePicked(picked);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  field.valueController.text.isEmpty
                      ? l10n.selectDate
                      : field.valueController.text.endsWith('.0000')
                      ? field.valueController.text.substring(0, 5)
                      : field.valueController.text,
                  style: TextStyle(
                    color: field.valueController.text.isEmpty
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (field.valueController.text.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.withoutYear,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    child: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: field.valueController.text.endsWith('.0000'),
                        onChanged: onWithoutYearChanged,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.remindEveryYear,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    child: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: field.remindYearly,
                        onChanged: onRemindYearlyChanged,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.remindBefore,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showMultiSelectReminders(context, l10n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getRemindersSummary(field.remindBefore, l10n),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      case FieldType.boolean:
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 36,
            child: Switch(
              value: field.valueController.text == 'true',
              onChanged: onBooleanChanged,
            ),
          ),
        );
      case FieldType.text:
        return TextField(
          controller: field.valueController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 4,
          maxLength: 64,
          onChanged: (_) => onValueChanged(),
          decoration: InputDecoration(
            hintText: l10n.textType,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            counterText: "",
          ),
        );
    }
  }

  void _showMultiSelectReminders(BuildContext context, AppLocalizations l10n) {
    final Map<String, String> options = {
      'halfYear': l10n.halfYear,
      'threeMonths': l10n.threeMonths,
      'month': l10n.month,
      'twoWeeks': l10n.twoWeeks,
      'week': l10n.week,
      'threeDays': l10n.threeDays,
      'day': l10n.day,
      'today': l10n.today,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n.remindBefore,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    ...options.entries.map((entry) {
                      final isSelected = field.remindBefore.contains(entry.key);
                      return CheckboxListTile(
                        title: Text(entry.value),
                        value: isSelected,
                        dense: true,
                        onChanged: (val) {
                          final newList = List<String>.from(field.remindBefore);
                          if (val == true) {
                            newList.add(entry.key);
                          } else {
                            newList.remove(entry.key);
                          }
                          onRemindBeforeChanged(newList);
                          setModalState(() {});
                        },
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.save),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRemindersSummary(List<String> selected, AppLocalizations l10n) {
    if (selected.isEmpty) return l10n.tapToSelect;
    if (selected.length == 1) {
      return _getLocalizedInterval(selected.first, l10n);
    }
    return "${selected.length} ...";
  }

  String _getLocalizedInterval(String key, AppLocalizations l10n) {
    switch (key) {
      case 'halfYear':
        return l10n.halfYear;
      case 'threeMonths':
        return l10n.threeMonths;
      case 'month':
        return l10n.month;
      case 'twoWeeks':
        return l10n.twoWeeks;
      case 'week':
        return l10n.week;
      case 'threeDays':
        return l10n.threeDays;
      case 'day':
        return l10n.day;
      case 'today':
        return l10n.today;
      default:
        return key;
    }
  }
}
