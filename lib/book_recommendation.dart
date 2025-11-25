import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/book_api.dart';

class BookRecommendationScreen extends StatefulWidget {
  final String age;
  final String interest;

  const BookRecommendationScreen({
    super.key,
    required this.age,
    required this.interest,
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
      age: widget.age.toString(),
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
                onPressed: previewLink == null
                    ? null
                    : () => _openLink(previewLink),
              ),
            ),
          );
        },
      ),
    );
  }
}
