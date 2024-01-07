import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ParkingPage extends StatefulWidget {
  final int parkingId;

  const ParkingPage({Key? key, required this.parkingId}) : super(key: key);

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  final storage = FlutterSecureStorage();
  bool isLoading = true;
  bool isFavorite = false;
  Map<String, dynamic> parkingDetails = {};
  int _selectedIndex = 2;
  @override
  void initState() {
    super.initState();
    fetchParkingDetails();
  }

  Future<void> fetchParkingDetails() async {
    setState(() {
      isLoading = true;
    });
    String? token = await storage.read(key: "jwt");
    var response = await http.get(
      Uri.parse('http://10.0.2.2:5000/parking/${widget.parkingId}'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        parkingDetails = data['parking'];
        isFavorite = parkingDetails['isFavorite'];
        isLoading = false;
      });
    } else {
      _showSnackBar('Failed to load parking details.');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleFavorite() async {
    String? token = await storage.read(key: "jwt");
    var response = await http.post(
      Uri.parse('http://10.0.2.2:5000/add_to_favourites'),
      headers: {"Authorization": "Bearer $token"},
      body: json.encode({'parking_id': widget.parkingId}),
    );

    if (response.statusCode == 201) {
      fetchParkingDetails(); // Refresh parking details
      _showSnackBar('Toggled favorite successfully.');
    } else {
      _showSnackBar(
          'Failed to toggle favorite. Status Code: ${response.statusCode}');
    }
  }

  void _showSnackBar(String content) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(content)));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Implement navigation logic depending on the index
    // For example:
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/profile');
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/favourites');
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/maps');
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/parked_cars');
    } else if (index == 4) {
      // do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 102,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Parking Details'),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // Parking Name
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                        child: Text(
                      parkingDetails['name'] ?? 'Loading...',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    )),
                    color: const Color.fromRGBO(153, 140, 230, 1),
                  ),

                  // Add/Remove from favourites
                  ListTile(
                    leading: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    title: const Text('Add to favorites'),
                    onTap: toggleFavorite,
                  ),

                  // Display actual values fetched from the backend
                  Text(
                      'Number of spots available: ${parkingDetails['availableSpots'] ?? '...'} out of ${parkingDetails['totalSpots'] ?? '...'}'),
                  // ... Other widgets
                ],
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
        ));
  }
}
