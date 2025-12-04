import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadService {

  // download a file from "url"
  static Future<String?> downloadEpub(String url, String filename) async {
    try {
      // Send a GET request to download the file bytes from the internet.
      final response = await http.get(Uri.parse(url));
      print("EPUB Download status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("Download failed: ${response.body.substring(0, 200)}");
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();

      // Make filename safe for filesystem
      final safeFileName = filename.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final filePath = "${directory.path}/$safeFileName.epub";
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print("Saved EPUB to: $filePath");
      return filePath;
    } catch (e) {
      print("EPUB download failed: $e");
      return null;
    }
  }




}
