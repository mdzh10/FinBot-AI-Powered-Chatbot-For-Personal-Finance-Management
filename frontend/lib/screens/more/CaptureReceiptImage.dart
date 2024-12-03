import 'dart:convert';
import 'dart:io';
import 'package:finbot/models/ReceiptResponse.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'ImageEdit.dart';

class ImageCapturePage extends StatefulWidget {
  final int? userId;

  const ImageCapturePage({super.key, this.userId});

  @override
  State<ImageCapturePage> createState() => _ImageCapturePageState();
}

class _ImageCapturePageState extends State<ImageCapturePage> {
  File? _image;
  final picker = ImagePicker();
  final String apiUrl = 'https://finbot-fastapi-rc4376baha-ue.a.run.app/transactions/add';
  bool _isLoading = false; // Track loading state
  ReceiptResponse? _receiptResponse;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Start loading when API call begins
      setState(() {
        _isLoading = true;
      });

      // Simulate API call with the selected image and getting receipt data
      _receiptResponse = await _fetchReceiptData(pickedFile);

      // End loading after receiving response
      setState(() {
        _isLoading = false;
      });

      if (_receiptResponse?.transactions != null && _receiptResponse?.transactions != []) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadImageScreen(
              transactions: _receiptResponse?.transactions ?? [], // Provide empty list if null
              userId: widget.userId,
            ),
          ),
        );
      } else {
        // Show a SnackBar if no transactions are found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No transactions found.'),
            duration: Duration(seconds: 3),
          ),
        );
      }




    }
  }

  Future<ReceiptResponse?> _fetchReceiptData(XFile? image) async {
    final Uri apiUrl = Uri.parse('https://finbot-fastapi-rc4376baha-ue.a.run.app/receipt/extract-items/');  // Replace with your actual API URL

    var request = http.MultipartRequest('POST', apiUrl);

    // Add user_id as a field
    request.fields['user_id'] = widget.userId.toString();

    // Add file as binary data
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final responseData = json.decode(responseString);
        ReceiptResponse receiptResponse = ReceiptResponse.fromJson(responseData);
        print(receiptResponse);
        return receiptResponse;
      } else {
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture or Upload Image',  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // If loading, show CircularProgressIndicator
            if (_isLoading)
              CircularProgressIndicator()
            else ...[
              ElevatedButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text('Capture Image'),
                onPressed: () => _getImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text('Upload Image'),
                onPressed: () => _getImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
