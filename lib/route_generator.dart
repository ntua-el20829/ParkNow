import 'package:flutter/material.dart';
import 'package:park_now/screens/error_page.dart';
import 'package:park_now/screens/launch_page.dart';
import 'package:park_now/screens/login.dart';
import 'package:park_now/screens/maps.dart';
import 'package:park_now/screens/sign_up.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in
    //final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LaunchPage());

      case '/login':
        return MaterialPageRoute(builder: (_) => Login());

      case '/sign_up':
        return MaterialPageRoute(builder: (_) => SignUp());

      case '/maps':
        return MaterialPageRoute(builder: (_) => Maps());
    }

    // In any other case throw an error
    return MaterialPageRoute(builder: (_) => ErrorPage());
  }
}
