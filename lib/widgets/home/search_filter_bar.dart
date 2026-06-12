import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final Set<String> existingGroups;
  final String? selectedGroupFilter;
  final ValueChanged<String?> onGroupFilterChanged;
  final Color Function(String) getGroupColor;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.existingGroups,
    required this.selectedGroupFilter,
    required this.onGroupFilterChanged,
    required this.getGroupColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '${l10n.search}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        if (existingGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.all),
                    selected: selectedGroupFilter == null,
                    onSelected: (bool selected) {
                      if (selected) onGroupFilterChanged(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...existingGroups.map((group) {
                    final color = getGroupColor(group);
                    final isSelected = selectedGroupFilter == group;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          group,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: color,
                        backgroundColor: color.withValues(alpha: 0.2),
                        side: BorderSide(color: color.withValues(alpha: 0.5)),
                        onSelected: (bool selected) {
                          onGroupFilterChanged(selected ? group : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}