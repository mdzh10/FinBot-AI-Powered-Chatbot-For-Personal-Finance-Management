class SignupResponse {
  final bool isSuccess;
  final String msg;
  final int userId;
  final String email;
  final String userName;
  final String phoneNumber;

  SignupResponse({
    required this.isSuccess,
    required this.msg,
    required this.userId,
    required this.email,
    required this.userName,
    required this.phoneNumber
  });

  // Factory method to create a SignupResponse from JSON
  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      isSuccess: json['isSuccess'],
      msg: json['msg'],
      userId: json['user_id'] is int ? json['user_id'] : 0, // Default to 0 if not an int
      email: json['email'] is String ? json['email'] : '', // Default to empty string if not a String
      userName: json['username'] is String ? json['username'] : '', // Default to empty string if not a String
      phoneNumber: json['phone_number'] is String ? json['phone_number'] : '', // Default to empty string if not a String
    );
  }
}