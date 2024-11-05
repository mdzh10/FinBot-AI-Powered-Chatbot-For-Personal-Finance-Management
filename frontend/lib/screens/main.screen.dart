import 'package:finbot/screens/settings/settings.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../bloc/cubit/app_cubit.dart';
import 'home/home.screen.dart';
import 'onboard/onboard_screen.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  final PageController _controller = PageController(keepPage: true);
  int _selected = 0;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state){
        AppCubit cubit = context.read<AppCubit>();
        if(cubit.state.accessToken == null){
          return OnboardScreen();
        } else {
          print("cubit userId : " + cubit.state.userId.toString());
        }
        return  Scaffold(
          body: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomeScreen(cubit.state.userId),
              // AccountsScreen(),
              // CategoriesScreen(),
              // SettingsScreen()
            ],
            onPageChanged: (int index){
              setState(() {
                _selected = index;
              });
            },
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selected,
            destinations: const [
              NavigationDestination(icon: Icon(Symbols.home, fill: 1,), label: "Home"),
              NavigationDestination(icon: Icon(Symbols.wallet, fill: 1,), label: "Accounts"),
              NavigationDestination(icon: Icon(Symbols.category, fill: 1,), label: "Categories"),
              NavigationDestination(icon: Icon(Symbols.settings, fill: 1,), label: "Settings"),
            ],
            onDestinationSelected: (int selected){
                _controller.jumpToPage(selected);
            },
          ),
        );
      },
    );

  }
}