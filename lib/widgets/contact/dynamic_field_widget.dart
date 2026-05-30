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

  const DynamicFieldWidget({
    super.key,
    required this.field,
    required this.onTapField,
    required this.onManageGroups,
    required this.getGroupColor,
    required this.getIconForType,
    required this.onDatePicked,
    required this.onBooleanChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: field.isAiGenerated
          ? Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
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
                              : AppKeys.getLocalizedLabel(field.keyController.text, l10n),
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
              child: _buildInput(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, AppLocalizations l10n) {
    if (field.keyController.text == AppKeys.groups) {
      final List<String> selectedGroups = Contact.parseGroups(field.valueController.text);
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      backgroundColor: color.withValues(alpha: 0.3),
                      side: BorderSide(color: color.withValues(alpha: 0.6)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
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
          decoration: const InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
        );
      case FieldType.date:
        return InkWell(
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
                  : field.valueController.text,
              style: TextStyle(
                color: field.valueController.text.isEmpty
                    ? Colors.grey
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
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
          decoration: InputDecoration(
            hintText: l10n.textType,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          ),
        );
    }
  }
}
