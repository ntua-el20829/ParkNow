import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:park_now/global_server_config.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  var username = TextEditingController();
  var password = TextEditingController();
  var email = TextEditingController();
  var phone_number = TextEditingController();
  String _baseUrl =
      "http://${server}:${port}/signup"; // Change this to your actual server IP and port

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      var response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'username': username.text,
          'email': email.text,
          'password': password.text,
          'phone_number': phone_number.text,
        }),
      );
      print(
          'Response status: ${response.statusCode}'); // Debug: Check the response status
      print(
          'Response body: ${response.body}'); // Debug: Check the response body
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User successfully created')));
        Navigator.of(context).pushReplacementNamed('/');
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User already exists')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create user')));
      }
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
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        title: SvgPicture.asset(
          'assets/icons/full_logo.svg',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Username Field
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 20.0, top: 60.0),
              child: TextFormField(
                controller: username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: "Username",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a username';
                  }
                  return null;
                },
              ),
            ),

            // Email Field
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TextFormField(
                controller: email,
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
                    return 'Enter an email';
                  } else if (!regExp.hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ),

            // Password Field
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TextFormField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: "Password",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a password';
                  }
                  return null;
                },
              ),
            ),

            // Phone Number Field
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TextFormField(
                controller: phone_number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: "Phone Number",
                ),
                validator: (value) {
                  final pattern = r'(^[0-9]+$)';
                  final regExp = RegExp(pattern);

                  if (value == null || value.isEmpty) {
                    return 'Enter your phone number';
                  } else if (!regExp.hasMatch(value) || value.length != 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),

            // Sign Up Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
                  elevation: 0,
                  minimumSize: const Size(151, 55),
                ),
                onPressed: _signUp,
                child: const Text("Sign Up",
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
    );
  }
}
