import 'dart:convert';
import 'package:http/http.dart' as http;

// Maps each child's age to categories that match publishing standards
Map<String, List<String>> ageCategoryMap = {
  "5": ["picture books", "read aloud", "early reader", "children"],
  "6": ["picture books", "early reader", "children stories", "read aloud"],
  "7": ["early reader", "beginner chapter books", "children fiction"],
  "8": ["chapter books", "middle grade", "junior fiction", "children adventure"],
  "9": ["middle grade", "chapter books", "juvenile fiction", "children mystery"],
  "10": ["middle grade novels", "junior fiction", "children adventure", "juvenile fiction"],
  "11": ["middle grade fiction", "young readers", "pre-teen books", "juvenile adventure"],
  "12": ["middle grade", "young adult beginner", "pre-teen fiction", "junior fantasy"],
};

class BookApi {
  static Future<List<Book>> getBooks({
    required String age,
    required String interest,
  }) async {
    try {
      // 1) Get age categories
      final categories = ageCategoryMap[age] ?? ["children"];

      // 2) Clean interest text
      final cleanInterest = interest.toLowerCase().trim();

      // 3) Build improved query
      final query = "children $cleanInterest books ${categories.first}";

      final url = Uri.parse(
        "https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=20&printType=books",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);

      if (data["items"] == null) {
        return [];
      }

      return (data["items"] as List)
          .map((item) => Book.fromJson(item))
          .toList();
    } catch (e) {
      print("Book API error: $e");
      return [];
    }
  }

}


class Book {
  final String title;
  final String authors;
  final String? thumbnail;
  final String? previewLink;

  Book({
    required this.title,
    required this.authors,
    this.thumbnail,
    this.previewLink,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volume = json["volumeInfo"];

    return Book(
      title: volume["title"] ?? "No title",
      authors: volume["authors"] != null
          ? (volume["authors"] as List).join(", ")
          : "Unknown author",
      thumbnail: volume["imageLinks"]?["thumbnail"],
      previewLink: volume["previewLink"],
    );
  }

  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    return Book(
      title: json["title"] ?? "No title",
      authors: json["author_name"] != null
          ? (json["author_name"] as List).join(", ")
          : "Unknown author",
      thumbnail: json["cover_i"] != null
          ? "https://covers.openlibrary.org/b/id/${json["cover_i"]}-M.jpg"
          : null,
      previewLink: json["key"] != null
          ? "https://openlibrary.org${json["key"]}.pdf"
          : null,
    );
  }
}
