import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  String? accessToken; // Only store access token
  late String? currency;

  // Static method to get the current state from SharedPreferences
  static Future<AppState> getState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");
    String? currency = prefs.getString("currency");

    AppState appState = AppState();
    appState.accessToken = accessToken;
    appState.currency = currency;

    return appState;
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit(AppState initialState) : super(initialState);

  // Update the access token
  Future<void> updateAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
    emit(await AppState.getState());
  }

  // Reset the access token
  Future<void> resetAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("currency");
    await prefs.remove("access_token");
    emit(await AppState.getState());
  }

  Future<void> updateCurrency(currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency", currency);
    emit(await AppState.getState());
  }
}
