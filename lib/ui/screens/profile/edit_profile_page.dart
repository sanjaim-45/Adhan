import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:provider/provider.dart';
import '../../../model/api/customer/customer.dart';
import '../../../model/api/edit_customer/edit_customer_api_model.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../../../service/api/customer/customer_service_api.dart';
import '../../../utils/font_mediaquery.dart';

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
  late CustomerService _customerService;
  Customer? customer;
  bool isLoading = true;
  bool isUpdating = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _civilIdController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(baseUrl: AppUrls().appUrl);
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    try {
      setState(() => isLoading = true);
      final data = await _customerService.getCustomerById(widget.customerId);
      final Customer fetchedCustomer = Customer.fromJson(data['data']);

      setState(() {
        customer = fetchedCustomer;
        _fullNameController.text = '${fetchedCustomer.firstName} ${fetchedCustomer.lastName}';
        _mobileNumberController.text = fetchedCustomer.phoneNumber ?? '';
        _emailController.text = fetchedCustomer.email ?? '';
        _locationController.text = 'Kuwait City, Kuwait';
        _civilIdController.text = fetchedCustomer.civilId ?? '';
        _passportController.text = fetchedCustomer.passportNumber ?? '';
        isLoading = false;
      });
    } on Exception catch (e) {
      setState(() => isLoading = false);
      if (e.toString().contains('Authentication failed')) {
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

    Future<void> _handleUpdate() async {
      if (!_formKey.currentState!.validate()) return;

      final nameParts = _fullNameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final request = EditCustomerRequest(
        customerId: widget.customerId,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: _mobileNumberController.text.trim(),
        email: _emailController.text.trim(),
        civilId:
            _civilIdController.text.trim().isNotEmpty
                ? _civilIdController.text.trim()
                : null,
        passportNumber:
            _passportController.text.trim().isNotEmpty
                ? _passportController.text.trim()
                : null,
      );

      setState(() {
        isUpdating = true;
      });

      try {
        final response = await _customerService.editCustomer(request);

        if (!mounted) return;

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Combine first name and last name into full name
        final fullName = '$firstName $lastName'.trim();

        // Update UserDetailsProvider with the new details
        final userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);
        await userDetailsProvider.updateUserDetails(
          fullName: fullName,
          mosque: userDetailsProvider.userDetails?.mosque ?? '',
          mosqueLocation: userDetailsProvider.userDetails?.mosqueLocation ?? '',
        );
        // Navigate back after a short delay to allow the snackbar to be visible
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            isUpdating = false;
          });
        }
      }
    }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _civilIdController.dispose();
    _passportController.dispose();
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

    return Scaffold(
      backgroundColor: Colors.white,
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
            leadingWidth: 30,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: screenWidth * 0.043),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              'Edit Profile',
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
                buildAvatar(customer?.profileImageUrl),
                SizedBox(height: 16),
                _buildTextField(
                  'Full Name',
                  'e.g. Ahmed Al-Mutairi',
                  context,
                  controller: _fullNameController,
                  isRequired: true,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  'Mobile Number',
                  'e.g. +965 50123456',
                  context,
                  controller: _mobileNumberController,
                  isRequired: true,
                  validator: _validatePhoneNumber,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  'Email Address',
                  'e.g. ahmed@email.com',
                  context,
                  controller: _emailController,
                  isRequired: true,
                  validator: _validateEmail,
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
                  controller: _civilIdController,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  'Passport Number',
                  '8122 3554 1228',
                  context,
                  controller: _passportController,
                  isReadOnly: true,
                ),
                SizedBox(height: 24),
                _buildUpdateButton(context),
                SizedBox(height: screenHeight * 0.04),
              ],
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
    String? Function(String?)? validator,
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
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly,
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
                color: isReadOnly ? Colors.black : const Color(0xFFA1A1A1),
                fontSize: getFontRegularSize(context),
                letterSpacing: -0.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: GoogleFonts.beVietnamPro(letterSpacing: -0.5),
          ),
        ),
      ],
    );
  }
}

Widget buildAvatar([String? imageUrl]) {
  return Stack(
    alignment: Alignment.topLeft,
    children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.green.shade50,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child:
            imageUrl == null
                ? Icon(Icons.person, size: 40, color: Colors.green.shade200)
                : null,
      ),
      Positioned(
        bottom: 4,
        left: 55,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D7C3F),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
        ),
      ),
    ],
  );
}
