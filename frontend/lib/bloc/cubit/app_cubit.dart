import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  String? accessToken; // Only store access token
  late String? currency;
  late String? userName;
  late int? userId;

  // Static method to get the current state from SharedPreferences
  static Future<AppState> getState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");
    String? currency = prefs.getString("currency");
    String? userName = prefs.getString("userName");
    int? userId = prefs.getInt("userId");

    AppState appState = AppState();
    appState.accessToken = accessToken;
    appState.currency = currency;
    appState.userName = userName;
    appState.userId = userId;

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

  Future<void> updateUserDetails(String userName, int userId) async {
    print(userId);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", userName);
    await prefs.setInt("userId", userId);
    emit(await AppState.getState());
  }

  // Reset the access token
  Future<void> resetAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("currency");
    await prefs.remove("access_token");
    await prefs.remove("userId");
    emit(await AppState.getState());
  }

  Future<void> updateCurrency(currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency", currency);
    emit(await AppState.getState());
  }

  Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }
}
