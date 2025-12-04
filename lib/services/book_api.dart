import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:final_year_project/book.dart';

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
  static String _refineInterest(String raw) {
    raw = raw.toLowerCase();

    if (raw.contains("animal")) return "children animal stories";
    if (raw.contains("adventure")) return "children adventure stories";
    if (raw.contains("mystery")) return "children mystery stories";
    if (raw.contains("space")) return "children space stories";
    if (raw.contains("sport")) return "children sports stories";
    if (raw.contains("funny")) return "funny children stories";

    // default fallback
    return "children books";
  }
  static Future<List<Book>> getBooks({
    required String age,
    required String interest,
  }) async {
    try {
      //get list of categories for this age
      final categories = ageCategoryMap[age] ?? ["children"];
      final refinedInterest = _refineInterest(interest);

      //combine interest and age category to create the final search text
      final query = "$refinedInterest ${categories.first}".toLowerCase();

      print("Gutendex primary search query: $query");

      final url = Uri.parse(
        "https://gutendex.com/books/?topic=juvenile&languages=en&search=$query",
      );

      //send the HTTP GET request
      final response = await http.get(url);
      print("Gutendex status code: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("Non-200 response: ${response.body}");
        return [];
      }
      final data = jsonDecode(response.body);
      final List results = data["results"] as List? ?? [];
      print("Gutendex raw results count (primary): ${results.length}");

      var books = results
          .map((item) => Book.fromGutendex(item as Map<String, dynamic>))
          .where((b) => b.epubUrl != null)
          .toList();

      print("Books with EPUB (primary): ${books.length}");

      if (books.isNotEmpty) return books;

      print("No EPUB books found on primary query, trying fallback 'children books'");

      final fallbackUrl = Uri.parse(
        "https://gutendex.com/books/?topic=juvenile&languages=en",
      );
      final fbResponse = await http.get(fallbackUrl);
      print("Fallback status code: ${fbResponse.statusCode}");

      if (fbResponse.statusCode == 200) {
        final fbData = jsonDecode(fbResponse.body);
        final List fbResults = fbData["results"] as List? ?? [];
        print("Gutendex raw results count: ${fbResults.length}");

        books = fbResults
            .map((item) => Book.fromGutendex(item as Map<String, dynamic>))
            .where((b) => b.epubUrl != null)
            .toList();

        print("Books with EPUB : ${books.length}");

      }

      // If fallback call failed, return an emty list
      print("Fallback request failed with status ${fbResponse.statusCode}");
      return [];
    } catch (e) {
      print("Gutendex API error: $e");
      return [];
    }
  }
}

