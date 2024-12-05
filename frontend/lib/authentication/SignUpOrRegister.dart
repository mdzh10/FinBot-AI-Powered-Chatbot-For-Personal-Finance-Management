import 'package:finbot/authentication/SignInPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/buttons/my_text_button.dart';
import '../widgets/constraints.dart';
import 'Register.dart';


class SignUpOrRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 90),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Image.asset(
                        'assets/images/get_started.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  "FinBot",
                  style: aHeadLine,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "Master your finances with FinBot—your AI-powered assistant that tracks spending, categorizes receipts, and offers personalized insights!",
                    style: aBodyText,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 150),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: MyTextButton(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                        bgColor: Colors.white,
                        buttonName: "Register",
                        textColor: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: MyTextButton(
                        bgColor: Colors.transparent,
                        buttonName: "Sign In",
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SigninPage(),
                              ));
                          // Navigator.pushNamed(context, MyRoutes.homeRoute);
                        },
                        textColor: Colors.white,
                      ),
                    )
                  ]),
                ),
              ],
            )),
      ),
    );
  }
}
