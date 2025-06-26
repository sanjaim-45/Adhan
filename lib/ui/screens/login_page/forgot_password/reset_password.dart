import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:prayerunitesss/ui/screens/login_page/login_page.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../../service/api/auth/auth_api_service.dart';
import '../../../../service/api/login/login_page_api.dart';
import '../../../../utils/font_mediaquery.dart';

class ResetPasswordUi extends StatefulWidget {
  final String contactInfo;

  const ResetPasswordUi({super.key, required this.contactInfo});

  @override
  State<ResetPasswordUi> createState() => _ResetPasswordUiState();
}

class _ResetPasswordUiState extends State<ResetPasswordUi>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obsureConfirmPassword = true;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final LoginService _apiService = LoginService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _newPasswordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthApiService(
        baseUrl: AppUrls.appUrl,
        client: http.Client(),
      );

      final response = await authService.confirmPasswordApi(
        userConfirmPassword: _confirmpasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (kDebugMode) {
          print('Password Reset Response: ${response.message}');
        }

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showExitConfirmation() async {
    bool? shouldExit = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: Colors.orange,
                ),
                const SizedBox(height: 15),
                Text(
                  'Exit Password Reset?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to exit? You won\'t be able to reset your password if you leave now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E50C3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Exit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3B873E),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top logo section (same as your original code)
            SizedBox(
              height: screenHeight * 0.22,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.08),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: screenHeight * 0.12,
                        width: screenWidth * 0.30,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.001,
                    right: screenWidth * 0.013,
                    child: Image.asset(
                      'assets/images/logo_blur.png',
                      height: screenHeight * 0.27,
                      width: screenWidth * 0.50,
                    ),
                  ),
                ],
              ),
            ),

            // Login form
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.04,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset Password',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontBoldSize(context),
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Enter Your New Password',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontRegularSize(context),
                          color: Colors.grey[700],
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Username Field
                      Text(
                        'New Password ',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w600,
                          fontSize: getFontRegularSize(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      CustomTextField(
                        controller: _newPasswordController,
                        hintText: 'Enter your New Password',
                        obscureText: _obscurePassword,
                        validator:
                            _validateNewPassword, // Use the new password validator
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Password Field
                      Text(
                        'Confirm Password ',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w600,
                          fontSize: getFontRegularSize(context),
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 5),
                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmpasswordController,
                        hintText: 'Enter your Confirm New Password',
                        obscureText: _obsureConfirmPassword,
                        validator:
                            _validateConfirmPassword, // Use the confirm password validator
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obsureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obsureConfirmPassword = !_obsureConfirmPassword;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.055,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D7C3F),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                  : Text(
                                    'Continue',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: getFontRegularSize(context),
                                      letterSpacing: -0.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, color: Color(0xFF3A4354)),
                              Text(
                                'Back to Login',
                                style: TextStyle(color: Color(0xFF3A4354)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final EdgeInsets contentPadding;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 12,
    ),
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: getFontRegularSize(context),
          color: const Color(0xFFA1A1A1),
          fontWeight: FontWeight.w500,
        ),
        contentPadding: contentPadding,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3B873E), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

class AppValidators {
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or mobile number';
    }

    // Check if the input looks like a phone number (digits and optional +)
    final isPotentialPhoneNumber = RegExp(r'^[+0-9]+$').hasMatch(value);

    if (isPotentialPhoneNumber) {
      return _validatePhoneNumber(value);
    } else {
      return _validateEmail(value);
    }
  }

  static String? _validatePhoneNumber(String value) {
    // For Indian numbers: exactly 10 digits, starting with 6-9
    if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }

    if (!RegExp(r'^[+0-9]{8,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    if (value.length > 10 && !value.startsWith('+')) {
      return 'Mobile number cannot exceed 10 digits';
    }
    return null;
  }

  static String? _validateEmail(String value) {
    if (value.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    int atCount = '@'.allMatches(value).length;
    if (atCount != 1) {
      return 'Email must contain exactly one "@"';
    }

    List<String> parts = value.split('@');
    if (parts.length == 2) {
      String domainPart = parts[1];
      int dotAfterAt = '.'.allMatches(domainPart).length;
      if (dotAfterAt < 1) {
        return 'At least one dot (".") should be present after "@"';
      }
    }

    if (value.startsWith('@') || value.endsWith('@')) {
      return 'Email cannot start or end with "@"';
    }

    if (value.contains('.@')) {
      return 'Dot cannot be right before "@"';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+[a-zA-Z0-9]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email (e.g., example@domain.com)';
    }

    return null;
  }
}

class Validator {
  // Email validation function
  String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or mobile number';
    }

    // Email pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    // Mobile number pattern (basic: 10 digits)
    final mobileRegex = RegExp(r'^\d{10}$');

    if (!emailRegex.hasMatch(value) && !mobileRegex.hasMatch(value)) {
      return 'Enter a valid email or 10-digit mobile number';
    }

    return null;
  }

  // Password validation function
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? validateEmailAndPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email or mobile number';
    }

    // Remove any whitespace or special characters that might be in phone numbers
    final cleanedValue = value.replaceAll(RegExp(r'[+\-\s]'), '');

    // Check if it's a potential phone number (all digits, possibly with country code)
    if (RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      // Check for Indian phone numbers (10 digits, may start with 0 or +91)
      if (cleanedValue.length == 10) {
        return null;
      }
      // Check if it's 12 digits (like 91xxxxxxxxxx)
      else if (cleanedValue.length == 12 && cleanedValue.startsWith('91')) {
        return null;
      }
      // Check if it's 11 digits (like 0xxxxxxxxxx)
      else if (cleanedValue.length == 11 && cleanedValue.startsWith('0')) {
        return null;
      }
      return 'Please enter a valid 10-digit mobile number';
    }

    // Otherwise, validate as email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Add this method to your Validator class
  String? validatePasswordMatch(String? value, String? otherPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != otherPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
