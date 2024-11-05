class DashboardResponseModel {
  double totalBalance;
  double debits;
  double credits;

  DashboardResponseModel({
    required this.totalBalance,
    required this.debits,
    required this.credits,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> data) {
    return DashboardResponseModel(
      totalBalance: (data["total_balance"] ?? 0).toDouble(),
      debits: (data["debits"] ?? 0).toDouble(),
      credits: (data["credits"] ?? 0).toDouble(),
    );
  }
}
