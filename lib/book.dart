class Book {
  final String title;
  final String authors;
  final String? thumbnail;
  final String? epubUrl;

  Book({
    required this.title,
    required this.authors,
    this.thumbnail,
    this.epubUrl,
  });

  // Create a Book from the Gutendex JSON structure
  factory Book.fromGutendex(Map<String, dynamic> json) {
    final Map<String, dynamic> formats =
        (json["formats"] as Map?)?.cast<String, dynamic>() ?? {};

    String? epub;

    formats.forEach((key, value) {
      if (key.toString().startsWith("application/epub+zip")) {
        epub ??= value as String;
      }
    });

    return Book(
      title: json["title"] ?? "No title",
      authors: json["authors"] != null
          ? (json["authors"] as List).map((a) => a["name"]).join(", ")
          : "Unknown author",
      thumbnail: formats["image/jpeg"],
      epubUrl: epub,
    );
  }
}
