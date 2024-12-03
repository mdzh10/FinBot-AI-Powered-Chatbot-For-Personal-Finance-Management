import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class ChatPage extends StatefulWidget {
  final int? userId;

  ChatPage(this.userId , {super.key});  // Default userId is '1'

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _promptController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();



  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    String userPrompt = _promptController.text.trim();
    if (userPrompt.isEmpty) return;

    // Add user message to the chat
    setState(() {
      _messages.add({
        'sender': 'user',
        'type': 'text',
        'content': userPrompt,
      });
      _promptController.clear();
      _isLoading = true;
    });

    String finalPrompt = "user id is ${widget.userId} and $userPrompt";

    Map<String, dynamic> requestBody = {
      "prompt": finalPrompt,
      "showPopup": false,
    };
    print(requestBody.toString());

    try {
      var response = await http.post(
        Uri.parse('https://finbot-fastapi-rc4376baha-ue.a.run.app/report/generate-plots/'),  // Replace with your API endpoint
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      print(response);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['isSuccess']) {
          String chartData = jsonResponse['chart'];

          if (chartData == null || chartData.isEmpty) {
            _showError('Could not process the prompt');
            return;
          }

          // Remove data URL prefix
          final regex = RegExp(r'data:image/[^;]+;base64,');
          chartData = chartData.replaceFirst(regex, '');
          print('Base64 string length: ${chartData.length}');


          Uint8List imageBytes;
          try {
            imageBytes = base64Decode(chartData);
          } catch (e) {
            _showError('Error decoding image data: $e');
            return;
          }

          // Add system message (image) to the chat
          setState(() {
            _messages.add({
              'sender': 'system',
              'type': 'image',
              'content': chartData,
            });
          });
        } else {
          _showError(jsonResponse['msg'] ?? 'Failed to generate image.');
        }
      } else {
        _showError('Sorry, I do not have relevant information, its in beta right now for plot generation. Do you want to generate(income/expense) plot for any specific month/day?');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    // Add error message to the chat
    setState(() {
      _messages.add({
        'sender': 'system',
        'type': 'text',
        'content': message,
      });
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message['sender'] == 'user';
    CrossAxisAlignment crossAxisAlignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    MainAxisAlignment mainAxisAlignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    Color bubbleColor = isUser ? Colors.green.shade400 : Colors.deepPurple;
    TextStyle textStyle = TextStyle(color: isUser ? Colors.white70 : Colors.white70, fontSize: 16);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          if (!isUser) SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: message['type'] == 'text'
                  ? Text(message['content'], style: textStyle)
                  : GestureDetector(
                onTap: () {
                  // Optional: Implement full-screen image view
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    maxHeight: 200,
                  ),
                  child: Image.memory(
                    base64Decode(message['content']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading image', style: textStyle);
                    },
                  ),
                ),
              ),
            ),
          ),
          if (isUser) SizedBox(width: 8),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible =
        MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Text("Generate plots", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Divider(height: 1),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextField(
                      controller: _promptController,
                      maxLines: null, // Allows unlimited lines
                      minLines: 1,    // Starts with one line
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black), // Ensures text is black
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _isLoading ? null : _sendMessage,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}