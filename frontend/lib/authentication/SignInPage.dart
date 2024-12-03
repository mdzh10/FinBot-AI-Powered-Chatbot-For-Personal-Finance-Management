import 'dart:convert';
import 'package:finbot/authentication/Register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../bloc/cubit/app_cubit.dart';
import '../models/login_model.dart';
import '../screens/main.screen.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/my_text_button.dart';
import '../widgets/constraints.dart';
import '../widgets/my_passwordfield.dart';

class SigninPage extends StatefulWidget {
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool passwordVisibility = true;

  bool _isLoading = false;
  String? _message;

  // Helper function to validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  // Function to handle login
  Future<void> login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    const url = 'https://finbot-fastapi-rc4376baha-ue.a.run.app/auth/login'; // Replace with your deployed API URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = json.decode(response.body);
      final loginResponse = LoginResponse.fromJson(responseData);
      ThemeData theme = Theme.of(context);
      AppCubit cubit = context.read<AppCubit>();

      // Update message based on the response
      setState(() {
        _message = loginResponse.msg; // This will show message in your UI
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Row(
              children: [
                loginResponse.isSuccess
                    ? Icon(Icons.check_circle_outline, color: Colors.green, size: 40)
                    : Icon(Icons.close, color: Colors.redAccent, size: 40),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    loginResponse.isSuccess ? "Success" : "Error",
                    style: TextStyle(
                        color: loginResponse.isSuccess ? Colors.green : Colors.redAccent),
                  ),
                )
              ],
            ),
            content: Text(
              loginResponse.msg,
              style: TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              loginResponse.isSuccess
                  ? AppButton(
                color: theme.colorScheme.inversePrimary,
                isFullWidth: true,
                onPressed: () {
                  print(loginResponse.accessToken);
                  cubit.updateAccessToken(loginResponse.accessToken);
                  cubit.updateUserDetails(loginResponse.userName, loginResponse.userId);
                  setState(() {
                    _message = loginResponse.msg;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()), // Navigate to MainScreen
                  );
                },
                size: AppButtonSize.large,
                label: "Ok",
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              )
                  : TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel"),
              )
            ],
          );
        },
      );
    } catch (error) {
      print("Error: $error"); // Log the error for debugging
      setState(() {
        _message = 'Failed to connect to the server';
      });

      // Show error popup
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Connection Error"),
          content: Text("Failed to connect to the server. Please try again later."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Let's Sign you in.",
                    style: aHeadLine,
                  ),
                ),
                SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Welcome back.\nYou've been missed!",
                    style: aBodyText2,
                  ),
                ),
                SizedBox(height: 50.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: _emailController,
                    style: aBodyText.copyWith(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: "Email",
                      hintStyle: aBodyText,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MyPasswordField(
                    controller: _passwordController,
                    isPasswordVisible: passwordVisibility,
                    onTap: () {
                      setState(() {
                        passwordVisibility = !passwordVisibility;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: aBodyText),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        " Register",
                        style: aBodyText.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: MyTextButton(
                    buttonName: "Sign In",
                    onTap: () {
                      // Trim the input to remove unnecessary whitespace
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      // List to hold names of empty fields
                      List<String> emptyFields = [];

                      if (email.isEmpty) emptyFields.add("Email");
                      if (password.isEmpty) emptyFields.add("Password");

                      if (emptyFields.isNotEmpty) {
                        // Create a message listing all empty fields
                        String message = "Please fill in the following fields:\n" +
                            emptyFields.join(", ");

                        // Show popup dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Missing Information"),
                            content: Text(message),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      } else if (!isValidEmail(email)) {
                        // Show invalid email popup dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Invalid Email"),
                            content: Text("Please enter a valid email address."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // All validations passed, proceed to login
                        login(email, password);
                      }
                    },
                    bgColor: Colors.white,
                    textColor: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension method to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}
