import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Maps extends StatefulWidget {
  const Maps({super.key, required int user_id});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final storage = new FlutterSecureStorage();
  int? userId; // This will hold the extracted user ID

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load the user ID when the widget is initialized
  }

  // This function reads the JWT from secure storage, decodes it, and extracts the user ID
  _loadUserId() async {
    String? token =
        await storage.read(key: "jwt"); // Read the JWT from secure storage
    if (token != null) {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token); // Decode the JWT
      setState(() {
        userId = int.tryParse(decodedToken['id']
            .toString()); // Extract the user ID and ensure it's an integer
      });
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
      // Display the user ID if it's not null; otherwise, show a loading message
      body: Center(
        child: Text(userId != null
            ? 'This is the Maps page. User ID: $userId'
            : 'Loading...'),
      ),
    );
  }
}
