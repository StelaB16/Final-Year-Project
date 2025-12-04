import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';

class EpubViewerScreen extends StatefulWidget {
  final String filePath;

  const EpubViewerScreen({
    super.key,
    required this.filePath,
  });

  @override
  State<EpubViewerScreen> createState() => _EpubViewerScreenState();
}

class _EpubViewerScreenState extends State<EpubViewerScreen> {
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();

    // Read the EPUB file from the local path into bytes
    final bytes = File(widget.filePath).readAsBytesSync();

    // Create the EPUB controller from the bytes
    _epubController = EpubController(
      document: EpubDocument.openData(bytes),
    );
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show the current chapter title in the app bar
        title: EpubViewActualChapter(
          controller: _epubController,
          builder: (chapter) => Text(
            chapter?.chapter?.Title?.replaceAll('\n', '').trim() ??
                'Reading',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      // drawer with table of contents
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubController),
      ),
      body: EpubView(
        controller: _epubController,
        onDocumentError: (error) {
          debugPrint('EPUB load error: $error');
        },
      ),
    );
  }
}
