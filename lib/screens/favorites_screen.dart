import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/book_row.dart';
import '../widgets/city_card.dart';
import '../widgets/hobby_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_header.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<FavoritesProvider>();
    final cities = state.cities.where((c) => c.isFavorite).toList();
    final hobbies = state.hobbies.where((h) => h.isFavorite).toList();
    final books = state.books.where((b) => b.isFavorite).toList();
    final content = <Widget>[
      ScreenHeader(
        title: 'Your favorites',
        subtitle:
            '${state.favoriteCount} saved favorites. A little collection of you.',
      ),
      if (state.favoriteCount == 0)
        const EmptyState(
          title: 'Keep what inspires you',
          message:
              'Tap a heart in Browse to save cities, hobbies, and books here.',
          icon: Icons.favorite_border,
        ),
      if (cities.isNotEmpty) ...[
        _heading(context, 'Cities', cities.length),
        ...cities.map(
          (c) => CityCard(key: ValueKey('saved-city-${c.id}'), city: c),
        ),
      ],
      if (hobbies.isNotEmpty) ...[
        _heading(context, 'Hobbies', hobbies.length),
        ...hobbies.map(
          (h) => HobbyRow(key: ValueKey('saved-hobby-${h.id}'), hobby: h),
        ),
      ],
      if (books.isNotEmpty) ...[
        _heading(context, 'Books', books.length),
        ...books.map(
          (b) => BookRow(key: ValueKey('saved-book-${b.id}'), book: b),
        ),
      ],
    ];
    return ListView.builder(
      key: const PageStorageKey('favorites'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: content.length,
      itemBuilder: (_, i) => content[i],
    );
  }

  Widget _heading(BuildContext context, String name, int count) => Padding(
    padding: const EdgeInsets.only(left: 4, top: 8, bottom: 14),
    child: Text(
      '$name · $count',
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}
