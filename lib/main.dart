import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'favorite.dart';
import 'game_detail_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<int> favoriteGameIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList('favorites');
    if (favorites != null && favorites.isNotEmpty) {
      setState(() {
        favoriteGameIds = favorites.map((id) => int.parse(id)).toList();
      });
    }
  }

  void updateFavorites() {
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Games for You',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(updateFavorites: updateFavorites, favoriteGameIds: favoriteGameIds),
      routes: {
        '/game_detail': (context) => GameDetailView(updateFavorites: updateFavorites),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function updateFavorites;
  final List<int> favoriteGameIds;

  MyHomePage({required this.updateFavorites, required this.favoriteGameIds});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      widget.updateFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(updateFavorites: widget.updateFavorites),
          FavoriteTab(favoriteGameIds: widget.favoriteGameIds),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
