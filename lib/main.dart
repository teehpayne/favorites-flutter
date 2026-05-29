import 'package:flutter/material.dart';

void main() {
  runApp(const FavoritesApp());
}

class FavoritesApp extends StatelessWidget {
  const FavoritesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(),
    );
  }
}