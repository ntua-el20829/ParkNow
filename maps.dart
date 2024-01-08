import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:park_now/global_server_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  LatLng? userLocation; 

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

      // Set the user's location as LatLng
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });

      var response = await http.post(
        Uri.parse('http://${server}:${port}/nearest_parkings'),
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
        toolbarHeight: 140,
        title: SvgPicture.asset(
          'assets/icons/full_logo.svg',
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
                    Container(
                      height: MediaQuery.of(context).size.height * 0.50, // Adjust the height as needed
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(                         
                          target: userLocation!, 
                          zoom: 13),
                        markers: {
                          Marker(
                            markerId: MarkerId("_currentlocation"),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                            position: userLocation!,
                          ),
                          for (var parking in nearestParkings)
                          Marker(
                            markerId: MarkerId("_parkinglocation_${parking['_id']}"),
                            icon: BitmapDescriptor.defaultMarker,
                            position: LatLng(
                              parking['coordinates'][1],  // Latitude
                              parking['coordinates'][0],  // Longitude
                            ),
                          ),
                        },
                      ),
                    ),
              const SizedBox(height: 10),
                const Text(
                  'Nearest Parkings:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // Use CarouselSlider.builder instead of ListView.builder
                CarouselSlider.builder(
                  itemCount: nearestParkings.length,
                  itemBuilder: (context, index, realIndex) {
                    // Access the coordinates array directly
                    List<dynamic> coordinates = nearestParkings[index]['coordinates'];

                    // Extract latitude and longitude from coordinates
                    double latitude = coordinates[0];
                    double longitude = coordinates[1];
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        // Customize the appearance of the card as needed
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nearestParkings[index]['name'] ?? 'Unknown',
                                style: TextStyle(fontSize: 18), // Adjust the font size as needed
                              ),
                              Text(
                                'Spots Available: ${nearestParkings[index]['capacity'] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              Text(
                                'Fee per hour: ${nearestParkings[index]['fee'] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                                ],
                              ),
                          onTap: () {
                            Navigator.of(context).pushNamed('/parking_page',
                              arguments: nearestParkings[index]['_id'],
                            );
                          },
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 100,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
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
