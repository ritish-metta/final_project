import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  const PDFViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = true;
  String? _localPath;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      // Get Firebase Storage reference from the URL
      final ref = _storage.refFromURL(widget.pdfUrl);
      
      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      
      // Download the file using the download URL
      final response = await http.get(Uri.parse(downloadUrl));
      
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/assignment.pdf');
        await file.writeAsBytes(response.bodyBytes);
        
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription PDF'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localPath == null
              ? const Center(child: Text('Error loading PDF'))
              : SfPdfViewer.file(File(_localPath!)),
    );
  }
}