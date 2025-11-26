import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/book_recommendation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:get/get.dart";
import 'package:final_year_project/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Firebase connection to the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Main structure of the app
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Final Year Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const wrapper(),

      routes: {
        "/bookRecommendations": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;

          final String age = args["age"].toString();

          // safely get first interest
          final List interests = args["interests"] ?? [];
          final String interest =
          interests.isNotEmpty ? interests.first.toString() : "children";

          final String childId = args["childId"];

          return BookRecommendationScreen(
            age: age,
            interest: interest,
            childId: childId,
          );
        },
      },


    );
  }
}
//Just used to test firebase connection
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Connection Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Example test: get current user or test Firestore write
            await FirebaseFirestore.instance
                .collection('test')
                .add({'timestamp': DateTime.now()});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Firestore write successful ')),
            );
          },
          child: const Text("Test Firestore Connection"),
        ),
      ),
    );
  }
}
