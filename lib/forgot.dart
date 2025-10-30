import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {

  TextEditingController email=TextEditingController();

//Sends reset email through firebase
  reset()async{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Forgot Password",
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        centerTitle: true,
      ),
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Text(
                          "Reset Password",
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We will send you a reset link to your email address!",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),


                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: reset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            "Send Reset Link",
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),

                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            "Back to Login",
                            style: GoogleFonts.poppins(
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
            ),
        ),
    );
  }
}
