import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'settings_page.dart';
import 'calendar_page.dart';
import '../widgets/home/search_filter_bar.dart';
import '../widgets/home/column_settings_sheet.dart';
import '../widgets/home/contact_table.dart';
import 'contact_page.dart';
import '../services/home_widget_service.dart';
import '../services/firestore_service.dart';
import '../models/contact.dart';
import '../utils/constants.dart';
import '../utils/group_style.dart';
import '../utils/showcase_utils.dart';
import '../utils/validators.dart';
import '../l10n/app_localizations.dart';
import '../providers/tutorial_provider.dart';
import '../providers/contacts_provider.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _tableKey = GlobalKey();
  final GlobalKey _addKey = GlobalKey();
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();

  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<Contact>> _contactsStream;

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: 1,
  );

  @override
  void initState() {
    super.initState();
    ensureShowcaseViewRegistered();
    // Getting firestore service from provider safely in initState
    _contactsStream = Provider.of<FirestoreService>(
      context,
      listen: false,
    ).getContactsStream();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(NotificationService().requestPermissions());
    });
  }

  Future<void> _startTutorialIfNeeded() async {
    final tutorialProvider = context.read<TutorialProvider?>();
    if (tutorialProvider == null || tutorialProvider.isHomeTutorialShown) {
      return;
    }

    try {
      ShowcaseView.get().startShowCase([
        _tableKey,
        _addKey,
        _calendarKey,
        _settingsKey,
      ]);
    } catch (_) {
      // Skip if keys aren't mounted yet.
    }
    await tutorialProvider.markHomeTutorialAsShown();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Removed columns caching and width calculation, now in ContactsProvider

  Color _getGroupColor(String groupName) =>
      GroupStyle.colorFor(context, groupName);

  // Removed column width calc and sorting logic, now in ContactsProvider

  void _showColumnSettings(ContactsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ColumnSettingsSheet(
          allKeys: provider.knownKeys,
          columns: provider.columns.toList(),
          onReorder: (oldIndex, newIndex) {
            final columns = provider.columns.toList();
            final String item = columns.removeAt(oldIndex);
            columns.insert(newIndex, item);
            provider.updateColumns(columns);
          },
          onRemove: (index) {
            final columns = provider.columns.toList();
            columns.removeAt(index);
            provider.updateColumns(columns);
          },
          onAdd: (key) {
            final columns = provider.columns.toList();
            columns.add(key);
            provider.updateColumns(columns);
          },
          onSave: () {
            // Already saved inside updateColumns
          },
        );
      },
    );
  }

  Map<String, FieldType> _inferFieldTypes(List<Contact> contacts) {
    Map<String, FieldType> types = {};
    for (var contact in contacts) {
      for (var entry in contact.fields.entries) {
        String key = entry.key;
        String valueStr = "";

        if (entry.value is Map) {
          valueStr = entry.value['date']?.toString() ?? "";
        } else {
          valueStr = entry.value?.toString() ?? "";
        }

        if (valueStr.trim().isNotEmpty && !types.containsKey(key)) {
          if (key == AppKeys.name ||
              key == AppKeys.phone ||
              key == AppKeys.email ||
              key == AppKeys.birthday ||
              key == AppKeys.groups) {
            continue;
          }

          types[key] = Validators.inferType(valueStr);
        }
      }
    }
    return types;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildContactsTab(),
          const CalendarPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Showcase(
              key: _calendarKey,
              title: l10n.onboardingCalendarTitle,
              description: l10n.onboardingCalendarDesc,
              targetPadding: const EdgeInsets.all(4),
              child: const Icon(Icons.calendar_today),
            ),
            label: l10n.calendar,
          ),
          BottomNavigationBarItem(
            icon: Showcase(
              key: _settingsKey,
              title: l10n.onboardingSettingsTitle,
              description: l10n.onboardingSettingsDesc,
              targetPadding: const EdgeInsets.all(4),
              child: const Icon(Icons.settings),
            ),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<Contact>>(
      stream: _contactsStream,
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];
        final provider = Provider.of<ContactsProvider>(context, listen: false);

        // Use post-frame callback to avoid updating state during build
        if (snapshot.connectionState != ConnectionState.waiting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.syncColumnsWithData(contacts);
            HomeWidgetService.updateBirthdays(contacts);
            HomeWidgetService.updateCustomEvents(contacts);
            _startTutorialIfNeeded();
          });
        }

        final existingNames = contacts.map((c) => c.name).toSet();

        Set<String> existingGroups = {};
        for (var c in contacts) {
          final groupStr = c.fields[AppKeys.groups]?.toString();
          if (groupStr != null) {
            existingGroups.addAll(Contact.parseGroups(groupStr));
          }
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(AppLocalizations.of(context)!.home),
            actions: [
              if (snapshot.hasData && contacts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.view_column),
                  tooltip: AppLocalizations.of(context)!.configureColumns,
                  onPressed: () => _showColumnSettings(provider),
                ),
            ],
          ),
          body: _buildBody(snapshot, contacts, existingNames, existingGroups),
          floatingActionButton: Showcase(
            key: _addKey,
            title: l10n.onboardingAddContactTitle,
            description: l10n.onboardingAddContactDesc,
            child: FloatingActionButton(
              heroTag: 'home_add_contact_fab',
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () async {
                final allFieldTypes = _inferFieldTypes(contacts);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPage(
                      existingFields: provider.knownKeys,
                      existingNames: existingNames,
                      existingGroups: existingGroups,
                      existingFieldTypes: allFieldTypes,
                    ),
                  ),
                );
                provider.invalidateCache();
              },
              tooltip: 'Додати контакт',
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<List<Contact>> snapshot,
    List<Contact> contacts,
    Set<String> existingNames,
    Set<String> existingGroups,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Помилка: ${snapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Consumer<ContactsProvider>(
      builder: (context, provider, child) {
        bool isSearchActive =
            provider.searchQuery.isNotEmpty ||
            provider.selectedGroupFilter != null;
        List<Contact> filteredContacts = provider.getFilteredAndSortedContacts(
          contacts,
        );

        Map<String, double> columnWidths = {};
        for (String colName in provider.columns) {
          columnWidths[colName] = provider.calculateColumnWidth(
            colName,
            contacts,
            context,
            _textPainter,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchFilterBar(
              searchController: _searchController,
              searchQuery: provider.searchQuery,
              onSearchChanged: (value) => provider.setSearchQuery(value),
              onClearSearch: () {
                _searchController.clear();
                provider.clearSearch();
                FocusScope.of(context).unfocus();
              },
              existingGroups: existingGroups,
              selectedGroupFilter: provider.selectedGroupFilter,
              onGroupFilterChanged: (group) => provider.setGroupFilter(group),
              getGroupColor: _getGroupColor,
            ),
            Expanded(
              child: Showcase(
                key: _tableKey,
                title: l10n.onboardingHomeTitle,
                description: l10n.onboardingHomeDesc,
                child: ContactTable(
                  columns: provider.columns,
                  filteredContacts: filteredContacts,
                  allContacts: contacts,
                  columnWidths: columnWidths,
                  isFilteringActive: isSearchActive,
                  sortColumn: provider.sortColumn,
                  sortAscending: provider.sortAscending,
                  onSort: (column) => provider.toggleSort(column),
                  onReorder: (oldIndex, newIndex) {
                    final contact = filteredContacts.removeAt(oldIndex);
                    filteredContacts.insert(newIndex, contact);

                    if (provider.sortColumn != null) {
                      provider.toggleSort(
                        provider.sortColumn!,
                      ); // This might just clear sort
                    }

                    context.read<FirestoreService>().updateAllContactsOrder(
                      filteredContacts,
                    );
                  },
                  onTap: (contact) async {
                    final allFieldTypes = _inferFieldTypes(contacts);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactPage(
                          existingFields: provider.knownKeys,
                          existingNames: existingNames,
                          existingGroups: existingGroups,
                          existingFieldTypes: allFieldTypes,
                          contact: contact,
                        ),
                      ),
                    );
                    provider.invalidateCache();
                  },
                  getGroupColor: _getGroupColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
