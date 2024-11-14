import 'package:finbot/screens/settings/settings.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../bloc/cubit/app_cubit.dart';
import 'accounts/accounts.screen.dart';
import 'categories/categories.screen.dart';
import 'home/home.screen.dart';
import 'onboard/onboard_screen.dart';
import 'dart:async';
class MainScreen extends StatefulWidget{
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final PageController _controller = PageController(keepPage: true);
  int _selected = 0;
  bool _isGlorious = false;

  @override
  void initState() {
    super.initState();
    _startGlowAnimation();
  }

  void _startGlowAnimation() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _isGlorious = !_isGlorious; // Toggle glow effect every second
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        AppCubit cubit = context.read<AppCubit>();
        if (cubit.state.accessToken == null) {
          return OnboardScreen();
        } else {
          print("cubit userId : " + cubit.state.userId.toString());
        }
        return Scaffold(
          body: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomeScreen(cubit.state.userId),
              AccountsScreen(cubit.state.userId),
              CategoriesScreen(cubit.state.userId),
              SettingsScreen(cubit.state.userId)
            ],
            onPageChanged: (int index) {
              setState(() {
                _selected = index;
              });
            },
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selected,
            destinations: [
              const NavigationDestination(icon: Icon(Symbols.home, fill: 1,), label: "Home"),
              const NavigationDestination(icon: Icon(Symbols.wallet, fill: 1,), label: "Accounts"),

              // Glorious Chatbot Button
              NavigationDestination(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: EdgeInsets.all(_isGlorious ? 4 : 8), // Animate padding to create a "pulse" effect
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _isGlorious
                        ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ]
                        : [],
                  ),
                  child: Image.asset(
                    'assets/images/bot.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                label: "Chatbot",
              ),

              const NavigationDestination(icon: Icon(Symbols.category, fill: 1,), label: "Categories"),
              const NavigationDestination(icon: Icon(Symbols.more_horiz_rounded, fill: 1,), label: "More"),
            ],
            onDestinationSelected: (int selected) {
              setState(() {
                _selected = selected;
              });
              _controller.jumpToPage(selected);
            },
          ),
        );
      },
    );
  }
}
