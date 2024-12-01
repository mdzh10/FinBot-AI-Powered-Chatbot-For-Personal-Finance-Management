import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Receipt Response Model
class ReceiptResponse {
  final bool isSuccess;
  final String msg;
  final List<Item> items;

  ReceiptResponse({
    required this.isSuccess,
    required this.msg,
    required this.items,
  });

  factory ReceiptResponse.fromJson(Map<String, dynamic> data) {
    return ReceiptResponse(
      isSuccess: data['isSuccess'],
      msg: data['msg'],
      items: (data['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'msg': msg,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class Item {
  final int id;
  final String itemName;
  final String category;
  final double price;
  final int quantity;

  Item({
    required this.id,
    required this.itemName,
    required this.category,
    required this.price,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> data) {
    return Item(
      id: data['id'],
      itemName: data['item_name'],
      category: data['category'],
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'price': price,
      'quantity': quantity,
    };
  }
}

class ImageCapturePage extends StatefulWidget {
  @override
  _ImageCapturePageState createState() => _ImageCapturePageState();
}

class _ImageCapturePageState extends State<ImageCapturePage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Simulating API call with the selected image and getting receipt data
      ReceiptResponse receiptResponse = await _fetchReceiptData();

      // Pass the receipt data and the image to the next screen (ImageEditPage)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditPage(image: _image!, receipt: receiptResponse),
        ),
      );
    }
  }

  // Simulate fetching receipt data from an API
  Future<ReceiptResponse> _fetchReceiptData() async {
    // Simulate a network delay
    await Future.delayed(Duration(seconds: 2));

    // Simulate API response (this would normally come from a backend or service)
    return ReceiptResponse(
      isSuccess: true,
      msg: "Receipt processed successfully",
      items: [
        Item(id: 1, itemName: "Apple", category: "Fruit", price: 2.5, quantity: 3),
        Item(id: 2, itemName: "Milk", category: "Dairy", price: 1.2, quantity: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture or Upload Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
        ),
      ),
    );
  }
}

class ImageEditPage extends StatefulWidget {
  final File image;
  final ReceiptResponse receipt;

  ImageEditPage({required this.image, required this.receipt});

  @override
  _ImageEditPageState createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage> {
  late List<Item> _editableItems;

  @override
  void initState() {
    super.initState();
    // Initialize the list of items for editing
    _editableItems = widget.receipt.items.map((item) => Item(
      id: item.id,
      itemName: item.itemName,
      category: item.category,
      price: item.price,
      quantity: item.quantity,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Receipt Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.file(widget.image, height: 200),
            SizedBox(height: 20),
            Text(
              widget.receipt.msg,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Receipt Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // Display and edit items
            for (int i = 0; i < _editableItems.length; i++) ...[
              _buildItemEditRow(i),
              SizedBox(height: 10),
            ],
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Save details and go back to capture page
                    Navigator.pop(context, _editableItems);
                  },
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to the capture page
                    Navigator.pop(context);
                  },
                  child: Text('Recapture/Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemEditRow(int index) {
    Item item = _editableItems[index];
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: item.itemName),
            decoration: InputDecoration(labelText: 'Item Name'),
            onChanged: (value) {
              setState(() {
                _editableItems[index] = Item(
                  id: item.id,
                  itemName: value,
                  category: item.category,
                  price: item.price,
                  quantity: item.quantity,
                );
              });
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: item.quantity.toString()),
            decoration: InputDecoration(labelText: 'Quantity'),
            onChanged: (value) {
              setState(() {
                _editableItems[index] = Item(
                  id: item.id,
                  itemName: item.itemName,
                  category: item.category,
                  price: item.price,
                  quantity: int.tryParse(value) ?? item.quantity,
                );
              });
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(text: item.price.toStringAsFixed(2)),
            decoration: InputDecoration(labelText: 'Price'),
            onChanged: (value) {
              setState(() {
                _editableItems[index] = Item(
                  id: item.id,
                  itemName: item.itemName,
                  category: item.category,
                  price: double.tryParse(value) ?? item.price,
                  quantity: item.quantity,
                );
              });
            },
          ),
        ),
      ],
    );
  }
}