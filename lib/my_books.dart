import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'epub_viewer_screen.dart';

class MyBooksScreen extends StatelessWidget {
  final String childId;

  const MyBooksScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    //get current logged in user
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Books"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("children")
            .doc(childId)
            .collection("myBooks")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No downloaded books yet"));
          }

          //get the list of book doc
          final books = snapshot.data!.docs;

          if (books.isEmpty) {
            return const Center(child: Text("No downloaded books yet"));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final data = books[index].data() as Map<String, dynamic>;
              final title = data["title"];
              final authorData = data["authors"];
              final author = (authorData is List) ? authorData.join(", ") : authorData;
              final localPath = data["filePath"];

              return ListTile(
                title: Text(title ?? "Unknown title"),
                subtitle: Text(author ?? "Unknown author"),
                trailing: const Icon(Icons.menu_book),
                onTap: () async {
                  if (localPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("This book has no local file.")),
                    );
                    return;
                  }

                  final file = File(localPath);
                  if (!file.existsSync()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("File missing")),
                    );
                    return;
                  }

                  // Open the EPUB reader screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EpubViewerScreen(filePath: localPath),
                    ),
                  );
                },


              );
            },
          );

        },
      ),
    );
  }
}
