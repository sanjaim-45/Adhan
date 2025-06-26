// add_delivery_address_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../../model/api/address/shipping_address_create_model.dart';
import '../../../../service/api/address/shipping_address_add/shipping_address_create.dart';
import '../../../../service/api/address/shipping_address_add/shipping_address_update_api.dart';
import '../../../../service/api/templete_api/api_service.dart';
import '../../../../utils/font_mediaquery.dart';

class AddDeliveryAddressPage extends StatefulWidget {
  final ShippingAddress?
  existingAddress; // Use ShippingAddress instead of ShippingAddressss
  final bool isFirstAddress; // Add this new parameter

  const AddDeliveryAddressPage({
    super.key,
    this.existingAddress,
    this.isFirstAddress = false,
  });

  @override
  State<AddDeliveryAddressPage> createState() => _AddDeliveryAddressPageState();
}

class _AddDeliveryAddressPageState extends State<AddDeliveryAddressPage> {
  final ShippingAddressApiService _shippingAddressApiService;
  final ShippingAddressUpdateApiService _shippingAddressUpdateApiService;
  final _formKey = GlobalKey<FormState>();

  _AddDeliveryAddressPageState()
    : _shippingAddressApiService = ShippingAddressApiService(
        ApiService(baseUrl: AppUrls.appUrl),
      ),
      _shippingAddressUpdateApiService = ShippingAddressUpdateApiService(
        apiService: ApiService(baseUrl: AppUrls.appUrl),
      );

  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late bool isDefault;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing address data if available
    _fullNameController = TextEditingController(
      text: widget.existingAddress?.fullName ?? '',
    );
    _mobileNumberController = TextEditingController(
      text: widget.existingAddress?.phoneNumber ?? '',
    );
    _emailController = TextEditingController(
      text: widget.existingAddress?.email ?? '',
    );
    _addressController = TextEditingController(
      text: widget.existingAddress?.address ?? '',
    );

    // Set isDefault based on different scenarios
    if (widget.isFirstAddress) {
      // First address - always true and can't be changed
      isDefault = true;
    } else if (widget.existingAddress != null) {
      // Editing existing address - use its current value
      isDefault = widget.existingAddress!.isDefault;
    } else {
      // Adding subsequent address - default to false
      isDefault = false;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _shouldShowCheckbox() {
    // Don't show checkbox if:
    // 1. It's the first address (forced to be default)
    // 2. We're editing an existing default address
    if (widget.isFirstAddress ||
        (widget.existingAddress != null && widget.existingAddress!.isDefault)) {
      return false;
    }
    return true;
  }

  bool _isCheckboxEnabled() {
    // Checkbox should only be enabled when:
    // 1. Not the first address
    // 2. Not editing an existing default address
    return !widget.isFirstAddress &&
        !(widget.existingAddress != null && widget.existingAddress!.isDefault);
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.existingAddress != null) {
        // Update existing address
        await _shippingAddressUpdateApiService.updateShippingAddress(
          addressId: widget.existingAddress!.shippingAddressId,
          fullName: _fullNameController.text,
          phoneNumber: _mobileNumberController.text,
          email: _emailController.text,
          address: _addressController.text,
          makeDefault: isDefault,
        );
      } else {
        // Create new address
        await _shippingAddressApiService.createShippingAddress(
          fullName: _fullNameController.text,
          phoneNumber: _mobileNumberController.text,
          email: _emailController.text,
          address: _addressController.text,
          makeDefault: isDefault,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingAddress != null
                ? 'Address updated successfully'
                : 'Address created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true); // Return success
    } catch (e) {
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
    return Scaffold(
      resizeToAvoidBottomInset: true,

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
              surfaceTintColor: Colors.white,
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
              title: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  widget.existingAddress != null
                      ? 'Edit Address'
                      : 'Add Address',
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
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _buildTextField(
                        label: 'Full Name',
                        hint: 'e.g. Ahmed Al-Mutairi',
                        controller: _fullNameController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20), // Max 20 chars
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z]"),
                          ), // Allow letters only
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter full name';
                          }
                          // Check if it contains only letters and no spaces
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'No spaces allowed in full name';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Mobile Number',
                        hint:
                            'e.g. 5012345678', // Updated hint to show expected format
                        controller: _mobileNumberController,
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
                        maxLines: 3,
                        validator: (value) {
                          // Treat only spaces as empty
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter address';
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
                      if (_shouldShowCheckbox())
                        Row(
                          children: [
                            Checkbox(
                              value: isDefault,
                              onChanged:
                                  _isCheckboxEnabled()
                                      ? (val) {
                                        setState(() {
                                          isDefault = val ?? false;
                                        });
                                      }
                                      : null,
                            ),
                            Text("Make this my default Address"),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.existingAddress != null
                                  ? 'Update Address'
                                  : 'Save Address',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
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
