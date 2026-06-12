import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class ContactsProvider extends ChangeNotifier {
  static const String _prefsKey = 'saved_columns';

  List<String> _columns = [];
  final Set<String> _knownKeys = {};
  
  String _searchQuery = '';
  String? _selectedGroupFilter;
  
  String? _sortColumn;
  bool _sortAscending = true;

  final Map<String, double> _columnWidthCache = {};

  List<String> get columns => _columns;
  Set<String> get knownKeys => _knownKeys;
  String get searchQuery => _searchQuery;
  String? get selectedGroupFilter => _selectedGroupFilter;
  String? get sortColumn => _sortColumn;
  bool get sortAscending => _sortAscending;

  ContactsProvider() {
    _loadColumns();
  }

  Future<void> _loadColumns() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColumns = prefs.getStringList(_prefsKey);

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
    notifyListeners();
  }

  Future<void> saveColumns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _columns);
  }

  void updateColumns(List<String> newColumns) {
    _columns = newColumns;
    saveColumns();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setGroupFilter(String? group) {
    _selectedGroupFilter = group;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void toggleSort(String column) {
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
    notifyListeners();
  }

  void invalidateCache() {
    _columnWidthCache.clear();
  }

  Set<String> getAllAvailableKeys(List<Contact> contacts) {
    Set<String> keys = {};
    for (var contact in contacts) {
      keys.addAll(contact.fields.keys);
    }
    return keys;
  }

  void syncColumnsWithData(List<Contact> contacts) {
    final allKeys = getAllAvailableKeys(contacts);
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
      saveColumns();
      notifyListeners();
    }
  }

  List<Contact> getFilteredAndSortedContacts(List<Contact> contacts) {
    List<Contact> filtered = contacts.where((contact) {
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
      filtered.sort((a, b) {
        dynamic valA = a.fields[_sortColumn];
        dynamic valB = b.fields[_sortColumn];

        if (valA == null && valB == null) return 0;
        if (valA == null) return _sortAscending ? 1 : -1;
        if (valB == null) return _sortAscending ? -1 : 1;

        int cmp;
        if (_sortColumn == AppKeys.birthday) {
          try {
            // Updated Date parsing to use intl if possible, else fallback
            final format = DateFormat('dd.MM.yyyy');
            final dateA = format.parseStrict(valA.toString());
            final dateB = format.parseStrict(valB.toString());
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
      filtered.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    return filtered;
  }

  double calculateColumnWidth(String columnName, List<Contact> contacts, BuildContext context, TextPainter textPainter) {
    if (_columnWidthCache.containsKey(columnName)) {
      return _columnWidthCache[columnName]!;
    }

    final l10n = AppLocalizations.of(context)!;
    double maxWidth = 0.0;
    const textStyle = TextStyle(fontSize: 14);
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    final label = AppKeys.getLocalizedLabel(columnName, l10n);
    textPainter.maxLines = 1;
    textPainter.text = TextSpan(text: label, style: headerStyle);
    textPainter.layout();
    maxWidth = textPainter.size.width;

    final contactsToCheck = contacts.take(40);

    for (var contact in contactsToCheck) {
      final value = contact.fields[columnName]?.toString() ?? '';
      final isName = columnName == AppKeys.name;

      textPainter.text = TextSpan(text: value, style: isName ? headerStyle : textStyle);
      textPainter.layout();

      if (textPainter.size.width > maxWidth) {
        maxWidth = textPainter.size.width;
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
}
