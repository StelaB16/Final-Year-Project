import 'package:final_year_project/homepage.dart';
import 'package:final_year_project/login.dart';
import 'package:final_year_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            if (snapshot.hasData){
              return homepage();
            }else{
              //if not logged in go to login page
              return login();
            }
          }),
    );
  }
}
