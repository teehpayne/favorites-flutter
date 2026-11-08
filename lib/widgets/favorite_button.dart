import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.name,
    required this.selected,
    required this.onPressed,
    this.onPhoto = false,
  });
  final String name;
  final bool selected;
  final VoidCallback onPressed;
  final bool onPhoto;
  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: (selected ? 'Unfavorite ' : 'Favorite ') + name,
    isSelected: selected,
    style: onPhoto
        ? IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xff7160b5),
          )
        : null,
    onPressed: onPressed,
    icon: Icon(selected ? Icons.favorite : Icons.favorite_border),
  );
}
