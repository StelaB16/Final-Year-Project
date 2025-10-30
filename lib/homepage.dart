import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
//Get the current logged in user
  final user=FirebaseAuth.instance.currentUser;

  //Function to sign up
  signout()async{
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Homepage"),),
      body: Center(
        child: Text('${user!.email}'),
      ), //center
      floatingActionButton: FloatingActionButton(
          onPressed: (()=>signout()),
          child: Icon(Icons.login_rounded),
    ),
    );
  }
}
