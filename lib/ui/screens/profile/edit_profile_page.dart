import 'dart:convert';
import 'dart:io';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:prayerunitesss/ui/screens/login_page/login_page.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:provider/provider.dart';

import '../../../model/api/customer/customer.dart';
import '../../../model/api/edit_customer/edit_customer_api_model.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../../../service/api/customer/customer_service_api.dart';
import '../../../service/api/otp_service/otp_service.dart';
import '../../../utils/custom_appbar.dart';
import '../../../utils/font_mediaquery.dart';
import 'change_email_otp_verification.dart';
import 'edit_widgets/change_phone_number_otp_verification.dart';

class EditProfilePage extends StatefulWidget {
  final int customerId;

  const EditProfilePage({super.key, required this.customerId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  String? selectedValue = 'English';
  List<String> items = ['English', 'Arabic'];
  late CustomerServices _customerService;
  Customer? customer;
  bool isLoading = true;
  bool isUpdating = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _civilIdController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _idExpiryController = TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _mobileNumberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _civilIdFocusNode = FocusNode();
  final FocusNode _passportFocusNode = FocusNode();
  final FocusNode _idExpiryFocusNode = FocusNode();
  DateTime selectedDate = DateTime.now();

  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();
  final List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'tiff',
    'webp',
    'avif',
  ];
  void _pickDate(BuildContext context) {
    DateTime initialPickerDate;
    if (_idExpiryController.text.isNotEmpty) {
      try {
        initialPickerDate = DateFormat(
          'dd-MM-yyyy',
        ).parse(_idExpiryController.text);
        // Ensure the initial date is not before tomorrow
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        if (initialPickerDate.isBefore(tomorrow)) {
          initialPickerDate = tomorrow;
        }
      } catch (e) {
        // Fallback to tomorrow if parsing fails
        initialPickerDate = DateTime.now().add(const Duration(days: 1));
      }
    } else {
      initialPickerDate = DateTime.now().add(const Duration(days: 1));
    }

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
      initialDateTime: initialPickerDate,
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final extension = image.path.split('.').last.toLowerCase();

      if (!_allowedExtensions.contains(extension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a valid image format (JPG, PNG, etc.)',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return; // Reject the file
      }

      setState(() {
        _selectedImageFile = File(image.path); // Accept only allowed formats
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _customerService = CustomerServices(baseUrl: AppUrls.appUrl);
    _fetchCustomerData();
    _civilIdController.addListener(() {
      if (_civilIdController.text.length == 12) {
        setState(() {});
      } else {
        setState(() {
          // If Civil ID is not 12 digits (or empty), clear ID Expiry Date
          _idExpiryController.clear();
        });
      }
    });
  }

  Future<void> _fetchCustomerData() async {
    try {
      setState(() => isLoading = true);
      final data = await _customerService.getCustomerById();
      final Customer fetchedCustomer = Customer.fromJson(data['data']);

      setState(() {
        customer = fetchedCustomer;
        _fullNameController.text =
            '${fetchedCustomer.firstName} ${fetchedCustomer.lastName}';
        _mobileNumberController.text = fetchedCustomer.phoneNumber ?? '';
        _emailController.text = fetchedCustomer.email ?? '';
        _locationController.text = 'Kuwait City, Kuwait';
        _civilIdController.text = fetchedCustomer.civilId ?? '';
        _passportController.text = fetchedCustomer.passportNumber ?? '';
        if (fetchedCustomer.civilIdExpiryDate != null) {
          final formattedDate = DateFormat(
            'dd-MM-yyyy',
          ).format(fetchedCustomer.civilIdExpiryDate!);
          _idExpiryController.text = formattedDate;
        } else {
          _idExpiryController.text = '';
        }

        isLoading = false;
      });
    } on Exception catch (e) {
      setState(() => isLoading = false);
      if (e.toString().contains('Authentication failed')) {
        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUpdating = true);

    try {
      final String civilIdText = _civilIdController.text.trim();
      final String idExpiryText = _idExpiryController.text.trim();
      final bool isCivilIdEmpty = civilIdText.isEmpty;
      DateTime? parsedExpiryDate;
      if (!isCivilIdEmpty && idExpiryText.isNotEmpty) {
        try {
          parsedExpiryDate = DateFormat('dd-MM-yyyy').parse(idExpiryText);
        } catch (e) {
          // Handle parsing error if needed
          print('Error parsing date: $e');
        }
      }
      final response = await _customerService.editCustomer(
        EditCustomerRequest(
          customerId: widget.customerId,
          firstName:
              _fullNameController.text.trim().split(' ').isNotEmpty
                  ? _fullNameController.text.trim().split(' ').first
                  : '',
          lastName:
              _fullNameController.text.trim().split(' ').length > 1
                  ? _fullNameController.text
                      .trim()
                      .split(' ')
                      .sublist(1)
                      .join(' ')
                  : '',
          phoneNumber: _mobileNumberController.text.trim(),
          email: _emailController.text.trim(),
          civilId: isCivilIdEmpty ? null : civilIdText,
          passportNumber:
              _passportController.text.trim().isNotEmpty
                  ? _passportController.text.trim()
                  : null,
          status: true,
          userTypeId: 2,
          profileImagePath: _selectedImageFile?.path,
          civilIdExpiryDate: parsedExpiryDate, // Otherwise, parse the date
        ),
        profileImage: _selectedImageFile,
      );

      if (!mounted) return;

      final responseBody = jsonDecode(response.body);
      final newImagePath =
          responseBody['profileImagePath'] ?? _selectedImageFile?.path;

      // Update user details
      final userDetailsProvider = Provider.of<UserDetailsProvider>(
        context,
        listen: false,
      );
      await userDetailsProvider.updateUserDetails(
        fullName: _fullNameController.text.trim(),
        mosque: userDetailsProvider.userDetails?.mosque ?? '',
        mosqueLocation: userDetailsProvider.userDetails?.mosqueLocation ?? '',
        profileImage: newImagePath,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Return the new image path to the previous screen
      // Pass a map containing all updated details
      Navigator.of(context).pop({
        'imagePath': newImagePath,
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _mobileNumberController.text.trim(),
        // Add other details as needed
      });
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  // String? _validateEmail(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Email is required';
  //   }
  //   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
  //     return 'Please enter a valid email';
  //   }
  //   return null;
  // }

  // String? _validatePhoneNumber(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Phone number is required';
  //   }
  //   if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
  //     return 'Please enter a valid phone number';
  //   }
  //   return null;
  // }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _civilIdController.dispose();
    _passportController.dispose();
    _idExpiryController.dispose();
    _fullNameFocusNode.dispose();
    _mobileNumberFocusNode.dispose();
    _emailFocusNode.dispose();
    _locationFocusNode.dispose();
    _civilIdFocusNode.dispose();
    _passportFocusNode.dispose();
    _idExpiryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final otpService = OtpService(
      apiService: ApiService(baseUrl: AppUrls.appUrl),
    );

    return AbsorbPointer(
      absorbing: isUpdating,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: 'Edit Profile',
            onBack: () => Navigator.of(context).pop(),
          ),

          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    buildAvatar(
                      customer != null && customer!.profileImageUrl != null
                          ? '${AppUrls.appUrl}/${customer!.profileImageUrl}'
                          : null,
                      _selectedImageFile,
                      _pickImage,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Full Name',
                      'e.g. Ahmed Al-Mutatis',
                      context,
                      controller: _fullNameController,
                      isRequired: true,
                      focusNode: _fullNameFocusNode,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full Name is required';
                        }
                        // Trim the value to remove leading/trailing spaces before validation
                        final trimmedValue = value.trim();
                        if (trimmedValue.length < 3) {
                          return 'Full Name must be at least 3 characters';
                        }
                        // Check for numbers in the trimmed value
                        if (RegExp(r'[^a-zA-Z\s]').hasMatch(trimmedValue)) {
                          return 'Full Name cannot contain numbers';
                        }
                        // Check for symbols (excluding spaces and allowing only alphabets) in the trimmed value
                        if (RegExp(r'[^a-zA-Z\s]').hasMatch(trimmedValue)) {
                          return 'Full Name cannot contain numbers';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Mobile Number',
                      'e.g. +965 50123456',
                      context,
                      isReadOnly: true,

                      controller: _mobileNumberController,
                      focusNode: _mobileNumberFocusNode,
                      isRequired: true,
                      suffixWidget: TextButton(
                        // In EditProfilePage's build method, update the Change button onPressed:
                        onPressed: () async {
                          final newNumber = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChangePhoneNumberOtpVerification(
                                    mobileNumber: _mobileNumberController.text,
                                    otpService: otpService,
                                  ),
                            ),
                          );

                          if (newNumber != null && mounted) {
                            setState(() {
                              _mobileNumberController.text = newNumber;
                            });

                            // Optionally refresh customer details
                            await _fetchCustomerData();
                          }
                        },

                        child: Text(
                          'Change',
                          style: GoogleFonts.beVietnamPro(
                            color: Color(0xFF2E7D32),
                            fontSize: getFontRegularSize(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Email Address',
                      'e.g. ahmed@email.com',
                      context,
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      isReadOnly: true,

                      // validator: _validateEmail,
                      suffixWidget: TextButton(
                        onPressed: () async {
                          // Navigate to another page
                          final newEmail = Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UpdateEmailPage(
                                    email: _emailController.text,
                                    otpService: otpService,
                                  ),
                            ),
                          );

                          if (newEmail != null && mounted) {
                            setState(() async {
                              _emailController.text = await newEmail;
                            });

                            // Optionally refresh customer details
                            await _fetchCustomerData();
                          }
                        },
                        child: Text(
                          _emailController.text.isEmpty ? 'Add' : 'Change',
                          style: GoogleFonts.beVietnamPro(
                            color: Color(0xFF2E7D32),
                            fontSize: getFontRegularSize(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextFieldDropDown(
                      "Preferred Language",
                      "e.g. English,Arabic",
                      context,
                      selectedValue: selectedValue,
                      items: items,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Civil Id',
                      '2553 3335 4233',
                      context,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      controller: _civilIdController,
                      focusNode: _civilIdFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // Return null if the field is empty and not required
                        }
                        if (value.isNotEmpty && value.length != 12) {
                          return 'Civil ID must be exactly 12 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length == 12) {
                          setState(() {});
                        } else {
                          // If Civil ID length is not 12
                          setState(() {
                            _idExpiryController.clear(); // Clear ID Expiry Date
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    if (_civilIdController.text.length == 12)
                      _buildTextField(
                        'ID Expiry Date',
                        'DD-MM-YYYY',
                        context,
                        controller: _idExpiryController,
                        focusNode: _idExpiryFocusNode,
                        isReadOnly: true, // Allow manual input
                        keyboardType:
                            TextInputType.datetime, // Suggest datetime keyboard
                        onTap: isUpdating ? null : () => _pickDate(context),
                        validator: (value) {
                          if (_civilIdController.text.length == 12 &&
                              (value == null || value.isEmpty)) {
                            return 'ID Expiry Date is required';
                          }
                          if (value != null && value.isNotEmpty) {
                            // Check for DD-MM-YYYY format
                            if (!RegExp(
                              r'^\d{2}-\d{2}-\d{4}$',
                            ).hasMatch(value)) {
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
                              final tomorrow = DateTime.now().add(
                                const Duration(days: 1),
                              );
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
                    // _buildTextField(
                    //   'Passport Number',
                    //   '8122 3554 1228',
                    //   context,
                    //   controller: _passportController,
                    //   isReadOnly: true,
                    // ),
                    // SizedBox(height: 24),
                    _buildUpdateButton(context),
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isUpdating ? null : _handleUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D7C3F),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child:
            isUpdating
                ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
                : Text(
                  'Update',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: getFontRegularSize(context),
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildTextFieldDropDown(
    String label,
    String hint,
    BuildContext context, {
    required String? selectedValue,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
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
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: Theme(
            data: Theme.of(
              context,
            ).copyWith(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedValue,
              items:
                  items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.beVietnamPro(letterSpacing: -0.5),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
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
                  color: const Color(0xFFA1A1A1),
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: GoogleFonts.beVietnamPro(
                letterSpacing: -0.5,
                fontSize: getFontRegularSize(context),
                color: Colors.black,
              ),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    BuildContext context, {
    TextEditingController? controller,
    bool isReadOnly = false,
    bool isRequired = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    Widget? suffixWidget, // This will now appear inside the input box
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.w600,
                fontSize: getFontRegularSize(context),
                letterSpacing: -0.5,
              ),
            ),
            if (isRequired)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('*', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: isReadOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            inputFormatters: inputFormatters,
            autovalidateMode:
                AutovalidateMode.onUserInteraction, // Added this line
            onChanged: onChanged,
            validator:
                validator ??
                (isRequired
                    ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    }
                    : null),
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
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              hintText: hint,
              hintStyle: GoogleFonts.beVietnamPro(
                color: Colors.grey.shade400,
                fontSize: getFontRegularSize(context),
                letterSpacing: -0.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: suffixWidget, // Place the widget inside the input box
            ),
            style: GoogleFonts.beVietnamPro(letterSpacing: -0.5),
          ),
        ),
      ],
    );
  }
}

Widget buildAvatar([
  String? imageUrl,
  File? imageFile,
  VoidCallback? onCameraTap,
]) {
  const fallbackImage =
      "https://t3.ftcdn.net/jpg/06/19/26/46/360_F_619264680_x2PBdGLF54sFe7kTBtAvZnPyXgvaRw0Y.jpg";

  Widget imageWidget;

  if (imageFile != null) {
    imageWidget = ClipOval(
      child: Image.file(imageFile, width: 80, height: 80, fit: BoxFit.cover),
    );
  } else if (imageUrl != null && imageUrl.isNotEmpty) {
    imageWidget = ClipOval(
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            fallbackImage,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  } else {
    imageWidget = ClipOval(
      child: Image.network(
        fallbackImage,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  return Stack(
    alignment: Alignment.topLeft,
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black, // Specify your border color here
            width: 3, // Specify the border width
          ),
        ),
        child: imageWidget,
      ),
      if (onCameraTap != null)
        Positioned(
          bottom: 4,
          left: 55,
          child: GestureDetector(
            onTap: onCameraTap,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2D7C3F),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.camera_alt,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
    ],
  );
}
