import 'dart:async'; // Import for TimeoutException
import 'dart:io'; // Import for SocketException

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:prayerunitesss/ui/screens/login_page/create_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../service/api/login/login_page_api.dart';
import '../../../utils/firebase/default_firebase_options.dart';
import '../../../utils/font_mediaquery.dart';
import '../../widgets/main_screen.dart';
import '../notification/notification_preference.dart';
import 'forgot_password/forgot_password_ui.dart';
import 'forgot_password/reset_password.dart';
import 'login_via_otp/login_otp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
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

  String? _validatePassword(String? value) {
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await LoginService.login(
        userName: _usernameController.text,
        password: _passwordController.text,
        context: context,
        maintainSession: true,
      );

      if (response.message == "Login Successfull") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'customerId',
          response.customerDetailResponse.customerId,
        );
        final fcmService = DefaultFirebaseOptions();
        await fcmService.initialize();

        if (fcmService.fcmToken != null) {
          print('FCM Token to send to server: ${fcmService.fcmToken}');
        }

        final storedId = prefs.getString('customerId');
        print('Stored customerId: $storedId');

        final hasSetPreferences =
            prefs.getBool('hasSetNotificationPreferences') ?? false;
        print('Notification preferences set: $hasSetPreferences');

        if (!mounted) return;
        _usernameController.clear();
        _passwordController.clear();

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
        if (!mounted) return;
        _usernameFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on SocketException catch (_) {
      if (!mounted) return;
      _usernameFocusNode.unfocus();
      _passwordFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection. Please check your network settings.',
          ),
          behavior: SnackBarBehavior.floating,

          backgroundColor: Colors.red,
        ),
      );
    } on TimeoutException catch (_) {
      if (!mounted) return;
      _usernameFocusNode.unfocus();
      _passwordFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection timeout. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on http.ClientException catch (e) {
      if (!mounted) return;
      _usernameFocusNode.unfocus();
      _passwordFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print(e);
      if (!mounted) return;
      _usernameFocusNode.unfocus();
      _passwordFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        _usernameFocusNode.unfocus();
        _passwordFocusNode.unfocus();
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

    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjusts the view when keyboard appears
      backgroundColor: const Color(0xFF3B873E),
      body: GestureDetector(
        onTap: () {
          // This will unfocus any currently focused text field
          FocusScope.of(context).unfocus();
        },
        behavior:
            HitTestBehavior
                .opaque, // Makes sure taps are detected even on transparent areas
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: SizedBox(
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
              ),
              SliverFillRemaining(
                hasScrollBody:
                    false, // Set to false to prevent scrolling when content is small
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, // Horizontal padding
                    vertical: screenHeight * 0.04,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // Center content vertically
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
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[700],
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Username Field
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3A4354),
                            fontSize: getDynamicFontSize(context, 0.032),
                            letterSpacing: -0.5,
                          ),
                          children: const <TextSpan>[
                            TextSpan(text: 'Email ID or Phone Number'),
                            // TextSpan(
                            //   text: '*',
                            //   style: TextStyle(color: Colors.red),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      TextFormField(
                        controller: _usernameController,
                        focusNode: _usernameFocusNode, // Add this

                        validator: AppValidators.validateEmailOrPhone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9@.]'),
                          ),
                        ],
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontRegularSize(context),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        decoration: InputDecoration(
                          hintText: 'Enter your Email Id or Phone Number',
                          hintStyle: GoogleFonts.beVietnamPro(
                            // No full stop here.
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
                      SizedBox(height: screenHeight * 0.025),

                      // Password Field
                      Text(
                        'Password',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A4354),
                          fontSize: getDynamicFontSize(context, 0.032),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode, // Add this

                        validator: _validatePassword,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontRegularSize(context),
                        ),
                        obscureText: !_isPasswordVisible,
                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        decoration: InputDecoration(
                          hintText: 'Enter your password',
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              color: Colors.grey, // <-- Add this line

                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: getFontRegularSize(context) * 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _formKey.currentState?.reset(); // <-- Add this

                              _usernameController.clear();
                              _passwordController.clear();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: getDynamicFontSize(context, 0.032),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _formKey.currentState?.reset(); // <-- Add this

                              _usernameController.clear();
                              _passwordController.clear();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginOtp(),
                                ),
                              );
                            },
                            child: Text(
                              'Login Via OTP',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: getDynamicFontSize(context, 0.032),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.055,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
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
                                    'Login',
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
                            "Dont have an account?",
                            style: GoogleFonts.inter(letterSpacing: -0.5),
                          ),
                          GestureDetector(
                            onTap: () {
                              _formKey.currentState?.reset(); // <-- Add this

                              _usernameController.clear();
                              _passwordController.clear();
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
                      const Expanded(
                        child: SizedBox(),
                      ), // Use Expanded to push content to the top
                    ],
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
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
