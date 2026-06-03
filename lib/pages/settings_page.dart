import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/contact.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final currentLocale = localeProvider.locale ?? Localizations.localeOf(context);

    final hsvColor = HSVColor.fromColor(themeProvider.seedColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: currentLocale.languageCode,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  localeProvider.setLocale(Locale(newValue));
                }
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'en',
                  child: Text(l10n.english),
                ),
                DropdownMenuItem<String>(
                  value: 'uk',
                  child: Text(l10n.ukrainian),
                ),
                DropdownMenuItem<String>(
                  value: 'de',
                  child: Text(l10n.german),
                ),
                DropdownMenuItem<String>(
                  value: 'fr',
                  child: Text(l10n.french),
                ),
                DropdownMenuItem<String>(
                  value: 'es',
                  child: Text(l10n.spanish),
                ),
                DropdownMenuItem<String>(
                  value: 'pl',
                  child: Text(l10n.polish),
                ),
              ],
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.themeColor,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        themeProvider.themeMode == ThemeMode.light
                            ? Icons.light_mode
                            : Icons.light_mode_outlined,
                        color: themeProvider.themeMode == ThemeMode.light
                            ? themeProvider.seedColor
                            : null,
                      ),
                      onPressed: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    IconButton(
                      icon: Icon(
                        themeProvider.themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.dark_mode_outlined,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? themeProvider.seedColor
                            : null,
                      ),
                      onPressed: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: hsvColor.hue,
                  min: 0,
                  max: 360,
                  activeColor: themeProvider.seedColor,
                  onChanged: (double value) {
                    final newColor = HSVColor.fromAHSV(1.0, value, 0.7, 0.9).toColor();
                    themeProvider.setSeedColor(newColor);
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(l10n.reminderTime),
            trailing: Text(
              notificationProvider.reminderTime.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: notificationProvider.reminderTime,
              );
              if (picked != null) {
                notificationProvider.setReminderTime(picked);
              }
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.upload),
            title: Text(l10n.exportData),
            onTap: () => _exportData(context, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.importData),
            onTap: () => _importData(context, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: Text(l10n.importFromPhone),
            onTap: () => _importFromPhone(context, l10n),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Ладіков Максим, 45 група \n ladikovmax@gmail.com",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, AppLocalizations l10n) async {
    try {
      final contacts = await FirestoreService().getAllContacts();
      if (contacts.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noDataToExport)),
          );
        }
        return;
      }

      final jsonData = contacts.map((c) => c.toMap()).toList();
      final jsonString = jsonEncode(jsonData);

      if (kIsWeb) {
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/contacts_export.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], text: 'Personal PIM Contacts Export');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportSuccessful)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.exportFailed}: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, AppLocalizations l10n) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);

      final contacts = jsonData.map((data) {
        return Contact.fromMap(Map<String, dynamic>.from(data), "");
      }).toList();

      await FirestoreService().importContacts(contacts);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importSuccessful)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.importFailed}: $e')),
        );
      }
    }
  }

  Future<void> _importFromPhone(BuildContext context, AppLocalizations l10n) async {
    try {
      if (kIsWeb) return;

      final status = await fc.FlutterContacts.permissions.request(fc.PermissionType.read);
      if (status != fc.PermissionStatus.granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.permissionDenied)),
          );
        }
        return;
      }

      final nativeContacts = await fc.FlutterContacts.getAll(
        properties: {fc.ContactProperty.phone, fc.ContactProperty.email, fc.ContactProperty.event},
      );

      if (nativeContacts.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noResultsFound)),
          );
        }
        return;
      }

      if (context.mounted) {
        final selectedContacts = await showModalBottomSheet<List<Contact>>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => _ContactPickerSheet(
            nativeContacts: nativeContacts,
            l10n: l10n,
          ),
        );

        if (selectedContacts != null && selectedContacts.isNotEmpty) {
          await FirestoreService().importContacts(selectedContacts);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.importSuccessful)),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }
}

class _ContactPickerSheet extends StatefulWidget {
  final List<fc.Contact> nativeContacts;
  final AppLocalizations l10n;

  const _ContactPickerSheet({
    required this.nativeContacts,
    required this.l10n,
  });

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  final Set<int> _selectedIndices = {};
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredContacts = widget.nativeContacts.where((c) {
      final name = c.displayName ?? "";
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        AppBar(
          title: Text(widget.l10n.selectContacts),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: widget.l10n.search,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = filteredContacts[index];
              final nativeIndex = widget.nativeContacts.indexOf(contact);
              final isSelected = _selectedIndices.contains(nativeIndex);

              return CheckboxListTile(
                title: Text(contact.displayName ?? ""),
                subtitle: Text(contact.phones.isNotEmpty ? (contact.phones.first.number) : ""),
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedIndices.add(nativeIndex);
                    } else {
                      _selectedIndices.remove(nativeIndex);
                    }
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () {
                      final selected = _selectedIndices.map((i) {
                        final nc = widget.nativeContacts[i];
                        return _mapNativeToContact(nc);
                      }).toList();
                      Navigator.pop(context, selected);
                    },
              child: Text(widget.l10n.importNContacts(_selectedIndices.length)),
            ),
          ),
        ),
      ],
    );
  }

  Contact _mapNativeToContact(fc.Contact native) {
    final Map<String, dynamic> fields = {
      AppKeys.name: native.displayName ?? "",
    };

    if (native.phones.isNotEmpty) {
      fields[AppKeys.phone] = native.phones.first.number;
    }

    if (native.emails.isNotEmpty) {
      fields[AppKeys.email] = native.emails.first.address;
    }

    if (native.events.isNotEmpty) {
      final bday = native.events.where((e) => e.label.label == fc.EventLabel.birthday).toList();
      if (bday.isNotEmpty) {
        final date = bday.first;
        final monthStr = date.month.toString().padLeft(2, '0');
        final dayStr = date.day.toString().padLeft(2, '0');
        String dateStr;
        if (date.year != null) {
          dateStr = "$dayStr.$monthStr.${date.year}";
        } else {
          dateStr = "$dayStr.$monthStr.0000";
        }
        fields[AppKeys.birthday] = {
          'date': dateStr,
          'remindYearly': true,
          'remindBefore': 'day',
        };
      }
    }

    return Contact(fields: fields);
  }
}
