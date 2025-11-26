import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadService {

  static Future<String?> downloadPdf(String url, String bookId) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return null;

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/my_books/$bookId.pdf";

      final fileDir = Directory("${directory.path}/my_books");
      if (!fileDir.existsSync()) {
        fileDir.createSync(recursive: true);
      }

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      print("PDF download error: $e");
      return null;
    }
  }
}
