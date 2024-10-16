import 'dart:convert';

import 'package:finbot/authentication/SignInPage.dart';
import 'package:flutter/material.dart';
import '../models/signup_model.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/my_text_button.dart';
import '../widgets/constraints.dart';
import '../widgets/my_passwordfield.dart';
import '../widgets/my_textfield.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool passwordVisibility = true;

  bool _isLoading = false;
  String? _message;

 

  // Function to handle signup
  Future<void> signUp(String email, String password, String userName, String phoneNumber) async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    const url = 'http://192.168.1.33:8000/auth/signup';

    try {
      print("Tapped 1");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': userName,
          'phone_number': phoneNumber
        }),
      );

      print("Tapped 2");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = json.decode(response.body);
      final signupResponse = SignupResponse.fromJson(responseData);
      ThemeData theme = Theme.of(context);

      // Update message based on the response
      setState(() {
        _message = signupResponse.msg; // This will show "Email already registered" in your UI
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
                signupResponse.isSuccess
                    ? Icon(Icons.check_circle_outline, color: Colors.green, size: 40)
                    : Icon(Icons.close, color: Colors.redAccent, size: 40),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(signupResponse.isSuccess ? "Success" : "Error",
                    style: TextStyle(color: signupResponse.isSuccess ? Colors.green : Colors.redAccent),),
                )
              ],
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(signupResponse.msg, style: TextStyle(fontSize: 20)),
                if (!signupResponse.isSuccess) // Show this message only if not successful
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                      "Please try a different email.",
                      style: TextStyle(fontSize: 16, color: Colors.red), // Red color for error
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              signupResponse.isSuccess
                  ? AppButton(
                color: theme.colorScheme.inversePrimary,
                isFullWidth: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SigninPage()),
                  );
                },
                size: AppButtonSize.large,
                label: "Login",
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              )
                  : TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: aBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },

        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Register",
                            style: aHeadLine,
                          ),
                          Text(
                            "Create new account to get started.",
                            style: aBodyText2,
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          MyTextField(
                            controller: _nameController,
                            hintText: 'Name',
                            inputType: TextInputType.name,
                          ),
                          MyTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            inputType: TextInputType.emailAddress,
                          ),
                          MyTextField(
                            controller: _phoneController,
                            hintText: 'Phone',
                            inputType: TextInputType.phone,
                          ),
                          MyPasswordField(
                            controller: _passwordController,
                            isPasswordVisible: passwordVisibility,
                            onTap: () {
                              setState(() {
                                passwordVisibility = !passwordVisibility;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    // SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: aBodyText,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SigninPage()),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: aBodyText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Spacer(),
                    MyTextButton(
                      buttonName: 'Register',
                      onTap: () {
                        signUp(_emailController.text, _passwordController.text, _nameController.text, _phoneController.text);
                      },
                      bgColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                    SizedBox(height:40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}