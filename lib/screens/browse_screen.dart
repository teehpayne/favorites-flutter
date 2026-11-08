import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/book_row.dart';
import '../widgets/city_card.dart';
import '../widgets/hobby_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_header.dart';

enum ContentCategory { cities, hobbies, books }

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  ContentCategory selectedCategory = ContentCategory.cities;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FavoritesProvider>();
    final query = search.text.trim().toLowerCase();
    final List<Widget> items = switch (selectedCategory) {
      ContentCategory.cities =>
        state.cities
            .where((c) => c.cityName.toLowerCase().contains(query))
            .map((c) => CityCard(key: ValueKey('city-${c.id}'), city: c))
            .toList(),
      ContentCategory.hobbies =>
        state.hobbies
            .where((h) => h.hobbyName.toLowerCase().contains(query))
            .map((h) => HobbyRow(key: ValueKey('hobby-${h.id}'), hobby: h))
            .toList(),
      ContentCategory.books =>
        state.books
            .where(
              (b) => ('${b.bookTitle} ${b.bookAuthor}').toLowerCase().contains(
                query,
              ),
            )
            .map((b) => BookRow(key: ValueKey('book-${b.id}'), book: b))
            .toList(),
    };
    return CustomScrollView(
      key: const PageStorageKey('browse'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenHeader(
                  title: 'Find your favorites',
                  subtitle: 'Places, passions, and pages worth keeping.',
                ),
                SegmentedButton<ContentCategory>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ContentCategory.cities,
                      label: Text('Cities'),
                    ),
                    ButtonSegment(
                      value: ContentCategory.hobbies,
                      label: Text('Hobbies'),
                    ),
                    ButtonSegment(
                      value: ContentCategory.books,
                      label: Text('Books'),
                    ),
                  ],
                  selected: {selectedCategory},
                  onSelectionChanged: (value) => setState(() {
                    selectedCategory = value.first;
                    search.clear();
                  }),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search ${selectedCategory.name}',
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(search.clear),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 4,
                  ),
                  child: Text(
                    items.length.toString() +
                        (items.length == 1 ? ' discovery' : ' discoveries'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              title: 'No matches found',
              message: 'Try another name, title, or author.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => items[i],
            ),
          ),
      ],
    );
  }
}
