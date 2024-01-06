import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:park_now/global_server_config.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final storage = FlutterSecureStorage();
  List<dynamic> favouriteParkings = [];
  bool isLoading = true;
  int _selectedIndex = 1; // Assuming Favorites is at index 1

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
        Uri.parse('http://${server}:${port}/favourites'),
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
        Uri.parse('http://${server}:${port}/favourites'),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Implement navigation logic depending on the index
    // Example navigation logic (you will need to update this with actual routes)
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
      case 1:
        // Current tab is Favorites, so we do not need to navigate
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/maps');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/parked_cars');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140,
        leading: IconButton(
          icon: Image.asset('assets/images/back_arrow.png'),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/maps');
          },
        ),
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                      icon:
                          Icon(Icons.heart_broken_sharp, color: Colors.purple),
                      onPressed: () {
                        _deleteFavourite(parking['id']);
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            label: 'Parked Cars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
