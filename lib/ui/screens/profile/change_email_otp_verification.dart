import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../service/api/customer/customer_service_api.dart';
import '../../../service/api/otp_service/otp_service.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/font_mediaquery.dart';

class UpdateEmailPage extends StatefulWidget {
  final String email;
  final OtpService otpService;
  const UpdateEmailPage({
    super.key,
    required this.email,
    required this.otpService,
  });

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    if (value.toLowerCase() == widget.email.toLowerCase()) {
      return 'New email cannot be the same as the current one.';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    final emailError = _validateEmail(email);
    if (emailError != null) {
      setState(() {
        _errorMessage = emailError;
        FocusScope.of(context).requestFocus(_emailFocusNode);
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.otpService.sendOtp(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Move focus to OTP field after sending OTP
      if (mounted) {
        FocusScope.of(context).requestFocus(_otpFocusNode);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          String errorMessage = e.toString();
          // Remove "Exception: " prefix if present
          if (errorMessage.startsWith("Exception: ")) {
            errorMessage = errorMessage.substring("Exception: ".length);
          }
          _errorMessage = errorMessage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(_errorMessage.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final phoneNumber = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (phoneNumber.isEmpty || otp.isEmpty) {
      setState(() {
        if (phoneNumber.isEmpty && !_emailFocusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_emailFocusNode);
        } else if (otp.isEmpty && !_otpFocusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_otpFocusNode);
        }
        _errorMessage = 'Please enter both Email and OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.otpService.verifyPhoneOtp(
        phoneOrEmail: phoneNumber,
        code: otp,
      );
      await CustomerServices(baseUrl: AppUrls.appUrl).getCustomerById();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // If verification is successful, pop back
      if (response.message.contains('successfully')) {
        Navigator.of(
          context,
        ).pop(_emailController.text.trim()); // Return new number
      }
    } catch (e) {
      // print(e);
      print('response message = ${e.toString()}');
      String errorMessage = e.toString();
      // Extract only the message part if it's in the format: Exception: {"message":"Your error message"}
      RegExp regExp = RegExp(r'{"message":"([^"}]+)"}');
      Match? match = regExp.firstMatch(errorMessage);
      if (match != null && match.groupCount > 0) {
        errorMessage = match.group(1)!;
      }
      print(errorMessage);
      if (mounted) {
        setState(() => _errorMessage = errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage.toString()),
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
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Unfocus when tapping outside
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: PreferredSize(
          key: ValueKey("appBar"), // Added a key for testing or other purposes
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 70,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: 40,
                    height: 15,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              title: Text(
                'Update Email',
                style: GoogleFonts.beVietnamPro(
                  color: Colors.black,
                  letterSpacing: -0.5,
                  fontSize: getDynamicFontSize(context, 0.05),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          reverse: true, // This will help in keeping focused field visible
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Update Email",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Edit or add a Email for communication and recovery.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Current Email : ',
                    style: TextStyle(color: Colors.black54),
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.email.isEmpty ? 'Add Email' : widget.email,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        hintText: 'Enter New Email',
                        hintStyle: const TextStyle(color: Color(0xFFA1A1A1)),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: TextButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    "Send OTP",
                                    style: GoogleFonts.beVietnamPro(
                                      color: const Color(0xFF2E7D32),
                                      fontSize: getFontRegularSize(context),
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "OTP Verification",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6, // Restrict input to 6 digits
                autovalidateMode: AutovalidateMode.onUserInteraction,
                buildCounter:
                    (
                      BuildContext context, {
                      int? currentLength,
                      int? maxLength,
                      bool? isFocused,
                    }) => null,
                validator: (value) {
                  final email = _emailController.text.trim();
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (email.isEmpty) {
                    return 'Please enter a valid email first';
                  }
                  if (!emailRegex.hasMatch(email)) {
                    return 'Please enter a valid email first';
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length < 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'e.g. 758543',
                  hintStyle: const TextStyle(color: Color(0xFFA1A1A1)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // if (_errorMessage != null) ...[
              //   const SizedBox(height: 16),
              //   Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              // ],
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          // Adjust padding when keyboard is visible
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _verifyOtp,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        "Verify OTP",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
