import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hobby_model.dart';
import '../providers/favorites_provider.dart';
import 'favorite_button.dart';

class HobbyRow extends StatelessWidget {
  const HobbyRow({super.key, required this.hobby});
  final HobbyModel hobby;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(hobby.hobbyIcon, style: const TextStyle(fontSize: 28)),
        ),
        title: Text(
          hobby.hobbyName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Make time for what you love'),
        trailing: FavoriteButton(
          name: hobby.hobbyName,
          selected: hobby.isFavorite,
          onPressed: () =>
              context.read<FavoritesProvider>().toggleHobbyFavorite(hobby.id),
        ),
      ),
    ),
  );
}
