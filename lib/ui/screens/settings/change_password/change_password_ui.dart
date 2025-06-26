import 'package:flutter/material.dart';
import 'package:prayerunitesss/model/api/change_password/change_password_model.dart';

import '../../../../service/api/change_password/change_password_service.dart';
import '../../../../service/api/templete_api/api_service.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/custom_appbar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final ChangePasswordService _service = ChangePasswordService(
    ApiService(baseUrl: AppUrls.appUrl),
  );

  Future<void> _changePassword() async {
    // Validate fields

    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if validation fails
    }

    setState(() => _isLoading = true);
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      final response = await _service.changePassword(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(response.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e.toString().contains("old password is not valid")) {
          errorMessage =
              "The current password you entered is incorrect. Please try again.";
        } else if (e.toString().contains(
          "Exception: Failed to change password: 400",
        )) {
          errorMessage =
              "Password change failed. Please enter your current password and try again.";
        } else {
          errorMessage =
              "An unexpected error occurred. Please try again later.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Change Password',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update your current password to keep your account secure.',
                style: TextStyle(color: Color(0xFF767676), fontSize: 12),
              ),
              const SizedBox(height: 20),
              Text(
                'Old Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: mediaQuery.size.width * 0.04,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                currentPasswordController,
                _obscureCurrent,
                (value) => setState(() => _obscureCurrent = !_obscureCurrent),
                hint: 'Enter your Old password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: mediaQuery.size.width * 0.04,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                newPasswordController,
                _obscureNew,
                (value) => setState(() => _obscureNew = !_obscureNew),
                hint: 'Enter your new password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
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
                  if (value == currentPasswordController.text) {
                    return 'New password cannot be the same as the old password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: mediaQuery.size.width * 0.04,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                confirmPasswordController, // You'll need to add this controller
                _obscureConfirm, // You'll need to add this state variable
                (value) => setState(() => _obscureConfirm = !_obscureConfirm),
                hint: 'Confirm your new password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your confirm password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  if (value == currentPasswordController.text) {
                    return 'New password cannot be the same as the old password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Update',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    bool obscureText,
    void Function(bool) toggleVisibility, {
    required String hint,
    String? Function(String?)? validator, // Add validator parameter
  }) {
    return TextFormField(
      // Changed from TextField to TextFormField
      controller: controller,
      obscureText: obscureText,
      validator: validator, // Add validator here
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA1A1A1)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey, // Set icon color to grey
          ),
          onPressed: () => toggleVisibility(!obscureText),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorMaxLines: 2, // To show full error message
      ),
    );
  }
}
