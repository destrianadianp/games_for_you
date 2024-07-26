import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteTab extends StatefulWidget {
  final List<int> favoriteGameIds;

  FavoriteTab({required this.favoriteGameIds});

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  static const String apiKey = '6308cb48803b465c908e2b0d997a1752';
  static const String baseUrl = 'https://api.rawg.io/api';
  List<dynamic> _favoriteGames = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteGames();
  }

  Future<void> _loadFavoriteGames() async {
    final List<dynamic> loadedFavorites = [];
    for (int id in widget.favoriteGameIds) {
      final response = await http.get(Uri.parse('$baseUrl/games/$id?key=$apiKey'));
      if (response.statusCode == 200) {
        loadedFavorites.add(json.decode(response.body));
      }
    }
    setState(() {
      _favoriteGames = loadedFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Games'),
        backgroundColor: Color.fromARGB(255, 60, 90, 122),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _favoriteGames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_favoriteGames[index]['name']),
            subtitle: Row(
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 20),
                SizedBox(width: 4),
                Text('${_favoriteGames[index]['rating'] ?? 'N/A'}'),
              ],
            ),
            leading: _favoriteGames[index]['background_image'] != null
                ? Image.network(
                    _favoriteGames[index]['background_image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Container(width: 50, height: 50, color: Colors.grey),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/game_detail',
                arguments: _favoriteGames[index]['id'],
              );
            },
          );
        },
      ),
    );
  }
}
