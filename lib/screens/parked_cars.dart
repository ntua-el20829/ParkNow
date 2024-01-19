import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:park_now/global_server_config.dart';
import 'package:intl/intl.dart';

class ParkedCarsScreen extends StatefulWidget {
  const ParkedCarsScreen({Key? key}) : super(key: key);

  @override
  _ParkedCarsScreenState createState() => _ParkedCarsScreenState();
}

class _ParkedCarsScreenState extends State<ParkedCarsScreen> {
  final storage = FlutterSecureStorage();
  List<dynamic> parkedCars = [];
  bool isLoading = true;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadParkedCars();
  }

  Future<void> _loadParkedCars() async {
    setState(() {
      isLoading = true;
    });

    String? token = await storage.read(key: "jwt");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view parked cars.')),
      );
      return;
    }

    var response = await http.get(
      Uri.parse('http://${server}:${port}/my_parked_cars'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        parkedCars = json.decode(response.body)['parked_cars'];
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load parked cars.')),
      );
    }
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
      // do nothing
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
            Navigator.of(context).pushReplacementNamed('/maps');
          },
        ),
        title: SvgPicture.asset(
          'assets/icons/full_logo.svg',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: parkedCars.length,
              itemBuilder: (context, index) {
                var car = parkedCars[index];
                DateTime dateTime = DateTime.parse(car['time_of_arrival']);
                return ListTile(
                  title: Text('Car with license plate ${car['license_plate']}'),
                  subtitle: Text(
                      'is parked at ${car['parking_name']} since ${DateFormat('dd/MM/yyyy kk:mm:ss').format(dateTime)}'),
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
        onTap: _onItemTapped, // Make sure this is implemented
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
