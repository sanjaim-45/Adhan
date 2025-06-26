//Setting

import 'package:flutter/material.dart';
import 'package:prayerunitesss/service/api/delete_account/delete_account_service.dart';
import 'package:prayerunitesss/ui/screens/settings/change_password/change_password_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../service/api/login/login_page_api.dart';
import '../../../service/api/templete_api/api_service.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/custom_appbar.dart';
import '../../../utils/font_mediaquery.dart';
import '../login_page/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEnglish = true;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preferred Language Section
          Text(
            'Preferred Language',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: getFontRegular55Size(context),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select the language you'd like to use for this App.",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: screenWidth * 0.0356,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arabic',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.0356,
                      ),
                    ),
                    SwitchTheme(
                      data: SwitchThemeData(
                        thumbColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          return Colors.white;
                        }),
                        trackColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return Color(0xFF3B873E);
                          }
                          return Color(0xFFF2F4F7);
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.transparent;
                              }
                              return Colors.transparent;
                            }),
                        trackOutlineWidth:
                            WidgetStateProperty.resolveWith<double>((states) {
                              return 0.0;
                            }),
                      ),
                      child: Switch(
                        value: !isEnglish,
                        onChanged: (value) {
                          setState(() {
                            isEnglish = false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'English',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.0356,
                      ),
                    ),
                    SwitchTheme(
                      data: SwitchThemeData(
                        thumbColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          return Colors.white;
                        }),
                        trackColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return Color(0xFF3B873E);
                          }
                          return Color(0xFFF2F4F7);
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.transparent;
                              }
                              return Colors.transparent;
                            }),
                        trackOutlineWidth:
                            WidgetStateProperty.resolveWith<double>((states) {
                              return 0.0;
                            }),
                      ),
                      child: Switch(
                        value: isEnglish,
                        onChanged: (value) {
                          setState(() {
                            isEnglish = true;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Section
          Text(
            'Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: getFontRegular55Size(context),
            ),
          ),
          const SizedBox(height: 8),
          _buildAccountTile(
            'assets/images/change_password.png',
            'Change Password',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
            context: context,
          ),
          _buildAccountTile(
            'assets/images/delete_my_account.png',
            'Delete My Account',
            iconColor: Colors.green,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final customerIdString = prefs.getString('customerId');

              if (customerIdString != null) {
                final customerId = int.parse(customerIdString);
                return showDeleteAccountBottomSheet(context, customerId);
              }
            },
            context: context,
          ),

          const SizedBox(height: 24),

          // Policies & Support
          Text(
            'Policies & Support',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: getFontRegular55Size(context),
            ),
          ),
          const SizedBox(height: 8),
          _buildPolicyTile(
            'assets/images/terms_and_conditions.png',
            'Terms & Conditions',
          ),
          _buildPolicyTile('assets/images/privacy.png', 'Privacy Policy'),
        ],
      ),
      backgroundColor: Color(0xFFF8F8F8),
    );
  }

  Widget _buildAccountTile(
    String imagePath,
    String title, {
    Color iconColor = Colors.green,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          color: iconColor,
          width: 32,
          height: 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.0356,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPolicyTile(String imagePath, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          color: Colors.green,
          width: 32,
          height: 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.0356,
          ),
        ),
        onTap: () {
          // TODO: Navigate or perform action
        },
      ),
    );
  }

  void showDeleteAccountBottomSheet(BuildContext context, int customerId) {
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close, size: 20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Trash Icon
              Image.asset(
                "assets/images/delete_account_ui.png",
                height: 120,
                width: 130,
              ),
              SizedBox(height: 16),
              // Title
              Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: getFontRegular55Size(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              // Description
              Text(
                'Your account will be deleted. If you change your mind, you can log back in before the process is complete to cancel the request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.0356,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final apiService = DeleteAccountService(
                      ApiService(baseUrl: AppUrls.appUrl),
                    );
                    final success = await apiService.deleteCustomerAccount(
                      customerId,
                    );

                    if (success) {
                      await LoginService.logout(context);

                      Navigator.of(context).pop(); // Close the bottom sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account deleted successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Navigate to LoginPage and remove all previous routes
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete account'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Confirm Account Deletion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.0356,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
