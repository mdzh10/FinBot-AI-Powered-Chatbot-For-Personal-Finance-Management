class Account {
  int? id;
  String name;
  String holderName;
  String accountNumber;
  bool? isDefault;
  double? balance;
  double? credit;
  double? debit;

  Account({
    this.id,
    required this.name,
    required this.holderName,
    required this.accountNumber,
    this.isDefault,
    this.credit,
    this.debit,
    this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> data) => Account(
    id: data["id"],
    name: data["name"],
    holderName: data["holderName"] ?? "",
    accountNumber: data["accountNumber"] ?? "",
    isDefault: data["isDefault"] == 1 ? true : false,
    credit: (data["credit"] ?? 0).toDouble(),
    debit: (data["debit"] ?? 0).toDouble(),
    balance: (data["balance"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "holderName": holderName,
    "accountNumber": accountNumber,
    "isDefault": (isDefault ?? false) ? 1 : 0,
    "credit": credit,
    "debit": debit,
    "balance": balance,
  };
}
