import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  int? userId;
  final storage = FlutterSecureStorage();
  int _selectedIndex = 2;
  bool isLoading = true;
  List<dynamic> nearestParkings = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadNearestParkings(); // Load nearest parkings when the widget is initialized
  }

  void _loadUserId() async {
    String? token = await storage.read(key: "jwt");
    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      setState(() {
        userId = int.tryParse(decodedToken['sub'].toString());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User has not granted access or timed out')));
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _loadNearestParkings() async {
    setState(() {
      isLoading = true;
    });
    String? token = await storage.read(key: "jwt");
    if (token == null || token.isEmpty) {
      _showSnackBar('Authentication token not found.');
      return;
    }

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled.');
        return;
      }

      // Request permission to access location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      var response = await http.post(
        Uri.parse('http://10.0.2.2:5000/nearest_parkings'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: json.encode(
            {'latitude': position.latitude, 'longitude': position.longitude}),
      );

      if (response.statusCode == 200) {
        setState(() {
          nearestParkings = json.decode(response.body)['nearest_parkings'];
          isLoading = false;
        });
      } else {
        _showSnackBar('Failed to load nearest parkings.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to get current location: $e');
      setState(() {
        isLoading = false;
      });
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
    // Example navigation logic (you will need to update this with actual routes)
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/favourites');
        break;
      case 2:
        // do nothing
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
        toolbarHeight: 100,
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userId != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/map_icon.svg',
                      width: 100,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Maps!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nearest Parkings:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: nearestParkings.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                nearestParkings[index]['name'] ?? 'Unknown'),
                            onTap: () {
                              Navigator.of(context).pushNamed('/parking_page',
                                  arguments: nearestParkings[index]['_id']);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
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
