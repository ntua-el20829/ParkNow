import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:park_now/screens/make_reservation.dart';

class CameraScreenWidget extends StatefulWidget {
  const CameraScreenWidget({
    super.key,
    required this.camera,
    required this.parkingId,
  });

  final CameraDescription camera;
  final int parkingId;

  @override
  State<CameraScreenWidget> createState() => _CameraScreenWidgetState();
}

class _CameraScreenWidgetState extends State<CameraScreenWidget> {
  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Δημιουργία ενός στιγμιοτύπου της κλάσης [TextRecognizer]
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Μεταβλητή χειρισμού της κάμερας.
  late CameraController _controller;

  /// Μεταβλητή για τη αρχικοποίηση του [CameraController].
  late Future<void> _initializeControllerFuture;

  /// Μεταβλητή στην οποία αποθηκεύεται το κείμενο που έχει αναγνωριστεί από την
  /// εικόνα. Μπορεί να είναι και null (όταν δεν αναγνωρίζεται κείμενο)
  String? _text;

  /// Αρχικοποίηση στιγμιοτύπου κλάσης
  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  /// Καταστροφή στιγμιοτύπου κλάσης
  @override
  void dispose() {
    _textRecognizer.close();

    _controller.dispose();

    super.dispose();
  }

  /// Μέθοδος που κατασκευάζει το [Widget] της κάμερας
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          Text('$_text'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            final recognizedText = await _textRecognizer
                .processImage(InputImage.fromFilePath(image.path));

            setState(() {
              _text = recognizedText.text;
            });

            Navigator.of(context).pushReplacementNamed('/make_reservation',
                arguments: ReservationPage(
                    parkingId: widget.parkingId, initialValue: '${_text}'));

            if (!mounted) return;
          } catch (e) {
            /// Σε περίπτωση σφάλματος τύπωσε το σφάλμα
            _showSnackBar('An error occured');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
