import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameDetailView extends StatefulWidget {
  final Function updateFavorites;

  GameDetailView({required this.updateFavorites});

  @override
  _GameDetailViewState createState() => _GameDetailViewState();
}

class _GameDetailViewState extends State<GameDetailView> {
  bool _isFavorite = false;
  late int _gameId;
  late Future<Map<String, dynamic>> _gameDetail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameId = ModalRoute.of(context)!.settings.arguments as int;
    _gameDetail = _fetchGameDetail(_gameId);
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _isFavorite = favorites.contains(_gameId.toString());
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    if (_isFavorite) {
      favorites.remove(_gameId.toString());
    } else {
      favorites.add(_gameId.toString());
    }

    await prefs.setStringList('favorites', favorites);
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.updateFavorites(); 
  }

  Future<Map<String, dynamic>> _fetchGameDetail(int id) async {
    final url = 'https://api.rawg.io/api/games/$id?key=6308cb48803b465c908e2b0d997a1752';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load game details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _gameDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Game Detail'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Game Detail'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          final game = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(game['name']),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
  padding: const EdgeInsets.all(8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      game['background_image'] != null
          ? Image.network(game['background_image'])
          : Container(
              height: 200,
              color: Colors.grey,
            ),
      SizedBox(height: 8.0),
      Text(
        game['name'],
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8.0),
      Text('Release Date: ${game['released'] ?? 'N/A'}'),
      SizedBox(height: 8.0),
      Row(
        children: [
          Icon(Icons.star, color: Colors.yellow, size: 20),
          SizedBox(width: 4.0), 
          Text(
            '${game['rating'] ?? 'N/A'}',
            style: TextStyle(fontSize: 16), 
          ),
        ],
      ),
      SizedBox(height: 8.0),
      Text('Description:'),
      Text(game['description_raw'] ?? 'No description available'),
    ],
  ),
),

            ),
          );
        }
      },
    );
  }
}
