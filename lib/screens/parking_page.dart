import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:park_now/global_server_config.dart';
import 'package:park_now/screens/make_reservation.dart';

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
  List<dynamic> reviews = [];
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
      Uri.parse('http://${server}:${port}/parking/${widget.parkingId}'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        parkingDetails = data['parking'];
        reviews = parkingDetails['reviews'] ?? [];
        isFavorite = parkingDetails['isFavorite'] ?? false;
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
    if (token == null) {
      _showSnackBar('Authentication token not found.');
      return;
    }

    var headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json" // Ensure this line is added
    };

    var body = json.encode({'parking_id': widget.parkingId});

    var response = await http.post(
      Uri.parse('http://${server}:${port}/add_to_favourites'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      fetchParkingDetails(); // Refresh parking details
      setState(() {
        isFavorite = !isFavorite; // toggle the state
      });
      _showSnackBar('Added to favorites successfully.');
    } else if (response.statusCode == 409) {
      _showSnackBar('This parking is already in your favorites.');
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
      Navigator.of(context).pushReplacementNamed('/more');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140,
        leading: IconButton(
          icon: Image.asset('assets/images/back_arrow.png'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
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
                 ListTile(
                  leading: Icon(
                    Icons.favorite,
                    color: const Color.fromRGBO(153, 140, 230, 1),
                  ),
                    title: const Text('Add to favorites'),
                    onTap: toggleFavorite,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'Number of spots available: ${parkingDetails['available_spots'] ?? '...'} out of ${parkingDetails['total_spots'] ?? '...'}',
                      style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Fee: ${parkingDetails['fee'] ?? '...'}',
                      style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/add_review',
                          arguments: widget.parkingId);
                    },
                    child: const Text('Add Review'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 80.0, left: 80.0, right: 80.0, bottom: 50.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
                      elevation: 0,
                      minimumSize: const Size(100, 55),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/make_reservation',
                          arguments: ReservationPage(
                              parkingId: widget.parkingId,
                              initialValue: 'none'));
                    },
                    child: const Text("Park Now",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          color: Colors.white,
                        )),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var reviewItem = reviews[index];
                    return ListTile(
                      title: Text(
                          'Rating: ${reviewItem['number_of_stars']} Stars'),
                      subtitle: Text('${reviewItem['review_text']}'),
                    );
                  },
                ),
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
      ),
    );
  }
}
