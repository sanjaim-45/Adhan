import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:prayerunitesss/service/api/otp_service/otp_service.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:prayerunitesss/ui/screens/login_page/create_account.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/font_mediaquery.dart';
import '../../../widgets/main_screen.dart';
import '../../notification/notification_preference.dart';
import '../forgot_password/reset_password.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key});

  @override
  State<LoginOtp> createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  bool _isLoading = false;
  bool _showOtpField = false;
  String? _errorMessage;
  final _otpFormKey = GlobalKey<FormState>();
  int _secondsRemaining = 30;
  Timer? _countdownTimer;
  // Validation methods
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Id or Phone Number is required';
    }
    if (value.length < 4) {
      return 'Email Id or Phone Number must be at least 4 characters';
    }
    return null;
  }

  void _startTimer() {
    // Cancel any existing timer
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }

    setState(() => _secondsRemaining = 30);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _tick() {
    if (mounted && _secondsRemaining > 0) {
      setState(() => _secondsRemaining--);
      Future.delayed(const Duration(seconds: 1), _tick);
    }
  }

  String _formatTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _usernameController.text.trim();
    final otpService = OtpService(
      apiService: ApiService(baseUrl: AppUrls.appUrl),
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Clear OTP field when resending OTP
    _otpController.clear();

    try {
      final response = await otpService.sendOuterOtp(phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _showOtpField = true;
      });

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // setState(() {
      //   _errorMessage = e.toString();
      // });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    final phoneNumber = _usernameController.text.trim();
    final otp = _otpController.text.trim();
    final otpService = OtpService(
      apiService: ApiService(baseUrl: AppUrls.appUrl),
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await otpService.verifyLoginOtp(
        userName: phoneNumber,
        otp: otp,
        context: context,
      );

      // // ✅ Show response message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(response.message),
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );

      // ✅ Check if login was successful
      if (response.message == "Login Successfull") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'customerId',
          response.customerDetailResponse.customerId,
        );

        // Optionally print or use the customerId
        final storedId = prefs.getString('customerId');
        print('Stored customerId: $storedId');

        final hasSetPreferences =
            prefs.getBool('hasSetNotificationPreferences') ?? false;
        print(
          'Notification preferences set: $hasSetPreferences',
        ); // Debug print

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    hasSetPreferences
                        ? const MainScreen()
                        : const NotificationPreference(),
          ),
        );
      } else {
        // ❌ Show failure toast
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed'),
            behavior: SnackBarBehavior.floating,

            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is Exception) {
        try {
          final decodedError = jsonDecode(
            e.toString().replaceFirst("Exception: ", ""),
          );
          errorMessage = decodedError['message'] ?? errorMessage;
        } catch (_) {}
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.beVietnamPro(fontSize: 15, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Unfocus when tapping outside
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF3B873E),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Top logo section (same as before)
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
                          'Access Live Mosque Audio',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontBoldSize(context),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Login with your Email ID or Phone Number and Password to access the live Mosque audio.',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                            color: Colors.grey[700],
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Username Field
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Email ID or Phone Number',
                                style: GoogleFonts.beVietnamPro(
                                  fontWeight: FontWeight.w600,
                                  fontSize: getFontRegularSize(context),
                                  letterSpacing: -0.5,
                                  color:
                                      Colors
                                          .black, // Default color for the text
                                ),
                              ),
                              // TextSpan(
                              //   text: '*',
                              //   style: GoogleFonts.beVietnamPro(
                              //     color: Colors.red, // Red color for the asterisk
                              //     fontWeight: FontWeight.w600,
                              //     fontSize: getFontRegularSize(context),
                              //     letterSpacing: -0.5,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        TextFormField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          validator: AppValidators.validateEmailOrPhone,
                          enabled: !_showOtpField,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,

                          decoration: InputDecoration(
                            hintText: 'Enter your Email ID or Phone Number',
                            hintStyle: GoogleFonts.beVietnamPro(
                              color: const Color(0xFFA1A1A1),
                              fontSize: getFontRegularSize(context),
                              letterSpacing: -0.5,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.04,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFEBEBEB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B873E),
                                width: 2,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              // <-- Add this
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFEBEBEB),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),

                        if (_showOtpField) ...[
                          SizedBox(height: screenHeight * 0.03),
                          Text(
                            'Enter OTP',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w600,
                              fontSize: getFontRegularSize(context),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.008),
                          Form(
                            key: _otpFormKey,
                            child: Pinput(
                              length: 6,
                              controller: _otpController,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration: defaultPinTheme.decoration!
                                    .copyWith(
                                      border: Border.all(
                                        color: const Color(0xFF3B873E),
                                      ),
                                    ),
                              ),
                              validator: (value) {
                                if (value == null || value.length != 6) {
                                  return 'Please enter a valid 6-digit OTP';
                                }
                                return null;
                              },
                              showCursor: true,
                              onCompleted: (pin) => _verifyOtp(),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "Time Remaining ",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _formatTime(_secondsRemaining),
                                      style: const TextStyle(
                                        color: Color(0xFF4E50C3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _secondsRemaining == 0 ? _sendOtp : null,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Didn't receive OTP? ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Resend',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              _secondsRemaining == 0
                                                  ? const Color(0xFF4E50C3)
                                                  : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_errorMessage != null) ...[
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],

                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.055,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _showOtpField
                                    ? _verifyOtp
                                    : _sendOtp,
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
                                      _showOtpField ? 'Verify OTP' : 'Continue',
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: getFontRegularSize(context),
                                        letterSpacing: -0.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: GoogleFonts.inter(),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Create Account",
                                style: GoogleFonts.inter(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _otpController.dispose();
    _usernameFocusNode.dispose();
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    super.dispose();
  }
}
