import 'package:final_year_project/login.dart';
import 'package:final_year_project/parent_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'child_setup.dart';

class wrapper extends StatefulWidget {
  const wrapper({super.key});

  @override
  State<wrapper> createState() => _wrapperState();
}

class _wrapperState extends State<wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //StreamBuilder keeps listening for user login/logout changes
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Wait for authentication to load
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final User? user = snapshot.data;

            // If no user logged in → go to login
            if (user == null) {
              return const login();
            }

            // User logged in → check if they have any children
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('children')
                  .get(),
              builder: (context, childSnap) {
                if (childSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (childSnap.hasError) {
                  return const Center(child: Text("Error loading data"));
                }

                // No children → go to Child Setup
                if (!childSnap.hasData || childSnap.data!.docs.isEmpty) {
                  return const ChildSetup();
                }

                // Children exist → go to Parent Home Page
                return const ParentHomePage();
              },
            );
          }

       ),
    );
  }
}
