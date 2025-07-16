import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../service/api/address/shipping_address_add/shipping_address_create.dart';
import '../../../../service/api/templete_api/api_service.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/font_mediaquery.dart';

class AddNewAddressPage extends StatefulWidget {
  final bool isFirstAddress; // Add this parameter

  const AddNewAddressPage({
    super.key,
    this.isFirstAddress = false, // Default to false
  });

  @override
  _AddNewAddressPageState createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  final _fullNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool isDefault = false;
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _mobileNumberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool isCheckboxEnabled = true;

  final ShippingAddressApiService _shippingAddressApiService;

  _AddNewAddressPageState()
    : _shippingAddressApiService = ShippingAddressApiService(
        ApiService(baseUrl: AppUrls.appUrl),
      );
  @override
  void initState() {
    super.initState();
    // If it's the first address, set as default and disable checkbox
    if (widget.isFirstAddress) {
      isDefault = true;
      isCheckboxEnabled = false;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _fullNameFocusNode.dispose();
    _mobileNumberFocusNode.dispose();
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();

    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await _shippingAddressApiService.createShippingAddress(
        fullName: _fullNameController.text,
        phoneNumber: _mobileNumberController.text,
        email: _emailController.text,
        address: _addressController.text,
        makeDefault: isDefault,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back if successful
      Navigator.of(context).pop(true);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
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
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leadingWidth: 70,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      margin: const EdgeInsets.all(10),
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
                title: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text(
                    'Add New Address',
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
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      _buildTextField(
                        label: 'Full Name',
                        hint: 'e.g. Ahmed Al-Mutairi',
                        controller: _fullNameController,
                        focusNode: _fullNameFocusNode,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30), // Max 20 chars

                          FilteringTextInputFormatter.allow(
                            RegExp(r"^[a-zA-Z][a-zA-Z\s]*$"),
                          ), // Allow letters only
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter full name';
                          }
                          // Check if the name starts with a space
                          if (value.startsWith(' ')) {
                            return 'Full name cannot start with a space';
                          }
                          if (value.length < 3) {
                            return 'Full name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Mobile Number',
                        hint:
                            'e.g. 5012345678', // Updated hint to show expected format
                        controller: _mobileNumberController,
                        focusNode: _mobileNumberFocusNode,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            10,
                          ), // Strictly 10 digits
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile number';
                          }
                          if (value.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          // Optional: Check if starts with valid Kuwaiti prefix (5,6,9)
                          // if (!RegExp(r'^[569]').hasMatch(value)) {
                          //   return 'Mobile number should start with 5, 6, or 9';
                          // }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Email Address',
                        hint: 'e.g. ahmed@email.com',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }

                          // Trim the value to remove leading/trailing whitespace
                          final trimmedValue = value.trim();

                          // Basic checks
                          if (trimmedValue.contains('..')) {
                            return 'Email cannot contain consecutive dots';
                          }

                          if (trimmedValue.startsWith('@') ||
                              trimmedValue.endsWith('@')) {
                            return 'Email cannot start or end with "@"';
                          }

                          if (trimmedValue.contains('.@')) {
                            return 'Dot cannot be right before "@"';
                          }

                          // Check for exactly one @
                          final atCount = '@'.allMatches(trimmedValue).length;
                          if (atCount != 1) {
                            return 'Email must contain exactly one "@"';
                          }

                          // Split and validate parts
                          final parts = trimmedValue.split('@');
                          if (parts.length != 2) {
                            return 'Invalid email format';
                          }

                          // Validate domain part
                          final domainPart = parts[1];
                          if (domainPart.isEmpty) {
                            return 'Domain part after "@" cannot be empty';
                          }

                          if (!domainPart.contains('.')) {
                            return 'Domain must contain a dot (".") after "@"';
                          }

                          if (domainPart.startsWith('.') ||
                              domainPart.endsWith('.')) {
                            return 'Domain cannot start or end with a dot';
                          }

                          // Final regex validation
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            caseSensitive: false,
                          );

                          if (!emailRegex.hasMatch(trimmedValue)) {
                            return 'Enter a valid email (e.g., example@domain.com)';
                          }

                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Home Address',
                        hint: 'e.g. 123 Main St, Kuwait City',
                        controller: _addressController,
                        focusNode: _addressFocusNode,
                        maxLines: 3,
                        validator: (value) {
                          // Treat only spaces as empty
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter address';
                          }
                          if (value.trim().length < 10) {
                            return 'Address must be at least 10 characters long';
                          }
                          // Optional: if you want to ensure it's not just numbers or symbols
                          if (!RegExp(
                            r"^[A-Za-z0-9\s,./-]+$",
                          ).hasMatch(value)) {
                            return 'Enter a valid address';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 24, // Checkbox width
                            height: 24, // Checkbox height
                            child: Stack(
                              children: [
                                Checkbox(
                                  value: isDefault,
                                  onChanged: (val) {
                                    setState(() {
                                      isDefault = val ?? false;
                                    });
                                  },
                                ),
                                if (!isCheckboxEnabled)
                                  Positioned.fill(
                                    child: Container(color: Colors.transparent),
                                  ),
                              ],
                            ),
                          ),
                          const Text("Make this my default Address"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _fullNameFocusNode.unfocus();
                        _mobileNumberFocusNode.unfocus();
                        _emailFocusNode.unfocus();
                        _addressFocusNode.unfocus();
                        _saveAddress();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Address',
                        style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A4354),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            inputFormatters: inputFormatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Color(0xFFA1A1A1)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color(0xFF2E7D32),
                ), // Focused color
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     appBar: PreferredSize(
//       preferredSize: const Size.fromHeight(80),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.only(
//             top: 20.0,
//           ), // Add padding to push content down
//           child: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leadingWidth: 70,
//             leading: Padding(
//               padding: const EdgeInsets.only(left: 10.0),
//               child: GestureDetector(
//                 onTap: () => Navigator.of(context).pop(),
//                 child: Container(
//                   margin: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: Colors.grey.withOpacity(0.5),
//                     ), // Optional: specify color
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//
//                   width: 40,
//                   height: 15, // This constrains the arrow container size
//                   child: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     size: 15, // Icon size
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//             title: Padding(
//               padding: const EdgeInsets.only(
//                 top: 0.0,
//               ), // Adjust title position if needed
//               child: Text(
//                 'Delivery Address',
//                 style: GoogleFonts.beVietnamPro(
//                   color: Colors.black,
//                   letterSpacing: -0.5,
//                   fontSize: getDynamicFontSize(context, 0.05),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//     body: Padding(
//       padding: const EdgeInsets.fromLTRB(
//         16.0,
//         16.0,
//         16.0,
//         0,
//       ), // Adjust bottom padding to 0
//       child: Column(
//         // Changed from ListView to Column
//         children: <Widget>[
//           Expanded(
//             // Wrap the scrollable content in Expanded
//             child: ListView(
//               children: <Widget>[
//                 _buildTextField(
//                   label: 'Full Name',
//                   hint: 'e.g. Ahmed Al-Mutairi',
//                   controller: _fullNameController,
//                 ),
//                 _buildTextField(
//                   label: 'Mobile Number',
//                   hint: 'e.g. +965 50123456',
//                   controller: _mobileNumberController,
//                   keyboardType: TextInputType.phone,
//                 ),
//                 _buildTextField(
//                   label: 'Email Address',
//                   hint: 'e.g. ahmed@email.com',
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 _buildTextField(
//                   label: 'Home Address',
//                   hint: 'e.g. 123 Main St, Kuwait City',
//                   controller: _addressController,
//                   maxLines: 3,
//                 ),
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: isDefault,
//                       onChanged: (val) {
//                         setState(() {
//                           isDefault = val ?? false;
//                         });
//                       },
//                     ),
//                     Text("Make this my default Address"),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           Padding(
//             // Add padding for the button
//             padding: const EdgeInsets.only(bottom: 16.0),
//             child: SizedBox(
//               height: 56,
//               width: double.infinity, // Make button take full width
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Add save logic here
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF2E7D32),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'Save Address',
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
