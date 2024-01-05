import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class EditInfoScreen extends StatefulWidget {
  const EditInfoScreen({Key? key}) : super(key: key);

  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  int _selectedIndex = 0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _updateInfo() async {
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No token found, please log in.')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final response = await http.put(
      Uri.parse('http://10.0.2.2:5000/edit_info'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User information updated successfully')),
      );
      // Optionally, navigate the user away from the edit screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user information')),
      );
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
        Navigator.of(context).pushReplacementNamed('/favourites');
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
            Navigator.of(context).pushReplacementNamed('/profile');
          },
        ),
        title: SvgPicture.asset(
          'assets/icons/full_logo.svg',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 20.0, top: 60.0),
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: "Username",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a new username';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 20.0, top: 60.0),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: "Password",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a new password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: "Email",
                ),
                validator: (value) {
                  final pattern =
                      r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
                  final regExp = RegExp(pattern);

                  if (value == null || value.isEmpty) {
                    return 'Enter a new email';
                  } else if (!regExp.hasMatch(value)) {
                    return 'Enter a valid new email';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: "Phone Number",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a new phone number';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
                  elevation: 0,
                  minimumSize: const Size(151, 55),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateInfo();
                  }
                },
                child: const Text("Update Information",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
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
