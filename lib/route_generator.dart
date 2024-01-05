import 'package:flutter/material.dart';
import 'package:park_now/screens/edit_info.dart';
import 'package:park_now/screens/error_page.dart';
import 'package:park_now/screens/favourites.dart';
import 'package:park_now/screens/launch_page.dart';
import 'package:park_now/screens/login.dart';
import 'package:park_now/screens/maps.dart';
import 'package:park_now/screens/more.dart';
import 'package:park_now/screens/my_cars.dart';
import 'package:park_now/screens/profile.dart';
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

      case '/favourites':
        return MaterialPageRoute(builder: (_) => FavouritesScreen());

      case '/more':
        return MaterialPageRoute(builder: (_) => MoreScreen());

      case '/parked_cars':
      //  return MaterialPageRoute(builder: (_) => ParkedCarsScreen());

      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      case '/edit_info':
        return MaterialPageRoute(builder: (_) => EditInfoScreen());

      case '/my_cars':
        return MaterialPageRoute(builder: (_) => MyCarsScreen());
    }

    // In any other case throw an error
    return MaterialPageRoute(builder: (_) => ErrorPage());
  }
}
