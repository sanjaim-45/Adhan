import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:prayerunitesss/ui/screens/login_page/forgot_password/reset_password.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../../service/api/auth/auth_api_service.dart';
import '../../../../utils/font_mediaquery.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;
  bool _showOtpField = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  String? _errorMessage;
  int _secondsRemaining = 30;
  Timer? _countdownTimer;
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
    _emailController.dispose();
    _otpController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();

    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }

    super.dispose();
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

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = AuthApiService(
          baseUrl: AppUrls.appUrl,
          client: http.Client(),
        );

        final response = await authService.forgotPassword(
          _emailController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _showOtpField = true;
          });
          _startTimer();
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = e.toString();
          if (e.toString().contains("message")) {
            errorMessage = jsonDecode(e.toString())['message'];
          }
          setState(() {
            _errorMessage = errorMessage;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _otpController.clear(); // Clear the Pinput controller text
    });

    try {
      final authService = AuthApiService(
        baseUrl: AppUrls.appUrl,
        client: http.Client(),
      );

      // Re-send OTP using same email
      final response = await authService.forgotPassword(_emailController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear OTP field
        _otpController.clear();

        // Restart timer
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e.toString().contains("message")) {
          errorMessage = jsonDecode(e.toString())['message'];
        }
        setState(() {
          _errorMessage = errorMessage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthApiService(
        baseUrl: AppUrls.appUrl,
        client: http.Client(),
      );

      final response = await authService.verifyResetPasswordOtp(
        otp: _otpController.text,
        userIdentifier: _emailController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) =>
                    ResetPasswordUi(contactInfo: _emailController.text),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e.toString().contains("message")) {
          errorMessage = jsonDecode(e.toString())['message'];
        }
        setState(() {
          _errorMessage = errorMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
              // Top logo section
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
                          'Forgot your password?',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontBoldSize(context),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Enter your email and we\'ll send you a reset link.',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                            color: Colors.grey[700],
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Email Field
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
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          enabled: !_showOtpField,
                          validator: AppValidators.validateEmailOrPhone,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: 'Enter your email or Phone number',
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
                          Pinput(
                            length: 6,
                            focusNode: _otpFocusNode,
                            controller: _otpController,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
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
                                onTap:
                                    _secondsRemaining == 0 ? _resendOtp : null,
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

                        // if (_errorMessage != null) ...[
                        //   SizedBox(height: screenHeight * 0.02),
                        //   Text(
                        //     _errorMessage!,
                        //     style: const TextStyle(color: Colors.red),
                        //   ),
                        // ],
                        const SizedBox(height: 30),

                        // Continue/Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.055,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _showOtpField
                                    ? _verifyOtp
                                    : _handleContinue,
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(height: 5),

                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.5,
                                  child: const Icon(
                                    Icons.arrow_back,
                                    size: 12,
                                    color: Color(0xFF3A4354),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Back to Login in',
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
      ),
    );
  }
}
