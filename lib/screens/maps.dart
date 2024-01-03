import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  int? userId;
  final storage =
      new FlutterSecureStorage(); // Ensure you have an instance of FlutterSecureStorage

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load the user ID when the widget is initialized
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
      print(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User has not granted access or timed out')));
      Navigator.of(context).pushReplacementNamed('/');
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
      body: Center(
        child: userId != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/map_icon.svg', // Replace with your map icon asset
                    width: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to Maps!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User ID: $userId',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              )
            : CircularProgressIndicator(), // Show a loading indicator while waiting
      ),
    );
  }
}
