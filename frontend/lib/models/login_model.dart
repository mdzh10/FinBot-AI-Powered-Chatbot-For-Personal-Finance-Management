class LoginResponse {
  final bool isSuccess;
  final String msg;
  final String accessToken;
  final String? tokenType;
  final int userId;
  final String? email;
  final String userName;
  final String? phoneNumber;

  LoginResponse({
    required this.isSuccess,
    required this.msg,
    required this.accessToken,
    this.tokenType,
    required this.userId,
    required this.email,
    required this.userName,
    required this.phoneNumber
  });

  // Factory method to create a LoginResponse from JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isSuccess: json['isSuccess'],
      msg: json['msg'],
      accessToken: json['access_token'] is String ? json['access_token'] : '',
      tokenType: json['token_type'] is String ? json['token_type'] : '',
      userId: json['user_id'] is int ? json['user_id'] : 0, // Default to 0 if not an int
      email: json['email'] is String ? json['email'] : '', // Default to empty string if not a String
      userName: json['username'] is String ? json['username'] : '', // Default to empty string if not a String
      phoneNumber: json['phone_number'] is String ? json['phone_number'] : '', // Default to empty string if not a String
    );
  }
}