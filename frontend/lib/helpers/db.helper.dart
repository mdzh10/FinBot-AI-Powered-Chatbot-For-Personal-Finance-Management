
import "dart:convert";
import "dart:io";
import "package:finbot/models/Account.dart";
import "package:finbot/models/AccountResponseModel.dart";
import "package:finbot/models/CategoryResponseModel.dart";
import "package:finbot/models/category.model.dart";
import 'package:http/http.dart' as http;
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";


Future<String> getExternalDocumentPath() async {
  // To check whether permission is given for this app or not.
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    // If not we will ask for permission first
    await Permission.storage.request();
  }
  Directory directory = Directory("");
  if (Platform.isAndroid) {
    // Redirects it to download folder in android
    directory = Directory("/storage/emulated/0/Download");
  } else {
    directory = await getApplicationDocumentsDirectory();
  }

  final exPath = directory.path;
  await Directory(exPath).create(recursive: true);
  return exPath;
}
Future<dynamic> export(int userId) async {
  List<dynamic> accounts = await loadAccount(userId);
  List<dynamic> categories = await loadCategory(userId);
  // List<dynamic> payments = await database!.query("payments",);
  Map<String, dynamic> data = {};
  data["accounts"] = accounts;
  data["categories"] = categories;
  // data["payments"] = payments;

  final path = await getExternalDocumentPath();
  String name = "fintracker-backup-${DateTime.now().millisecondsSinceEpoch}.json";
  File file= File('$path/$name');
  await file.writeAsString(jsonEncode(data));
  return file.path;
}

Future<List<Account>> loadAccount(int? userId) async {

  AccountResponseModel? accountResponseModel;

  final String apiUrl = "http://192.168.160.192:8000/account/" + userId.toString();
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

  final String apiUrl = "http://192.168.160.192:8000/category/" + userId.toString();
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

