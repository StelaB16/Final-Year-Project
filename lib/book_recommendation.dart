import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/services/Download_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/book_api.dart';

class BookRecommendationScreen extends StatefulWidget {
  final String age;
  final String interest;
  final String childId;

  const BookRecommendationScreen({
    super.key,
    required this.age,
    required this.interest,
    required this.childId,
  });

  @override
  State<BookRecommendationScreen> createState() =>
      _BookRecommendationScreenState();
}

class _BookRecommendationScreenState
    extends State<BookRecommendationScreen> {
  List<dynamic> books = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final results = await BookApi.getBooks(
      age: widget.age,
      interest: widget.interest,
    );

    setState(() {
      books = results;
      loading = false;
    });
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> saveBookToFirebase(Book book, String? filePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final parentId = user.uid;
    final childId = widget.childId;

    // create unique book ID based on timestamp
    final bookId = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('myBooks')
        .doc(bookId);

    await ref.set({
      'title': book.title,
      'authors': book.authors,
      'thumbnail': book.thumbnail,
      'previewLink': book.previewLink,
      'filePath': filePath,      // ✔ matches MyBooksScreen
      'bookId': bookId,
      'downloadedAt': FieldValue.serverTimestamp(),
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Books")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
          ? const Center(child: Text("No books found"))
          : ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];

          final title = book.title;
          final author = book.authors;
          final thumbnail = book.thumbnail;
          final previewLink = book.previewLink;

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: thumbnail != null
                  ? Image.network(thumbnail, fit: BoxFit.cover)
                  : Container(
                width: 50,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.book),
              ),
              title: Text(title),
              subtitle: Text(author),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  try {
                    final bookId = "${book.title}_${DateTime
                        .now()
                        .millisecondsSinceEpoch}";
                    final filePath = book.previewLink != null
                        ? await DownloadService.downloadPdf(book.previewLink!,
                        bookId)
                        : null;

                    await saveBookToFirebase(book, filePath);
                  }catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Book added to My Books")),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
