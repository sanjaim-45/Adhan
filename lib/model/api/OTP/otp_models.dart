// otp_models.dart

class OtpRequest {
  final String phoneOrEmail;

  OtpRequest({required this.phoneOrEmail});

  Map<String, dynamic> toJson() => {'PhoneOrEmail': phoneOrEmail};
}

class VerifyOtpRequest {
  final String phoneOrEmail;
  final String code;

  VerifyOtpRequest({required this.phoneOrEmail, required this.code});

  Map<String, dynamic> toJson() => {'phoneOrEmail': phoneOrEmail, 'code': code};
}

class OtpResponse {
  final String message;

  OtpResponse({required this.message});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(message: json['message'] ?? '');
  }
}
