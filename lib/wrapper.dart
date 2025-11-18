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
          builder: (context, snapshot){
            //If the user is logged in go to homepage
            if (snapshot.data == null){
              return const login();
            }

            //if logged in check firebase for child profile
            final user = snapshot.data!;
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
                  return Center(child: Text("Error loading data"));
                }

                //If no children exist, go to setup
                if (!childSnap.hasData || childSnap.data!.docs.isEmpty) {
                  return const ChildSetup();
                }

                //If child exists, go to parent dash board
                return const ParentHomePage();
              },
            );
         }
       ),
    );
  }
}
