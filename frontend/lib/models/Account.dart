enum AccountType { bank, cash }

extension AccountTypeExtension on AccountType {
  static AccountType fromString(String type) {
    switch (type) {
      case 'bank':
        return AccountType.bank;
      case 'cash':
        return AccountType.cash;
      default:
        throw ArgumentError('Unknown AccountType: $type');
    }
  }

  String toJson() {
    switch (this) {
      case AccountType.bank:
        return 'bank';
      case AccountType.cash:
        return 'cash';
    }
  }

  String get displayName {
    switch (this) {
      case AccountType.bank:
        return 'Bank';
      case AccountType.cash:
        return 'Cash';
    }
  }
}

class Account {
  int? id;
  int? userId;
  AccountType? accountType;
  String? bankName;
  String? accountName;
  int? accountNumber;
  double? balance;
  double? credit;
  double? debit;

  Account({
    this.id,
    this.userId,
    this.accountType,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.credit,
    this.debit,
    this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> data) => Account(
    id: data["id"],
    userId: data["user_id"],
    accountType: AccountTypeExtension.fromString(data["account_type"]),
    bankName: data["bank_name"] ?? "",
    accountName: data["account_name"] ?? "",
    accountNumber: data["account_number"] ?? 0,
    credit: (data["credit"] ?? 0).toDouble(),
    debit: (data["debit"] ?? 0).toDouble(),
    balance: (data["balance"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "account_type": accountType?.toJson(),
    "bank_name": bankName,
    "account_name": accountName,
    "account_number": accountNumber,
    "credit": credit,
    "debit": debit,
    "balance": balance,
  };
}
