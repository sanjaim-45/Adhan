import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';

import '../../../utils/app_urls.dart';
import '../../widgets/create_account/avatar_picker.dart';
import 'login_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  bool _isAccountCreated = false;
  bool _isLoading = false;
  File? _profilePicture; // Add this line to store the selected image
  int _secondsRemaining = 30;
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // Focus Nodes
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _civilIdFocusNode = FocusNode();
  final FocusNode _idExpiryFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _mosqueFocusNode = FocusNode();

  DateTime selectedDate = DateTime.now();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _civilIdController = TextEditingController();
  final TextEditingController _idExpiryController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  Timer? _countdownTimer;

  int? _selectedMosqueId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _civilIdController.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild to show/hide ID Expiry Date field
      }
    });
  }

  String _formatTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _pickDate(BuildContext context) {
    BottomPicker.date(
      pickerTitle: Text(
        'Set ID Expiry Date',
        style: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.05,
          letterSpacing: -0.5,
          color: Colors.black,
        ),
      ),
      dateOrder: DatePickerDateOrder.dmy,
      initialDateTime:
          selectedDate.isBefore(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day + 1,
                ),
              )
              ? DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day + 1,
              )
              : selectedDate,
      minDateTime: DateTime(
        DateTime.now().year,
        DateTime.now().month, // Restrict past dates,
        DateTime.now().day + 1, // Ensure it's at least the next day
      ),
      maxDateTime: DateTime(2100),
      pickerTextStyle: GoogleFonts.beVietnamPro(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: MediaQuery.of(context).size.width * 0.05,
      ),
      onSubmit: (pickedDate) {
        setState(() {
          selectedDate = pickedDate;
          final formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
          _idExpiryController.text = formattedDate;
        });
      },
      buttonContent: Text(
        textAlign: TextAlign.center,
        "Done",
        style: GoogleFonts.beVietnamPro(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      buttonStyle: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }

  // For OTP verification
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFEBEBEB)),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _civilIdController.dispose();
    _idExpiryController.dispose();
    _otpController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _mobileFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _civilIdFocusNode.dispose();
    _idExpiryFocusNode.dispose();
    _otpFocusNode.dispose();
    _mosqueFocusNode.dispose();
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    super.dispose();
  }

  Future<bool> _registerUser() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('${AppUrls.appUrl}/api/Customer/RegisterByQr');
      final multipartRequest = http.MultipartRequest('POST', uri);

      // Add form-data fields
      multipartRequest.fields.addAll({
        'FirstName': _firstNameController.text.trim(),
        'LastName': _lastNameController.text.trim(),
        'Code': _otpController.text.trim(),
        'PhoneNumber': _mobileController.text.trim(),
        'Email': _emailController.text.trim(),
        'CivilId': _civilIdController.text.trim(),
        'CivilIdExpiryDate':
            _idExpiryController.text.trim().isNotEmpty
                ? DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(
                  DateFormat(
                    'dd-MM-yyyy',
                  ).parse(_idExpiryController.text.trim()),
                )
                : '',
        'Password': _passwordController.text.trim(),
        'ConfirmPassword': _confirmPasswordController.text.trim(),
      });
      if (_profilePicture != null) {
        final extension = _profilePicture!.path.split('.').last.toLowerCase();
        final mimeType =
            extension == 'jpg' || extension == 'jpeg'
                ? 'image/jpeg'
                : extension == 'png'
                ? 'image/png'
                : extension == 'gif'
                ? 'image/gif'
                : extension == 'bmp'
                ? 'image/bmp'
                : extension == 'tiff'
                ? 'image/tiff'
                : extension == 'webp'
                ? 'image/webp'
                : 'image/avif';

        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            'ProfilePicture',
            _profilePicture!.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      print('Sending form-data: ${multipartRequest.fields}');

      // Send request
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print(e);
      String errorMessage =
          e.toString().contains("Exception: ")
              ? e.toString().replaceFirst("Exception: ", "")
              : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
      print(e.toString());
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
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

  // API Calls
  Future<bool> _sendOtp(String phoneNumber) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(
          '${AppUrls.appUrl}/api/Customer/ResendOtpforCreateAccount?PhoneOrEmail=$phoneNumber',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['message'] == 'OTP sent successfully') {
          _startTimer(); // Start timer on successful OTP send
          return true;
        }
        // Handle other messages or unexpected responses
        String errorMessage = jsonResponse['message'] ?? 'Failed to send OTP.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      // Handle non-200 status codes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.body}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Step Handlers
  void _handleStep1Next() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _currentStep = 2);
  }

  void _handleStep2Next() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final success = await _sendOtp(_mobileController.text.trim());
      setState(() => _isLoading = false);

      if (success) {
        setState(() => _currentStep = 3);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Try Again'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleStep3Submit() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP must be 6 digits.'),
          behavior: SnackBarBehavior.floating,

          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final registrationSuccess = await _registerUser();
      setState(() => _isLoading = false);

      if (registrationSuccess) {
        setState(() => _isAccountCreated = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isAccountCreated) {
          // If account is created, one back press should go to LoginPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          return false; // Prevent default back navigation, as we handled it
        } else if (_currentStep == 3) {
          setState(() {
            _currentStep = 1;
            _otpController.clear();
          });
          return false; // Prevent default back navigation
        } else {
          // Use pushReplacement to ensure clean navigation back to LoginPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          return false; // Prevent default back navigation as we handled it
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF2E7D32),
          body: Container(
            margin: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                // App Bar & Title
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset('assets/images/name_logo.png', height: 40),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child:
                          _isAccountCreated
                              ? _buildSuccessMessage(context)
                              : Column(
                                children: [
                                  // Header with back button and step indicator
                                  _buildStepHeader(context),
                                  const SizedBox(height: 10),

                                  // Content area
                                  Expanded(child: _buildCurrentStepContent()),

                                  // Next/Submit button
                                  if (!_isLoading)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        20,
                                      ),
                                      child: _buildActionButton(),
                                    ),

                                  RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: const TextStyle(
                                        color:
                                            Colors
                                                .black, // Default color for the text
                                        fontSize:
                                            16, // Adjust font size as needed
                                      ),
                                      children: [
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const LoginPage(),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Color(
                                                  0xFF2E7D32,
                                                ), // Specific color for "Login"
                                                fontWeight:
                                                    FontWeight
                                                        .bold, // Optional: make it bold
                                              ),
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
      ),
    );
  }

  // Update the _buildActionButton widget
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_currentStep == 1) {
            _handleStep2Next(); // This will now handle OTP sending
          } else if (_currentStep == 3) {
            _handleStep3Submit();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D7C3F),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          _currentStep == 1
              ? 'Next'
              : 'Create Account', // Only show these two options now
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Update the step header text to reflect the new flow
  Widget _buildStepHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (_currentStep == 3) {
              setState(() {
                _currentStep = 1;
                _otpController
                    .clear(); // Clear OTP when going back from OTP step
              });
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          },
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey.withOpacity(0.5),
              ), // Optional: specify color
              borderRadius: BorderRadius.circular(5),
            ),

            width: 40,
            height: 35, // This constrains the arrow container size
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15, // Icon size
              color: Colors.black,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              // Display "02/02" when on OTP step (which is internally _currentStep == 3)
              // and "01/02" when on Basic Info step (_currentStep == 1)
              "Step ${_currentStep == 3 ? '02' : _currentStep.toString().padLeft(2, '0')}/02",
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              _currentStep == 1 ? "Basic Information" : "OTP Verification",
              style: const TextStyle(color: Color(0xFF2E7D32)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _currentStep == 1
                        ? _buildBasicInfoStep()
                        : _buildOtpVerificationStep(),
              ),
            ),
          ),
        );
      },
    );
  }

  // Step 1: Basic Information
  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Please provide your basic details to register and activate your device.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 5),

        AvatarPicker(
          onImageSelected: (File? image) {
            setState(() {
              _profilePicture = image;
            });
          },
          initialImageFile: _profilePicture, // Pass the initial image here
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'First Name',
                'e.g. Ahmed',
                controller: _firstNameController,
                focusNode: _firstNameFocusNode,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ], // Add this

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter your First Name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                'Last Name',
                'e.g. Mutairi',
                controller: _lastNameController,
                focusNode: _lastNameFocusNode,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ], // Add this

                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null; // No error if empty or valid
                },
              ),
            ),
          ],
        ),

        _buildTextField(
          'Mobile Number',
          'e.g. +965 50123456',
          controller: _mobileController,
          focusNode: _mobileFocusNode,
          keyboardType: TextInputType.phone, // Ensure numeric keyboard
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Allow only numbers (0-9)
            LengthLimitingTextInputFormatter(10), // Max 10 digits
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your mobile number';
            }
            if (!RegExp(r'^[+0-9]{8,15}$').hasMatch(value)) {
              return 'Enter a valid phone number';
            }
            if (value.length != 10) {
              return 'Mobile number must be 10 digits';
            }
            return null;
          },
        ),
        _buildTextField(
          'Email Address',
          'e.g. ahmed@email.com',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            // If the field is empty, it's considered valid (not mandatory)
            if (value == null || value.isEmpty) {
              return null;
            }

            // If the user starts typing, then validate
            if (value.isNotEmpty) {
              // Check for consecutive dots (e.g., "user..name@domain.com")
              if (value.contains('..')) {
                return 'Email cannot contain consecutive dots';
              }

              // Ensure exactly one "@" symbol
              int atCount = '@'.allMatches(value).length;
              if (atCount != 1) {
                return 'Email must contain exactly one "@"';
              }

              // Split into local-part and domain
              List<String> parts = value.split('@');
              if (parts.length == 2) {
                String domainPart = parts[1]; // Everything after '@'

                // Ensure exactly one "." in the domain (e.g., "domain.com")
                int dotAfterAt = '.'.allMatches(domainPart).length;
                if (dotAfterAt != 1) {
                  return 'Only one dot (".") should be present after "@"';
                }
              }

              // Prevent "@" at start/end (e.g., "@domain.com" or "user@")
              if (value.startsWith('@') || value.endsWith('@')) {
                return 'Email cannot start or end with "@"';
              }

              // Prevent ".@" (e.g., "user.@domain.com")
              if (value.contains('.@')) {
                return 'Dot cannot be right before "@"';
              }

              // Final regex validation (covers most edge cases)
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+[a-zA-Z0-9]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email (e.g., example@domain.com)';
              }
            }

            return null; // Valid email
          },
        ),

        _buildPasswordField(
          'Password',
          'Enter a strong password',
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return 'Password must contain at least one special character';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Password must contain at least one uppercase letter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Password must contain at least one number';
            }
            return null;
          },
          isPasswordVisible: _isPasswordVisible,
          onVisibilityChanged: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),

        _buildPasswordField(
          'Confirm Password',
          'Re-enter your password',
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          isPasswordVisible:
              _isConfirmPasswordVisible, // Same visibility for both
          onVisibilityChanged: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),

        _buildTextField(
          'Civil ID Number',
          'e.g. 299010101010',
          controller: _civilIdController,
          focusNode: _civilIdFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                return 'Civil ID must be 12 digits';
              }
            }
            return null;
          },
        ),
        if (_civilIdController.text.length == 12)
          _buildTextField(
            'ID Expiry Date',
            'DD-MM-YYYY',
            controller: _idExpiryController,
            focusNode: _idExpiryFocusNode,
            readOnly: true, // Allow manual input
            keyboardType: TextInputType.datetime, // Suggest datetime keyboard
            onTap: () => _pickDate(context),

            validator: (value) {
              if (_civilIdController.text.length == 12 &&
                  (value == null || value.isEmpty)) {
                return 'ID Expiry Date is required';
              }
              if (value != null && value.isNotEmpty) {
                // Check for DD-MM-YYYY format
                if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(value)) {
                  return 'Enter date in DD-MM-YYYY format';
                }
                try {
                  // Parse the DD-MM-YYYY format correctly
                  final parts = value.split('-');
                  // Ensure correct parsing for DD-MM-YYYY
                  final parsedDate = DateTime(
                    int.parse(parts[2]), // year
                    int.parse(parts[1]), // month
                    int.parse(parts[0]), // day
                  );

                  // Check if date is today or in future
                  final tomorrow = DateTime.now().add(const Duration(days: 1));
                  final startOfTomorrow = DateTime(
                    tomorrow.year,
                    tomorrow.month,
                    tomorrow.day,
                  );
                  if (parsedDate.isBefore(startOfTomorrow)) {
                    return 'Expiry date must be Tomorrow or in the future';
                  }
                } catch (e) {
                  return 'Invalid date';
                }
              }
              return null;
            },
          ),
      ],
    );
  }

  // Step 2: Document Verification

  // Step 3: OTP Verification
  Widget _buildOtpVerificationStep() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTP Verification',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the 6-digit code sent to ${_mobileController.text}',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),

        Center(
          child: Pinput(
            length: 6,
            controller: _otpController,
            focusNode: _otpFocusNode,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyDecorationWith(
              border: Border.all(color: const Color(0xFF3B873E)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter the OTP';
              if (value.length != 6) return 'OTP must be 6 digits';
              return null;
            },
            showCursor: true,
            onCompleted: (pin) {
              if (_formKey.currentState!.validate()) {
                _handleStep3Submit();
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Time Remaining ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
                  _secondsRemaining == 0
                      ? () async {
                        final success = await _sendOtp(
                          _mobileController.text.trim(),
                        );
                        if (success) {
                          _otpController.clear(); // Clear the OTP field
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'OTP resent successfully'
                                  : 'Failed to resend OTP',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } // Missing curly brace was here
                      : null,
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Didn't receive OTP? ",
                      style: TextStyle(color: Colors.black, fontSize: 12),
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
    );
  }

  // Success Message
  Widget _buildSuccessMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/success.png", height: 100, width: 100),
          const SizedBox(height: 20),
          const Text(
            'Account Created Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Our team will review your request and activate your access soon. '
            'You\'ll receive a message once approved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 100,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Go to Login Page',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  Widget _buildTextField(
    String label,
    String hint, {
    FocusNode? focusNode,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters, // ✅ new optional param
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode, // Use the passed focusNode
            validator: validator,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            inputFormatters: inputFormatters, // ✅ applied here
            autovalidateMode:
                AutovalidateMode.onUserInteraction, // Added this line
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
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF3B873E),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFA1A1A1),
                fontSize: 14,
              ),
              errorStyle: const TextStyle(height: 0.8, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String? Function(T?)? validator,
    FocusNode? focusNode, // Add focusNode parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: DropdownButtonFormField<T>(
            focusNode: focusNode, // Pass focusNode here
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
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
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF3B873E),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFA1A1A1),
                fontSize: 14,
              ),
              errorStyle: const TextStyle(height: 0.8, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    String hint, {
    required TextEditingController controller,
    required String? Function(String?)? validator,
    FocusNode? focusNode,
    required bool isPasswordVisible, // Receive state from parent
    required VoidCallback onVisibilityChanged, // Callback for toggling
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: Column(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  validator: validator,
                  obscureText: !isPasswordVisible,
                  autovalidateMode:
                      AutovalidateMode.onUserInteraction, // Added this line
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
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B873E),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFA1A1A1),
                      fontSize: 14,
                    ),
                    // suffixIcon: IconButton(
                    //   icon: Icon(
                    //     isPasswordVisible
                    //         ? Icons.visibility
                    //         : Icons.visibility_off,
                    //     color: Colors.grey,
                    //   ),
                    //   onPressed: onVisibilityChanged, // Use parent's callback
                    // ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}
