import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:park_now/global_server_config.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final storage = FlutterSecureStorage();
  int _selectedIndex = 4;

  Future<void> _deleteAccount() async {
    String? token = await storage.read(key: "jwt");

    if (token == null) {
      _showSnackBar('Authentication token not found.');
      return;
    }

    final response = await http.delete(
      Uri.parse('http://${server}:${port}/delete_account'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      _showSnackBar('Account deleted successfully.');
      // Handle user account deletion (e.g., navigate to a login or home screen)
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      _showSnackBar('Failed to delete account. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'If you have any questions please contact us: contact@mail.com',
                    style: TextStyle(fontSize: 16, color: Colors.purple),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60, // Adjust the bottom position as needed
            child: Center(
              child: TextButton(
                onPressed: _deleteAccount,
                child: Text(
                  'Delete your account',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
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
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
