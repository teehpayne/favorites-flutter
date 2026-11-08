import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  Future<void> _confirmClear(BuildContext context) async {
    final state = context.read<FavoritesProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.heart_broken_outlined),
        title: const Text('Clear all favorites?'),
        content: const Text(
          'This removes saved cities, hobbies, and books from this device. Your theme preference will stay the same.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await state.clearFavorites();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.storageError == null
                ? 'All favorites cleared.'
                : 'Favorites cleared here. Retry saving to this device.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FavoritesProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const ScreenHeader(
          title: 'Make it yours',
          subtitle: 'A few preferences for your personal space.',
        ),
        Text('APPEARANCE', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.palette_outlined),
                    SizedBox(width: 12),
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Choose a look. We will remember it next time.'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                      ),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {state.themeMode},
                    onSelectionChanged: (value) =>
                        state.setThemeMode(value.first),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text('SAVED COLLECTION', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite_border),
                    SizedBox(width: 12),
                    Text(
                      'Your favorites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('${state.favoriteCount} favorites saved on this device.'),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: state.favoriteCount == 0
                      ? null
                      : () => _confirmClear(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear Favorites'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.phone_android_outlined),
          title: Text('Made for your everyday favorites'),
          subtitle: Text(
            'Your choices stay on this device. No account needed.',
          ),
        ),
      ],
    );
  }
}
