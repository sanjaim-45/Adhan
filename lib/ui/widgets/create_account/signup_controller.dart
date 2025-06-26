// signup_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupController {
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final civilIdController = TextEditingController();
  final idExpiryController = TextEditingController();
  final otpController = TextEditingController();

  int currentStep = 1;
  bool isAccountCreated = false;

  // Shared phone number after OTP request
  String? sharedPhoneNumber;

  final formKey = GlobalKey<FormState>();

  double getFontBoldSize(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.045;

  double getFontRegularSize(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.035;

  // Validate Full Name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your full name';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  // Validate Mobile Number
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty)
      return 'Please enter your mobile number';
    if (!RegExp(r'^[+0-9]{8,15}$').hasMatch(value))
      return 'Enter a valid phone number';
    return null;
  }

  // Validate Email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Enter a valid email address';
    return null;
  }

  // Validate Password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value))
      return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value))
      return 'Password must contain at least one number';
    return null;
  }

  // Validate Civil ID
  String? validateCivilId(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your Civil ID';
    if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return 'Civil ID must be 12 digits';
    }
    return null;
  }

  // Validate Expiry Date
  String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) return 'Please enter expiry date';
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Enter date in DD/MM/YYYY format';
    }
    return null;
  }

  // Validate OTP
  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'Please enter the OTP';
    if (value.length != 6) return 'OTP must be 6 digits';
    return null;
  }

  // Send OTP via API
  Future<bool> sendOtp(String baseUrl, String phoneNumber) async {
    final url = Uri.parse(
      '$baseUrl/api/Customer/SendResetPassword-otp?PhoneOrEmail=$phoneNumber',
    );
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['message'] == 'Otp sent successfully') {
          sharedPhoneNumber = phoneNumber;
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String baseUrl, String code) async {
    final url = Uri.parse('$baseUrl/api/Login/verify-otp');
    final body = {"phoneOrEmail": sharedPhoneNumber ?? "", "code": code};
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

  // Create Account
  Future<bool> createAccount(String baseUrl) async {
    final url = Uri.parse('$baseUrl/api/Customer/create');

    final request = http.MultipartRequest('POST', url)
      ..fields.addAll({
        'FirstName': fullNameController.text,
        'Password': passwordController.text,
        'PhoneNumber': mobileController.text,
        'Email': emailController.text,
        'CivilId': civilIdController.text,
        'CivilIdExpiryDate': idExpiryController.text,
        'PassportNumber': '', // Optional field
      });

    try {
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Error creating account: $e");
      return false;
    }
  }

  void dispose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    civilIdController.dispose();
    idExpiryController.dispose();
    otpController.dispose();
  }
}
