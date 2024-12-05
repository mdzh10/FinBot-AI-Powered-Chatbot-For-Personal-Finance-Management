import 'package:finbot/screens/onboard/widgets/currency_pic.dart';
import 'package:finbot/screens/onboard/widgets/landing.dart';
import 'package:flutter/material.dart';

import '../../authentication/SignUpOrRegister.dart';

class OnboardScreen extends StatefulWidget {
  OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose(); // Properly dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LandingPage(onGetStarted: () {
            _pageController.jumpToPage(1);
          },),
          // ProfileWidget(onGetStarted: (){
          //   _pageController.jumpToPage(2);
          // },),
          CurrencyPicWidget(onGetStarted: (){
            _pageController.jumpToPage(2);
          },),
          SignUpOrRegister()
        ],
      ),
    );
  }
}
