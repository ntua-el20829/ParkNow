import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:park_now/global_server_config.dart';
import 'dart:convert';
import 'package:park_now/main.dart';
import 'package:park_now/screens/camera.dart';
 
class ReservationPage extends StatefulWidget {
  final int parkingId;
  final String initialValue;
  const ReservationPage({Key? key, required this.parkingId, required this.initialValue}) : super(key: key);
 
  @override
  _ReservationPageState createState() => _ReservationPageState();
}
 
class _ReservationPageState extends State<ReservationPage> {
  late CameraController controller;
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  int selectedHours = 1; // Default to 1 hour
  double totalPayment = 5.0; // Default payment for 1 hour
  var licensePlate = TextEditingController();
 
  // We are not in a page listed on the navigation bar.
  // Nevertheless, _selectIndex must be initialised.
  // Assign _selectedIndex to 0
  int _selectedIndex = 0;

  @override
    void initState() {
    super.initState();

    if (widget.initialValue != 'none') {
      licensePlate.text = widget.initialValue;
    }


    // Αρχικοποίηση του ελεγκτή κάμερας [CameraController] για σύνδεση με την
    // πρώτη κάμερα.
    controller = CameraController(cameras[0], ResolutionPreset.max, imageFormatGroup: ImageFormatGroup.yuv420,);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });   
  }
 
 
  Widget _buildSelectTimeButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Hours:',
          style: TextStyle(
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<int>(
              value: selectedHours,
              onChanged: (int? newValue) {
                setState(() {
                  selectedHours = newValue!;
                  // Update total payment based on the selected hours
                  totalPayment = 5.0 * selectedHours.toDouble();
                });
              },
              items: List.generate(24, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text('$index hours'),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
 
  Future<void> _makeReservation() async {
  // Validate input fields
  if (_formKey.currentState!.validate()) {
    try {
      // Fetch authentication token
      String? token = await storage.read(key: "jwt");
      if (token == null) {
        _showSnackBar('No authentication token found.');
        return;
      }
 
      // Make reservation request
      var response = await http.post(
        Uri.parse('http://${server}:${port}/reserve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'license_plate': licensePlate,
          'time_of_departure': DateTime.now()
              .add(Duration(hours: selectedHours))  // Corrected line
              .toIso8601String(),
          'parking_id': widget.parkingId,
        }),
      );
 
      if (response.statusCode == 200) {
        _showSnackBar('Reservation made successfully.');
        // Optionally, you can navigate to another page after a successful reservation
      } else {
        _showSnackBar('Failed to make a reservation.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while making a reservation.');
    }
  }
}
 
 
  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
 
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Implement navigation logic depending on the index
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
            Navigator.of(context).pop(); // Use pop to navigate back
          },
        ),
        title: Center(
          child: SvgPicture.asset(
            'assets/icons/logo.svg', // Replace with your logo image path
            fit: BoxFit.cover,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
      children: [
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSelectTimeButton(),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                controller: licensePlate,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 8) {
                    return 'Please enter your license plate.';
                  }
                  return null;
                },
              ),

              // Κουμπί μετάβασης στην οθόνη της κάμερας
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    '/camera',
                    arguments: CameraScreenWidget(camera: firstCamera, parkingId: widget.parkingId),
                    );
                },
                icon: const Icon(Icons.photo_camera),
              ),

              SizedBox(height: 16.0),
              Text(
                'Total Payment: \$${totalPayment.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
                  elevation: 0,
                  fixedSize: Size(150, 50), // Adjust the width and height as needed
                ),
                onPressed: _makeReservation,
                child: Text(
                  'Reserve',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 18, // Adjust the font size as needed
                    color: Colors.white,
                  ),
                ),
              ),
 
 
            ],
          ),
        ),
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
 
          // We are not in a page listed on the navigation bar,
          // so all items must remain grey
          selectedItemColor: Color.fromRGBO(128, 126, 128, 1),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}