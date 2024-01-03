import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(

              // center column vertically
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ParkNow full logo
                Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, left: 8.0, right: 8.0, bottom: 100.0),
                    child: SvgPicture.asset(
                      'assets/icons/full_logo.svg',
                      fit: BoxFit.contain,
                    )),

                // Login Button
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                      elevation: 0,
                      minimumSize: const Size(261, 67),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text("Login",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          color: Color.fromRGBO(153, 140, 230, 1),
                        )),
                  ),
                ),

                // Sign Up Button
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
                      elevation: 0,
                      minimumSize: const Size(261, 67),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/sign_up');
                    },
                    child: const Text("Sign Up",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          color: Colors.white,
                        )),
                  ),
                ),
              ]),
        ));
  }
}
