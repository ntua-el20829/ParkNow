import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyReviews extends StatefulWidget {
  const MyReviews({super.key});

  @override
  State<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  final storage = FlutterSecureStorage();
  List<dynamic> myReviews = [];
  bool isLoading = true;

  // We are not in a page listed on the navigation bar.
  // Nevertheless, _selectIndex must be initialised.
  // Assign _selectedIndex to 0
  int _selectedIndex = 0;

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

  void initState() {
    super.initState();
    _loadReviews();
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _loadReviews() async {
    setState(() {
      isLoading = true;
    });

    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('No authentication token found.');
      return;
    }

    try {
      var response = await http.get(
        Uri.parse('http://10.0.2.2:5000/my_reviews'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          myReviews = json.decode(response.body)['reviews'];
          isLoading = false;
        });
      } else {
        _showSnackBar('Failed to load reviews.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while loading reviews.');
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: myReviews.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0,),
                  child: Column (
                    children: [
                      
                      Divider(),

                      Row(
                        children: [
                        Text(
                        'parking_${myReviews[index]['parking_id']}',
                        style: TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        ),
                       ),


                        const Spacer(),

                        Text('${myReviews[index]['number_of_stars']}',
                        style: TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        )
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.star, color: Colors.yellow),
                       )
                        ],
                        ),

                        Text(
                        '${myReviews[index]['review_text']}',
                        style: TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        ),
                       ),
                    ],
                    )
                  );
              },
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