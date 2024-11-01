import 'Account.dart';

class AccountResponseModel {
  bool isSuccess;
  String msg;
  List<Account> accounts;

  AccountResponseModel({
    required this.isSuccess,
    required this.msg,
    required this.accounts,
  });

  factory AccountResponseModel.fromJson(Map<String, dynamic> data) {
    return AccountResponseModel(
      isSuccess: data["isSuccess"] ?? false,
      msg: data["msg"] ?? "",
      accounts: (data["account"] as List<dynamic>)
          .map((json) => Account.fromJson(json))
          .toList(),
    );
  }
}
