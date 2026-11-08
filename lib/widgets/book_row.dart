import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/favorites_provider.dart';
import 'favorite_button.dart';

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});
  final BookModel book;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 48,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                width: 5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: Icon(
            Icons.auto_stories_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          book.bookTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(book.bookAuthor),
        trailing: FavoriteButton(
          name: book.bookTitle,
          selected: book.isFavorite,
          onPressed: () =>
              context.read<FavoritesProvider>().toggleBookFavorite(book.id),
        ),
      ),
    ),
  );
}
