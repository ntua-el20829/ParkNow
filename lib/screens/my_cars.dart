import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({Key? key}) : super(key: key);

  @override
  _MyCarsScreenState createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final storage = FlutterSecureStorage();
  int _selectedIndex = 0;
  List<dynamic> myCars = [];
  final TextEditingController _licensePlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMyCars();
  }

  Future<void> _loadMyCars() async {
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('Authentication token not found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/my_cars'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          myCars = json.decode(response.body)['vehicles'];
        });
      } else {
        _showSnackBar('Failed to load cars: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('An error occurred while loading cars');
    }
  }

  Future<void> _addNewCar() async {
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('Authentication token not found');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/my_cars'), // Your API endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({'license_plate': _licensePlateController.text}),
      );

      if (response.statusCode == 201) {
        _loadMyCars(); // Reload the cars list
        _showSnackBar('Vehicle registered successfully');
      } else {
        _showSnackBar('Failed to register vehicle: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('An error occurred while registering the vehicle');
    }
  }

  Future<void> _deleteCar(int carId) async {
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('Authentication token not found');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:5000/my_cars'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({'car_id': carId}),
      );

      if (response.statusCode == 200) {
        _loadMyCars();
        _showSnackBar('Vehicle deleted successfully');
      } else {
        _showSnackBar('Failed to delete vehicle: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('An error occurred while deleting the vehicle');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Register a new vehicle'),
          content: TextField(
            controller: _licensePlateController,
            decoration: InputDecoration(hintText: 'Enter license plate'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNewCar();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // do nothing
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/favourites');
    } else if (index == 2) {
      // do nothing
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/profile'),
          ),
          title: SvgPicture.asset(
            'assets/icons/parknow_logo.svg',
            fit: BoxFit.cover,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: ListView.builder(
          itemCount: myCars.length,
          itemBuilder: (context, index) {
            var car = myCars[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text('Vehicle #${index + 1}'),
                subtitle: Text('License plate: ${car['license_plate']}\n'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteCar(car['id']),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCarDialog,
          child: Icon(Icons.add),
          backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
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
