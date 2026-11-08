import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'browse_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});
  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<FavoritesProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (state.storageError != null)
              MaterialBanner(
                content: Text(state.storageError!),
                actions: [
                  TextButton(
                    onPressed: state.saveFavorites,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: IndexedStack(
                    index: selectedIndex,
                    children: const [
                      BrowseScreen(),
                      FavoritesScreen(),
                      SettingsScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: state.favoriteCount > 0,
              label: Text(state.favoriteCount.toString()),
              child: const Icon(Icons.favorite_outline),
            ),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Favorites',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
