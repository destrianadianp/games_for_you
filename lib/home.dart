import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeTab extends StatefulWidget {
  final Function updateFavorites;

  HomeTab({required this.updateFavorites});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const String apiKey = '6308cb48803b465c908e2b0d997a1752';
  static const String baseUrl = 'https://api.rawg.io/api';

  TextEditingController _searchController = TextEditingController();
  List<dynamic> _games = [];
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames([String query = '']) async {
    final url = Uri.parse('$baseUrl/games?key=$apiKey&page=$_currentPage&search=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _games = json.decode(response.body)['results'];
      });
    }
  }

  void _performSearch() {
    _fetchGames(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games for You'),
        backgroundColor: Color.fromARGB(255, 60, 90, 122),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_games[index]['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Release Date: ${_games[index]['released'] ?? 'N/A'}'),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 20),
                          SizedBox(width: 4),
                          Text('${_games[index]['rating'] ?? 'N/A'}'),
                        ],
                      ),
                    ],
                  ),
                  leading: _games[index]['background_image'] != null
                      ? Image.network(
                          _games[index]['background_image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(width: 50, height: 50, color: Colors.grey),
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/game_detail',
                      arguments: _games[index]['id'],
                    );
                    widget.updateFavorites();
                  },
                );
              },
            ),
          ),
          if (_games.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage > 1) {
                        setState(() {
                          _currentPage--;
                        });
                        _fetchGames(_searchController.text);
                      }
                    },
                    child: Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPage++;
                      });
                      _fetchGames(_searchController.text);
                    },
                    child: Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
