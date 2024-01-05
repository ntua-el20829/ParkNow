import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ParkingPage extends StatefulWidget {
  const ParkingPage({super.key, required this.parkingId});

  final int parkingId;

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  final storage = FlutterSecureStorage();
  bool isLoading = true;
  List<dynamic> favouriteParkings = [];

  // We are not in a page listed on the navigation bar.
  // Nevertheless, _selectIndex must be initialised.
  // Assign _selectedIndex to 0
  int _selectedIndex = 0;

  @override

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Implement navigation logic depending on the index
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

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 102,
        leading: IconButton(
          icon: Image.asset('assets/images/back_arrow.png'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: /* isLoading
      ? Center(child: CircularProgressIndicator())
      : */ListView(
        children: [

          // Parking Name
      
          Container(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text("Parking Name",
                  style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  color: Colors.white,
                )
              )),
              color: const Color.fromRGBO(153, 140, 230, 1),
            ),

          // Add/remove from favourites
          Row(
          children: [

            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Add/Remove from favourites",
                  style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                )
              )
            ),       
            
            ]
            ),

          Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 25.0, bottom: 2.0),
          child: Text("Number of spots available: 20 out of 100",
                style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                fontSize: 16,
              )
            )
          ),

          Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
          child: Text("Open 24 hours a week",
                style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                fontSize: 16,
              )
            )
          ),

          Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
          child: Text("Per hour pricing: ",
                style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                fontSize: 16,
              )
            )
          ),

            Padding(
              padding:
                  const EdgeInsets.only(top: 80.0, left: 80.0, right: 80.0, bottom: 50.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(153, 140, 230, 1),
                  elevation: 0,
                  minimumSize: const Size(100, 55),
                ),
                onPressed: () {},
                child: const Text("Park Now",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      color: Colors.white,
                    )),
              ),
            ),

          Row (
          children: [

            Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 10.0),
            child: Text("Reviews",
                  style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                )
              )
            ),

            const Spacer(),

            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/add_review', arguments: widget.parkingId);
              },
              icon: Icon(Icons.add_circle_outline_outlined),
              ),

            Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 10.0),
            child: Text("Add a new review",
                  style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: const Color.fromRGBO(153, 140, 230, 1),
                )
              )
            ),

          ]
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

        // We are not in a page listed on the navigation bar,
        // so all items must remain grey
        selectedItemColor: Color.fromRGBO(128,126,128, 1),

        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
    )
    );
  }
}