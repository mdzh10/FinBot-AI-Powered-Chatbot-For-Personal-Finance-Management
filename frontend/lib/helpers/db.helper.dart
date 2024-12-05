import "dart:convert";
import "dart:io";
import "package:finbot/models/Account.dart";
import "package:finbot/models/AccountResponseModel.dart";
import "package:finbot/models/CategoryResponseModel.dart";
import "package:finbot/models/Transaction.dart";
import "package:finbot/models/TransactionResponse.dart";
import "package:finbot/models/category.model.dart";
import 'package:http/http.dart' as http;
import "package:path_provider/path_provider.dart";

import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart"; // Needed for BuildContext

Future<String?> getExternalDocumentPath(BuildContext context) async {
  // Request storage permissions
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
    if (!status.isGranted) {
      // Inform the user that permission is needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required to export data.")),
      );
      return null;
    }
  }

  Directory? directory;
  if (Platform.isAndroid) {
    // Retrieve the Downloads directory
    List<Directory>? dirs =
    await getExternalStorageDirectories(type: StorageDirectory.downloads);
    if (dirs != null && dirs.isNotEmpty) {
      directory = dirs.first;
    } else {
      // Fallback to a default path if the Downloads directory is not found
      directory = Directory("/storage/emulated/0/Download");
    }
  } else {
    // For iOS, use the application documents directory
    directory = await getApplicationDocumentsDirectory();
  }

  if (directory != null) {
    // Ensure the directory exists
    await directory.create(recursive: true);
    return directory.path;
  }

  return null;
}

Future<List<Account>> loadAccount(int? userId) async {
  AccountResponseModel? accountResponseModel;

  final String apiUrl =
      "https://finbot-fastapi-rc4376baha-ue.a.run.app/account/" + userId.toString();
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    accountResponseModel = AccountResponseModel.fromJson(data);
  } else {
    throw Exception('Failed to load accounts');
  }

  return accountResponseModel.accounts;
}

Future<List<Category>> loadCategory(int? userId) async {
  CategoryResponse? categoryResponse;

  final String apiUrl =
      "https://finbot-fastapi-rc4376baha-ue.a.run.app/category/" + userId.toString();
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    categoryResponse = CategoryResponse.fromJson(data);
  } else {
    throw Exception('Failed to load categories');
  }
  return categoryResponse.categories;
}

Future<List<Transaction>> fetchTransactions(int? userId) async {
  TransactionResponse? transactionResponse;
  final uriTrans = Uri.parse("https://finbot-fastapi-rc4376baha-ue.a.run.app/transaction/$userId");
  try {
    final responseTrans = await http.get(uriTrans);
    print('API URL: $uriTrans');
    print('Response Status: ${responseTrans.statusCode}');
    print('Response Body: ${responseTrans.body}');

    if (responseTrans.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(responseTrans.body);
       transactionResponse = TransactionResponse.fromJson(json);
    } else {
      print('Failed to load transactions: ${responseTrans.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
  return transactionResponse?.transactions ?? [];
}


