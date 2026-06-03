import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home/search_filter_bar.dart';
import '../widgets/home/column_settings_sheet.dart';
import '../widgets/home/contact_table.dart';
import 'contact_page.dart';
import '../services/firestore_service.dart';
import '../models/contact.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _dbService = FirestoreService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedGroupFilter;

  List<String> _columns = [];
  final Set<String> _knownKeys = {};
  static const String _prefsKey = 'saved_columns';

  String? _sortColumn;
  bool _sortAscending = true;

  final Map<String, double> _columnWidthCache = {};
  late Stream<List<Contact>> _contactsStream;

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: 1,
  );

  @override
  void initState() {
    super.initState();
    _contactsStream = _dbService.getContactsStream();
    _loadColumns();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadColumns() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColumns = prefs.getStringList(_prefsKey);

    setState(() {
      if (savedColumns != null && savedColumns.isNotEmpty) {
        _columns = savedColumns;
      } else {
        _columns = [
          AppKeys.name,
          AppKeys.phone,
          AppKeys.email,
          AppKeys.birthday,
          AppKeys.groups
        ];
      }
      _knownKeys.addAll(_columns);
    });
  }

  Future<void> _saveColumns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _columns);
  }

  Set<String> _getAllAvailableKeys(List<Contact> contacts) {
    Set<String> keys = {};
    for (var contact in contacts) {
      keys.addAll(contact.fields.keys);
    }
    return keys;
  }

  void _syncColumnsWithData(Set<String> allKeys) {
    bool hasChanges = false;

    for (String key in allKeys) {
      if (!_knownKeys.contains(key)) {
        _knownKeys.add(key);
        if (!_columns.contains(key)) {
          _columns.add(key);
        }
        hasChanges = true;
      }
    }

    final Set<String> defaultKeys = {
      AppKeys.name,
      AppKeys.phone,
      AppKeys.email,
      AppKeys.birthday,
      AppKeys.groups
    };

    List<String> keysToRemove = [];
    for (String key in _knownKeys) {
      if (!allKeys.contains(key) && !defaultKeys.contains(key)) {
        keysToRemove.add(key);
      }
    }

    if (keysToRemove.isNotEmpty) {
      for (var key in keysToRemove) {
        _knownKeys.remove(key);
        _columns.remove(key);
      }
      hasChanges = true;
    }

    if (hasChanges) {
      _saveColumns();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  MaterialColor _getGroupColor(String groupName) {
    final List<MaterialColor> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
      Colors.deepOrange
    ];
    return colors[groupName.hashCode.abs() % colors.length];
  }

  double _calculateColumnWidth(String columnName, List<Contact> contacts) {
    if (_columnWidthCache.containsKey(columnName)) {
      return _columnWidthCache[columnName]!;
    }

    final l10n = AppLocalizations.of(context)!;
    double maxWidth = 0.0;
    const textStyle = TextStyle(fontSize: 14);
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    final label = AppKeys.getLocalizedLabel(columnName, l10n);
    _textPainter.maxLines = 1;
    _textPainter.text = TextSpan(text: label, style: headerStyle);
    _textPainter.layout();
    maxWidth = _textPainter.size.width;


    final contactsToCheck = contacts.take(40);

    for (var contact in contactsToCheck) {
      final value = contact.fields[columnName]?.toString() ?? '';
      final isName = columnName == AppKeys.name;

      _textPainter.text =
          TextSpan(text: value, style: isName ? headerStyle : textStyle);
      _textPainter.layout();

      if (_textPainter.size.width > maxWidth) {
        maxWidth = _textPainter.size.width;
      }
    }

    if (columnName == AppKeys.groups) {
      maxWidth += 60.0;
    }

    maxWidth += 40.0; // Increased padding for sort icon and safety

    final maxAllowedWidth = columnName == AppKeys.groups ? 250.0 : 180.0;
    final finalWidth = maxWidth > maxAllowedWidth ? maxAllowedWidth : maxWidth;

    _columnWidthCache[columnName] = finalWidth;
    return finalWidth;
  }

  void _invalidateCache() {
    _columnWidthCache.clear();
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        if (_sortAscending) {
          _sortAscending = false;
        } else {
          _sortColumn = null;
          _sortAscending = true;
        }
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('.');
    if (parts.length != 3) return DateTime(1900);
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void _showColumnSettings(Set<String> allKeys) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ColumnSettingsSheet(
          allKeys: allKeys,
          columns: _columns,
          onReorder: (oldIndex, newIndex) {
            final String item = _columns.removeAt(oldIndex);
            _columns.insert(newIndex, item);
          },
          onRemove: (index) {
            _columns.removeAt(index);
          },
          onAdd: (key) {
            _columns.add(key);
          },
          onSave: () {
            _saveColumns();
            setState(() {});
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
        String value = entry.value?.toString() ?? "";
        if (value.trim().isNotEmpty && !types.containsKey(key)) {
          if (key == AppKeys.name ||
              key == AppKeys.phone ||
              key == AppKeys.email ||
              key == AppKeys.birthday ||
              key == AppKeys.groups) {
            continue;
          }

          types[key] = Validators.inferType(value);
        }
      }
    }
    return types;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>>(
      stream: _contactsStream,
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];
        final allKeys = _getAllAvailableKeys(contacts);
        final existingNames = contacts.map((c) => c.name).toSet();

        Set<String> existingGroups = {};
        for (var c in contacts) {
          final groupStr = c.fields[AppKeys.groups]?.toString();
          if (groupStr != null) {
            existingGroups.addAll(Contact.parseGroups(groupStr));
          }
        }

        _syncColumnsWithData(allKeys);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(AppLocalizations.of(context)!.myContacts),
            actions: [
              if (snapshot.hasData && contacts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.view_column),
                  tooltip: AppLocalizations.of(context)!.configureColumns,
                  onPressed: () => _showColumnSettings(allKeys),
                ),
            ],
          ),
          drawer: const AppDrawer(),
          body: _buildBody(snapshot, contacts, existingNames, existingGroups),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final allFieldTypes = _inferFieldTypes(contacts);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactPage(
                    existingFields: _knownKeys,
                    existingNames: existingNames,
                    existingGroups: existingGroups,
                    existingFieldTypes: allFieldTypes,
                  ),
                ),
              );
              _invalidateCache();
              setState(() {});
            },
            tooltip: 'Додати контакт',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Contact>> snapshot, List<Contact> contacts,
      Set<String> existingNames, Set<String> existingGroups) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
          child: Text('Помилка: ${snapshot.error}',
              style: const TextStyle(color: Colors.red)));
    }

    bool isSearchActive = _searchQuery.isNotEmpty || _selectedGroupFilter != null;

    List<Contact> filteredContacts = contacts.where((contact) {
      if (_selectedGroupFilter != null) {
        final groupStr = contact.fields[AppKeys.groups]?.toString();
        final groups = Contact.parseGroups(groupStr);
        if (!groups.contains(_selectedGroupFilter)) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        bool matchesText = false;

        for (String colName in _columns) {
          final value = contact.fields[colName]?.toString().toLowerCase() ?? '';
          if (value.contains(query)) {
            matchesText = true;
            break;
          }
        }
        if (!matchesText) return false;
      }

      return true;
    }).toList();

    if (_sortColumn != null) {
      filteredContacts.sort((a, b) {
        dynamic valA = a.fields[_sortColumn];
        dynamic valB = b.fields[_sortColumn];

        if (valA == null && valB == null) return 0;
        if (valA == null) return _sortAscending ? 1 : -1;
        if (valB == null) return _sortAscending ? -1 : 1;

        int cmp;
        if (_sortColumn == AppKeys.birthday) {
          try {
            final dateA = _parseDate(valA.toString());
            final dateB = _parseDate(valB.toString());
            cmp = dateA.compareTo(dateB);
          } catch (_) {
            cmp = valA.toString().compareTo(valB.toString());
          }
        } else {
          final strA = valA.toString();
          final strB = valB.toString();

          final numA = double.tryParse(strA);
          final numB = double.tryParse(strB);

          if (numA != null && numB != null) {
            cmp = numA.compareTo(numB);
          } else {
            cmp = strA.toLowerCase().compareTo(strB.toLowerCase());
          }
        }
        return _sortAscending ? cmp : -cmp;
      });
    } else {
      filteredContacts.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    Map<String, double> columnWidths = {};
    for (String colName in _columns) {
      columnWidths[colName] = _calculateColumnWidth(colName, contacts);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchFilterBar(
          searchController: _searchController,
          searchQuery: _searchQuery,
          onSearchChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onClearSearch: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
            FocusScope.of(context).unfocus();
          },
          existingGroups: existingGroups,
          selectedGroupFilter: _selectedGroupFilter,
          onGroupFilterChanged: (group) {
            setState(() {
              _selectedGroupFilter = group;
            });
          },
          getGroupColor: _getGroupColor,
        ),
        Expanded(
          child: ContactTable(
            columns: _columns,
            filteredContacts: filteredContacts,
            allContacts: contacts,
            columnWidths: columnWidths,
            isFilteringActive: isSearchActive,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
            onSort: _onSort,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final contact = filteredContacts.removeAt(oldIndex);
                filteredContacts.insert(newIndex, contact);

                if (_sortColumn != null) {
                  _sortColumn = null;
                  _sortAscending = true;
                }
              });
              _dbService.updateAllContactsOrder(filteredContacts);
            },
            onTap: (contact) async {
              final allFieldTypes = _inferFieldTypes(contacts);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactPage(
                    existingFields: _knownKeys,
                    existingNames: existingNames,
                    existingGroups: existingGroups,
                    existingFieldTypes: allFieldTypes,
                    contact: contact,
                  ),
                ),
              );
              _invalidateCache();
              setState(() {});
            },
            getGroupColor: _getGroupColor,
          ),
        ),
      ],
    );
  }
}