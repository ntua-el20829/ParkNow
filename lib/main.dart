import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:park_now/route_generator.dart';

// Λίστα στην οποία πρόκειται να προστεθούν οι διαθέσιμες κάμερες.
late List<CameraDescription> cameras;

// Μεταβλητή στην οποία θα αποθηκευτεί η κάμερα που θα επιλέξουμε
late CameraDescription firstCamera;

Future<void> main() async {
  // Προκειμένου να πάρουμε μια λίστα με τις διαθέσιμες κάμερες της συσκευής
  // πρέπει να βεβαιωθούμε ότι όλες οι υπηρεσίες των προσθέτων που χρησιμο-
  // ποιούμε (plugins) έχουν αρχικοποιηθεί πριν καλέσουμε την runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Λήψη λίστας με τις διαθέσιμες κάμερες της συσκευής
  cameras = await availableCameras();

  // Από τη λίστα που έχει επιστραφεί, παίρνουμε την πρώτη κάμερα
  firstCamera = cameras.first;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkNow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(153, 140, 230, 1)),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
