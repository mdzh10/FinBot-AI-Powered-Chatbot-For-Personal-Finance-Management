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

  Future<void> login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    const url = 'http://192.168.1.33:8000/auth/login';  // Replace with your deployed API URL

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
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            AppCubit cubit = context.read<AppCubit>();
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
                        child: Text(loginResponse.isSuccess ? "Success" : "Error",
                          style: TextStyle(color: loginResponse.isSuccess ? Colors.green : Colors.redAccent),),
                      )
                ],
              ),
              content: Text(loginResponse.msg, style: TextStyle(fontSize: 20)),
              actions: <Widget>[
                loginResponse.isSuccess
                    ? AppButton(
                  color: theme.colorScheme.inversePrimary,
                  isFullWidth: true,
                  onPressed: () {
                    cubit.updateAccessToken(loginResponse.accessToken);
                    cubit.updateUserDetails(loginResponse.userName, loginResponse.userId);
                    setState(() {
                      _message = loginResponse.msg;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()), // need to change
                    );
                  },
                  size: AppButtonSize.large,
                  label: "Ok",
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
      setState(() {
        _message = 'Failed to connect to the server';
      });
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state after handling
      });
    }
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
                  child: Text("Welcome back.\nYou've been missed!", style: aBodyText2),
                ),
                SizedBox(height: 50.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: _emailController,
                    style: aBodyText.copyWith(color: Colors.white),
                    keyboardType: TextInputType.text,
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
                  )
                ),
                SizedBox(height: 230),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: aBodyText),
                    InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()), // need to change
                        );
                      },
                        child: Text(" Register", style: aBodyText.copyWith(color: Colors.white))),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: MyTextButton(
                    buttonName: "Sign In",
                    onTap: () {
                      login(_emailController.text, _passwordController.text);
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
