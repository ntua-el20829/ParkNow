import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage();
  int? userId;
  int _selectedIndex = 0; // Assuming Profile is at index 0

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _logout() async {
    await storage.delete(
        key: "jwt"); // Remove the JWT token from secure storage
    Navigator.of(context)
        .pushReplacementNamed('/'); // Navigate to the login screen
  }

  void _loadUserId() async {
    String? token =
        await storage.read(key: "jwt"); // Read the JWT from secure storage
    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token); // Decode the JWT
      setState(() {
        userId = int.tryParse(decodedToken['sub']
            .toString()); // Extract the user ID and ensure it's an integer
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User has not granted access or timed out')));
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Implement navigation logic depending on the index
    // For example:
    if (index == 0) {
      // do nothing
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
        toolbarHeight: 100,
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
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.purple,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: Text(
              '#User : $userId',
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListTile(
            title: Text('My cars'),
            onTap: () {
              // Navigate to My Cars screen
            },
          ),
          ListTile(
            title: Text('Favourite parking spots'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/favourites');
            },
          ),
          ListTile(
            title: Text('History'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/history');
            },
          ),
          ListTile(
            title: Text('My reviews'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/reviews');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Log out'),
            onTap: () {
              // Call the logout function
              _logout();
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
