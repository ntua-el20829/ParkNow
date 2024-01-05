import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddReview extends StatefulWidget {
  const AddReview({super.key, required this.parkingId});

  final int parkingId;

  @override
  State<AddReview> createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  /* validator για τον έλεγχο των πεδίων */
  var reviewTextController = TextEditingController();
  /* validator για τον έλεγχο των πεδίων */
  var numStarsController = TextEditingController();

  final storage = FlutterSecureStorage();

  // We are not in a page listed on the navigation bar.
  // Nevertheless, _selectIndex must be initialised.
  // Assign _selectedIndex to 0
  int _selectedIndex = 0;

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _addReview() async {

    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('No authentication token found.');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:5000/my_reviews'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
         body: json.encode({
          'review_text': reviewTextController.text,
          'number_of_stars': numStarsController.text,
          'parking_id': widget.parkingId,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Review added successfully.');
      } else {
        _showSnackBar('Failed to add review.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while adding review.');
    }
  }

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

  // Καταστροφή στιγμιοτύπου κλάσης
  @override
  void dispose() {
    // Απελευθέρωση των πόρων που δέσμευσαν οι [TextEditingController]
    reviewTextController.dispose();
    numStarsController.dispose();
    // Τέλος, καλούμε την dispose της υπερκλάσης
    super.dispose();
  }

  @override
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

        body: ListView(
        children: [

          
          Container(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text("Add a new review",
                  style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  color: Colors.white,
                )
              )),
              color: const Color.fromRGBO(153, 140, 230, 1),
            ),


        // Review Form

        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Star rating
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    final pattern = r'(^[0-5]+$)';
                    final regExp = RegExp(pattern);

                    if (value == null || value.isEmpty) {
                      return 'Enter number of stars';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Enter a valid number';
                    }
                    return null;
                },
                  controller: numStarsController,
                  decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  hintText: "Number of stars out of 5",
                ),
                ),
              ),

              const SizedBox(width: 20, height: 20),

              // Review text
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 8,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a username';
                  }
                  return null;
                },
                  controller: reviewTextController,
                  decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  hintText: "Add your review",
                ),
              ),
              ),

              const SizedBox(width: 20, height: 20),

              Row(
                children: [

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  Padding(padding: const EdgeInsets.all(10)),
                  ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        _addReview();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
        ]
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