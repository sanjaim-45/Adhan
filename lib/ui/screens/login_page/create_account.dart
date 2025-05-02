import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/font_mediaquery.dart';
import 'login_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool _isAccountCreated = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2E7D32), // top green color
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 50),
          child: Column(
            children: [
              // App Bar & Title
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/name_logo.png', height: 40),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Form(
                    key: _formKey, // Add this key to your state class

                    child:
                        _isAccountCreated
                            ? _buildSuccessMessage(context)
                            : ListView(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors
                                              .white, // Optional, set the background color if needed
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(
                                          0.2,
                                        ), // Set the border color
                                        width: 1, // Set the border width
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(
                                            0.1,
                                          ), // Shadow color
                                          spreadRadius: 2, // Spread the shadow
                                          blurRadius: 5, // Blur radius
                                          offset: Offset(
                                            0,
                                            0,
                                          ), // Offset the shadow vertically
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.arrow_back_ios_new),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Join the Circle of Prayer',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: getFontBoldSize(context),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Create your account to start listening to live prayers and stay connected to your masjid — anytime, anywhere.',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: getFontRegularSize(context),
                                    color: Colors.grey[700],
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 16),
                                buildAvatar(),
                                SizedBox(height: 16),

                                _buildTextField(
                                  'Full Name',
                                  'e.g. Ahmed Al-Mutairi',
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  'Mobile Number',
                                  'e.g. +965 50123456',
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  'Email Address',
                                  'e.g. ahmed@email.com',
                                ),
                                SizedBox(height: 16),
                                _buildPasswordField(
                                  'Password',
                                  'Enter a strong password',
                                ),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isAccountCreated = true;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2D7C3F),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation:
                                        0, // Set the elevation to 0 to remove the default shadow
                                  ),
                                  child: Text(
                                    'Create Account',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: getFontRegularSize(context),
                                      letterSpacing: -0.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: GoogleFonts.beVietnamPro(
                                          letterSpacing: -0.5,
                                          fontSize: getFontRegularSize(context)
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Login',
                                          style: GoogleFonts.beVietnamPro(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                            fontSize: getFontRegularSize(context)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w600,
            fontSize: getFontRegularSize(context),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 50,

          child: TextField(

            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color(0xFF3B873E),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              hintText: hint,
              hintStyle: GoogleFonts.beVietnamPro(
                color: Color(0xFFA1A1A1),
                fontSize: getFontRegularSize(context),
                letterSpacing: -0.5,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            style: GoogleFonts.beVietnamPro(
              letterSpacing: -0.5, // Letter spacing for the text input
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint) {
    final mediaQuery = MediaQuery.of(context);

    final screenWidth = mediaQuery.size.width;
    final inputFieldFontSize = screenWidth * 0.03;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w600,
            fontSize: getFontRegularSize(context),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),

        SizedBox(
          height: 50,
          child: TextField(
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color(0xFF3B873E),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              hintText: hint,
              hintStyle: GoogleFonts.beVietnamPro(
                color: Color(0xFFA1A1A1),
                fontSize:getFontRegularSize(context),
                letterSpacing: -0.5,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: inputFieldFontSize * 2,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildAvatar() {
  return Stack(
    alignment: Alignment.topLeft,
    children: [
      // Background circle with optional image or icon
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.green.shade50, // Light green background
        child: Icon(Icons.person, size: 40, color: Colors.green.shade200),
      ),

      // Small camera button
      Positioned(
        bottom: 4,
        left: 55,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF2D7C3F), // Dark green
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(6),
          child: Icon(Icons.camera_alt, size: 13, color: Colors.white),
        ),
      ),
    ],
  );
}

Widget _buildSuccessMessage(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/success.png", height: 100, width: 100),
        SizedBox(height: 20),
        Text(
          'Account Created Successfully!',
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: getFontBoldSize(context),
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Our team will review your request and activate your access soon. You’ll receive a message once approved.',
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(fontSize: getFontRegularSize(context), color: Colors.grey[600],            letterSpacing: -0.5
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => LoginPage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2E7D32),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0, // Set the elevation to 0 to remove the default shadow
          ),
          child: Text(
            'Go to Login Page',
            style: GoogleFonts.beVietnamPro(
              fontSize: getFontRegularSize(context),
              letterSpacing: -0.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
