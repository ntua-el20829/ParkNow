import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final storage = FlutterSecureStorage();
  List<dynamic> favouriteParkings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _loadFavourites() async {
    setState(() {
      isLoading = true;
    });

    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('No authentication token found.');
      return;
    }

    try {
      var response = await http.get(
        Uri.parse('http://yourbackend.address/favourites'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          favouriteParkings = json.decode(response.body)['favourites'];
          isLoading = false;
        });
      } else {
        _showSnackBar('Failed to load favourites.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while loading favourites.');
    }
  }

  _deleteFavourite(int parkingId) async {
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('No authentication token found.');
      return;
    }

    try {
      var response = await http.delete(
        Uri.parse('http://yourbackend.address/favourites'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({'parking_id': parkingId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          favouriteParkings
              .removeWhere((parking) => parking['id'] == parkingId);
        });
        _showSnackBar('Favourite removed successfully.');
      } else {
        _showSnackBar('Failed to delete favourite.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while deleting favourite.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Parking Spots'),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: favouriteParkings.length,
              itemBuilder: (context, index) {
                var parking = favouriteParkings[index];
                return Card(
                  child: ListTile(
                    title: Text(parking['name']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.purple),
                      onPressed: () {
                        _deleteFavourite(parking['id']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
