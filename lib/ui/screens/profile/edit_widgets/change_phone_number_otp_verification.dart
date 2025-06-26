import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../service/api/customer/customer_service_api.dart';
import '../../../../service/api/otp_service/otp_service.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/font_mediaquery.dart';

class ChangePhoneNumberOtpVerification extends StatefulWidget {
  final String mobileNumber;
  final OtpService otpService;

  const ChangePhoneNumberOtpVerification({
    super.key,
    required this.mobileNumber,
    required this.otpService,
  });

  @override
  State<ChangePhoneNumberOtpVerification> createState() =>
      _ChangePhoneNumberOtpVerificationState();
}

class _ChangePhoneNumberOtpVerificationState
    extends State<ChangePhoneNumberOtpVerification> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _mobileErrorMessage;
  String? _otpErrorMessage;
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  String? _errorMessage;

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _otpController.dispose();
    _mobileFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    // Unfocus all fields
    FocusScope.of(context).unfocus();

    final phoneNumber = _mobileNumberController.text.trim();

    setState(() {
      _mobileErrorMessage = null; // Clear previous mobile error message
    });
    if (phoneNumber.isEmpty) {
      setState(() {
        _mobileErrorMessage = 'Please enter a phone number';
      });
      _mobileFocusNode.requestFocus(); // Focus on mobile number field
      return;
    }
    if (phoneNumber.length < 10) {
      setState(() {
        _mobileErrorMessage = 'Phone number must be at least 10 digits';
      });
      _mobileFocusNode.requestFocus(); // Focus on mobile number field
      return;
    }
    if (phoneNumber == widget.mobileNumber) {
      setState(() {
        _mobileErrorMessage =
            'New phone number cannot be the same as the current one.';
        _mobileFocusNode.requestFocus(); // Focus on mobile number field
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _mobileErrorMessage = null;
    });

    try {
      final response = await widget.otpService.sendOtp(phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        String errorMessage = e.toString();
        // Remove "Exception: " prefix if present
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        _errorMessage = errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    } finally {
      _mobileFocusNode.requestFocus();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    // Unfocus all fields
    FocusScope.of(context).unfocus();

    final phoneNumber = _mobileNumberController.text.trim();
    final otp = _otpController.text.trim();
    setState(() {
      _otpErrorMessage = null; // Clear previous OTP error message
    });

    if (phoneNumber.isEmpty || otp.isEmpty) {
      setState(() {
        _otpErrorMessage = 'Please enter both phone number and OTP';
      });
      _otpFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _otpErrorMessage = null;
    });

    try {
      final response = await widget.otpService.verifyPhoneOuterOtp(
        phoneOrEmail: phoneNumber,
        code: otp,
      );

      await CustomerServices(baseUrl: AppUrls.appUrl).getCustomerById();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // In ChangePhoneNumberOtpVerification's _verifyOtp method:
      if (response.message.contains('successfully')) {
        Navigator.of(
          context,
        ).pop(_mobileNumberController.text.trim()); // Return new number
      }
    } catch (e) {
      // print(e);
      print('response message = ${e.toString()}');
      String errorMessage = e.toString();
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      // Extract only the message part if it's in the format: Exception: {"message":"Your error message"}
      RegExp regExp = RegExp(r'{"message":"([^"}]+)"}');
      Match? match = regExp.firstMatch(errorMessage);
      if (match != null && match.groupCount > 0) {
        errorMessage = match.group(1)!;
      }

      _otpFocusNode.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _otpErrorMessage = errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
        _otpFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFFFFFFF),
        appBar: PreferredSize(
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
                'Update Phone Number',
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
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update Phone Number",
                style: TextStyle(
                  fontSize: sizeWidth * 0.0356,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Edit or add a phone number for communication and recovery.",
                style: TextStyle(
                  fontSize: sizeWidth * 0.03,
                  color: Colors.black54,
                ),
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
                    text: 'Current Phone Number : ',
                    style: TextStyle(color: Colors.black54),
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.mobileNumber,
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
              Text(
                "Mobile Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sizeWidth * 0.0356,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mobileNumberController,
                      focusNode: _mobileFocusNode,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        if (value == widget.mobileNumber) {
                          return 'New phone number cannot be the same as the current one.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter New Mobile Number',
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
              // if (_mobileErrorMessage != null) ...[
              //   const SizedBox(height: 8),
              //   Text(
              //     _mobileErrorMessage!,
              //     style: const TextStyle(color: Colors.red),
              //   ),
              // ],
              const SizedBox(height: 24),
              Text(
                "OTP Verification",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sizeWidth * 0.0356,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(fontSize: sizeWidth * 0.0356),
                maxLength: 6,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  final mobile = _mobileNumberController.text.trim();
                  if (mobile.isEmpty) {
                    return 'Please enter a valid mobile number first';
                  }
                  if (mobile.length < 10) {
                    return 'Please enter a valid mobile number first';
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
                  counterText: "",
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
              ), //
              // if (_otpErrorMessage != null) ...[
              //   const SizedBox(height: 16),
              //   Text(
              //     _otpErrorMessage!,
              //     style: const TextStyle(color: Colors.red),
              //   ),
              // ],
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                16.0, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 16.0,
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
    );
  }
}
