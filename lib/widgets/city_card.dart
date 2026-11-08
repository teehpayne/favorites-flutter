import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../providers/favorites_provider.dart';
import 'favorite_button.dart';

class CityCard extends StatelessWidget {
  const CityCard({super.key, required this.city});
  final CityModel city;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/${city.cityImage}.jpeg',
              fit: BoxFit.cover,
              semanticLabel: city.cityName,
              cacheWidth: 1200,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xc0000000)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 72,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PLACES TO LOVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city.cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: FavoriteButton(
                name: city.cityName,
                selected: city.isFavorite,
                onPhoto: true,
                onPressed: () => context
                    .read<FavoritesProvider>()
                    .toggleCityFavorite(city.id),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
