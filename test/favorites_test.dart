import 'package:favorites/main.dart';
import 'package:favorites/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<FavoritesProvider> freshState() async {
  SharedPreferences.setMockInitialValues({});
  return FavoritesProvider(await SharedPreferences.getInstance());
}

Future<void> openApp(WidgetTester tester, FavoritesProvider state) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: const FavoritesApp()),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all categories persist independently with the theme after restart',
    () async {
      final state = await freshState();
      await state.toggleCityFavorite(1);
      await state.toggleHobbyFavorite(1);
      await state.toggleBookFavorite(1);
      await state.setThemeMode(ThemeMode.dark);
      final restored = FavoritesProvider(await SharedPreferences.getInstance());
      expect(restored.favoriteCount, 3);
      expect(restored.cities.first.isFavorite, isTrue);
      expect(restored.hobbies.first.isFavorite, isTrue);
      expect(restored.books.first.isFavorite, isTrue);
      expect(restored.themeMode, ThemeMode.dark);
      await restored.toggleHobbyFavorite(1);
      final again = FavoritesProvider(await SharedPreferences.getInstance());
      expect(again.hobbies.first.isFavorite, isFalse);
      expect(again.cities.first.isFavorite, isTrue);
      expect(again.books.first.isFavorite, isTrue);
    },
  );

  test(
    'rapid mutations and clear persist final state, retaining the theme',
    () async {
      final state = await freshState();
      final writes = [
        state.toggleBookFavorite(1),
        state.toggleBookFavorite(1),
        state.toggleHobbyFavorite(2),
        state.toggleCityFavorite(3),
        state.setThemeMode(ThemeMode.light),
        state.clearFavorites(),
      ];
      await Future.wait(writes);
      final restored = FavoritesProvider(await SharedPreferences.getInstance());
      expect(restored.favoriteCount, 0);
      expect(restored.themeMode, ThemeMode.light);
    },
  );

  test('legacy city favorites load and migrate on the next save', () async {
    SharedPreferences.setMockInitialValues({
      'favoriteCities': ['1', '9', '999'],
    });
    final state = FavoritesProvider(await SharedPreferences.getInstance());
    expect(state.favoriteCount, 2);
    await state.toggleBookFavorite(2);
    final restored = FavoritesProvider(await SharedPreferences.getInstance());
    expect(restored.favoriteCount, 3);
  });

  testWidgets('search filters each category and books by author', (
    tester,
  ) async {
    await openApp(tester, await freshState());
    await tester.enterText(find.byType(TextField), '  CAPE ');
    await tester.pumpAndSettle();
    expect(find.text('Cape Town'), findsOneWidget);
    expect(find.text('Copenhagen'), findsNothing);
    await tester.tap(find.text('Hobbies'));
    await tester.pumpAndSettle();
    expect(find.text('Painting'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'photog');
    await tester.pumpAndSettle();
    expect(find.text('Photography'), findsOneWidget);
    expect(find.text('Painting'), findsNothing);
    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'HARPER');
    await tester.pumpAndSettle();
    expect(find.text('To Kill a Mockingbird'), findsOneWidget);
    expect(find.text('Harper Lee'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no such book');
    await tester.pumpAndSettle();
    expect(find.text('No matches found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save each category, remove on Favorites, sync back to Browse', (
    tester,
  ) async {
    final state = await freshState();
    await openApp(tester, state);
    await tester.tap(find.byTooltip('Favorite Cape Town'));
    await tester.tap(find.text('Hobbies'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favorite Painting'));
    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favorite To Kill a Mockingbird'));
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Cape Town'), findsOneWidget);
    expect(find.text('Painting'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byTooltip('Unfavorite To Kill a Mockingbird'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Harper Lee'), findsOneWidget);
    await tester.tap(find.byTooltip('Unfavorite To Kill a Mockingbird'));
    await tester.pumpAndSettle();
    expect(state.favoriteCount, 2);
    expect(find.text('To Kill a Mockingbird'), findsNothing);
    await tester.tap(find.text('Browse'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favorite To Kill a Mockingbird'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear requires confirmation and updates every category', (
    tester,
  ) async {
    final state = await freshState();
    await state.toggleCityFavorite(1);
    await state.toggleHobbyFavorite(1);
    await state.toggleBookFavorite(1);
    await state.setThemeMode(ThemeMode.dark);
    await openApp(tester, state);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(state.favoriteCount, 3);
    await tester.tap(find.text('Clear Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(state.favoriteCount, 0);
    expect(state.themeMode, ThemeMode.dark);
    final restored = FavoritesProvider(await SharedPreferences.getInstance());
    expect(restored.favoriteCount, 0);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Keep what inspires you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screen and large text remain usable', (tester) async {
    final state = await freshState();
    await openApp(tester, state);
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
