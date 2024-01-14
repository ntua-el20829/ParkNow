import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:park_now/route_generator.dart';
import 'package:park_now/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

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

  // Initialise notifications and time zones
  NotificationService().initNotification();
  tz.initializeTimeZones();

  // Get current time zone
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

  // Set local location to match the current time zone
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

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
