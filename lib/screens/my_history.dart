import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:park_now/global_server_config.dart';

class ParkingHistoryPage extends StatefulWidget {
  const ParkingHistoryPage({Key? key}) : super(key: key);

  @override
  _ParkingHistoryPageState createState() => _ParkingHistoryPageState();
}

class _ParkingHistoryPageState extends State<ParkingHistoryPage> {
  final storage = FlutterSecureStorage();
  List<Map<String, dynamic>> parkingHistory = [];
  bool isLoading = true;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadParkingHistory();
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _loadParkingHistory() async {
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('No authentication token found.');
      return;
    }

    try {
      var response = await http.get(
        Uri.parse('http://${server}:${port}/my_history'),
        headers: {'Authorization': "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          parkingHistory = List<Map<String, dynamic>>.from(
            json.decode(response.body)['history'],
          );
          isLoading = false;
        });
      } else {
        _showSnackBar('Failed to load parking history.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while loading parking history.');
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '';

    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd/MM/yyyy kk:mm').format(dateTime);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/profile');
          },
        ),
        title: Center(
          child: SvgPicture.asset(
            'assets/icons/logo.svg',
            fit: BoxFit.cover,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: parkingHistory.length,
              itemBuilder: (context, index) {
                var historyItem = parkingHistory[index];
                return Card(
                  child: ListTile(
                    title: Text(historyItem['parking_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'License Plate: ${historyItem['license_plate']}',
                        ),
                        // Text(
                        //   'Total Fee: \$${historyItem['total_fee']}',
                        // ),
                        Text(
                          'Arrival: ${_formatDateTime(historyItem['time_of_arrival'])}',
                        ),
                        Text(
                          'Departure: ${_formatDateTime(historyItem['time_of_departure'])}',
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        historyItem['is_favourite'] > 0
                            ? Icon(Icons.favorite,
                                color: const Color.fromRGBO(153, 140, 230, 1))
                            : SizedBox(), // Display heart icon if in favorites
                        historyItem['number_of_stars'] > 0
                            ? Icon(Icons.star, color: Colors.yellow)
                            : SizedBox(), // Display star icon if reviewed
                      ],
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

        // We are not in a page listed on the navigation bar,
        // so all items must remain grey
        selectedItemColor: Color.fromRGBO(128, 126, 128, 1),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
