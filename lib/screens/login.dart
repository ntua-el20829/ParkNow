import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  var email = TextEditingController();
  var password = TextEditingController();
  final storage = new FlutterSecureStorage();

  void loginUser(String email, String password) async {
    var url = Uri.parse(
        'http://10.0.2.2:5000/login'); // Replace with your API endpoint
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      await storage.write(key: "jwt", value: jsonResponse['access_token']);
      Navigator.of(context).pushReplacementNamed('/maps', arguments: 1);
    } else {
      showMessage('Invalid email or password');
    }
  }

  void showMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 140,
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0, top: 100.0),
                  child: TextFormField(
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter an email';
                      }
                      return null;
                    },
                    controller: email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      labelText: "email",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a password';
                      }
                      return null;
                    },
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      labelText: "Password",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 70.0, bottom: 30.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
                        elevation: 0,
                        minimumSize: const Size(151, 55),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginUser(email.text, password.text);
                        }
                      },
                      child: const Text("Login",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            color: Colors.white,
                          ))),
                ),
              ],
            )));
  }
}
