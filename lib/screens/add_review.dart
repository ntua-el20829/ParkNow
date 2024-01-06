import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:park_now/global_server_config.dart';

class AddReview extends StatefulWidget {
  final int parkingId;
  const AddReview({Key? key, required this.parkingId}) : super(key: key);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController reviewTextController = TextEditingController();
  final TextEditingController numStarsController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> _addReview() async {
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      _showSnackBar('Authentication token not found.');
      return;
    }

    var response = await http.post(
      Uri.parse(
          'http://${server}:${port}/my_reviews'), // Replace with your actual domain
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        'review_text': reviewTextController.text,
        'number_of_stars': int.parse(numStarsController.text),
        'parking_id': widget.parkingId,
      }),
    );

    if (response.statusCode == 201) {
      _showSnackBar('Review added successfully.');
      Navigator.pop(context);
    } else {
      _showSnackBar(
          'Failed to add review. Status Code: ${response.statusCode}');
    }
  }

  void _showSnackBar(String content) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(content)));
  }

  @override
  void dispose() {
    reviewTextController.dispose();
    numStarsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: reviewTextController,
                decoration: InputDecoration(hintText: 'Enter your review'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: numStarsController,
                decoration: InputDecoration(hintText: 'Number of stars (1-5)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a star rating.';
                  }
                  if (int.tryParse(value) == null ||
                      int.parse(value) < 1 ||
                      int.parse(value) > 5) {
                    return 'Please enter a valid number between 1 and 5.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addReview();
                  }
                },
                child: Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
