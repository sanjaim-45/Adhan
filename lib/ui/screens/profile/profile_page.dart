import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayerunitesss/service/api/customer/customer_service_api.dart';
import 'package:prayerunitesss/ui/widgets/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/subscription/subscription_provider.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../../../service/api/login/login_page_api.dart';
import '../../../service/api/templete_api/api_service.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/font_mediaquery.dart';
import '../about_us/about_us.dart';
import '../contact/contact_us.dart';
import '../login_page/login_page.dart';
import '../settings/delivery_address/delivery_address_page.dart';
import '../settings/delivery_address/my_orders/my_requests.dart';
import '../settings/delivery_address/my_orders/orders_ui.dart';
import '../settings/settings_ui.dart';
import '../subscription/subscription.dart';
import '../transaction/transaction_history.dart';
import 'edit_profile_page.dart';
import 'notification_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSubscription();
    });
    _fetchCustomerDetails();
  }

  CustomerDetails? _userDetails;
  bool _isLoading = true;

  Future<void> _fetchCustomerDetails() async {
    try {
      setState(() => _isLoading = true);

      final customerService = CustomerServices(baseUrl: AppUrls.appUrl);
      final prefs = await SharedPreferences.getInstance();
      // Safely get customerId as a string and then parse it
      final customerIdString = prefs.getString('customerId');
      int? customerId;
      if (customerIdString != null) {
        customerId = int.tryParse(customerIdString);
      }

      if (customerId == null) {
        setState(() {
          _isLoading = false;
          _userDetails = null;
        });
        return;
      }

      final response = await customerService.getCustomerById();

      if (response != null && response['data'] != null) {
        setState(() {
          _userDetails = CustomerDetails.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _userDetails = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching customer: $e');
      setState(() {
        _userDetails = null;
        _isLoading = false;
      });
    }
  }

  // Centralized logout function
  Future<void> _performLogout(BuildContext context) async {
    // Store context in a variable to ensure we use the same one
    final navigator = Navigator.of(context);

    try {
      // Close the initial confirmation dialog
      navigator.pop();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform logout operations
      await LoginService.logout(context);

      navigator.pop(); // Close loading dialog

      await Future.delayed(Duration(milliseconds: 100));

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (navigator.canPop()) {
        navigator.pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,

          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshSubscription() async {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );
    final apiService = Provider.of<ApiService>(context, listen: false);

    // Force refresh the subscription data
    await subscriptionProvider.fetchSubscription(
      apiService,
      forceRefresh: true,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Title
                  Text(
                    "Logout?",
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Message
                  Text(
                    "Are you sure you want to sign out?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Logout Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _performLogout(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.red[400],
                          ),
                          child: Text(
                            "Logout",
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final authProvider = Provider.of<AuthProvider>(context);
    final userDetails = Provider.of<UserDetailsProvider>(context).userDetails;
    final userDetailsProvider = Provider.of<UserDetailsProvider>(context);
    final subscription = userDetailsProvider.userDetails?.subscription;

    return PopScope(
      canPop: false, // Disable default back button behavior
      onPopInvoked: (didPop) {
        if (didPop) return;
        navigateToHomeScreen(context); // Force navigation to ProfileScreen
      },
      child: Scaffold(
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
              automaticallyImplyLeading: false, // Add this line
              surfaceTintColor: Colors.white,
              title: Text(
                'My Profile',
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegular55Size(context),
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            children: [
              SizedBox(height: width * 0.03),
              Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade100,
                ),
                child: Builder(
                  builder: (context) {
                    // Loading state
                    if (_isLoading) {
                      return _buildShimmerLoading(context);
                    }

                    // No user data state

                    final width = MediaQuery.of(context).size.width;
                    final height = MediaQuery.of(context).size.height;

                    return Row(
                      children: [
                        // Profile Avatar - Check for null before using _userDetails
                        if (_userDetails != null)
                          _buildProfileAvatar(_userDetails!, context)
                        else
                          const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person),
                          ), // Placeholder if null

                        SizedBox(width: width * 0.04),

                        // User Details Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Name
                              Text(
                                _userDetails != null
                                    ? "${_userDetails!.firstName} ${_userDetails!.lastName}"
                                    : "User Name",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: getFontRegular55Size(context),
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 10),
                              // Mosque Name with Icon
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/profile/report_issue.png",
                                    height: height * 0.020,
                                    width: width * 0.05,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _userDetails?.phoneNumber ??
                                        "+965 12345678",
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.green,
                                      fontSize: getFontRegular35Size(context),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Edit Profile Button
                        _buildEditProfileButton(context),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(height: 10),
              buildTile(
                context,
                "assets/images/profile/notificaton.png",
                "Notification Preference",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPreferencePage(),
                    ),
                  );
                },
              ),
              buildTile(
                context,
                "assets/images/profile/crown.png",
                "My Subscription",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MySubscriptionPage(),
                    ),
                  );
                },
              ),
              buildTile(
                context,
                "assets/images/transaction_history.png",
                "Transaction History",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentHistoryPage(),
                    ),
                  );
                },
              ),
              buildTile(
                context,
                "assets/images/delivery_address.png",
                "Delivery Address",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DeliveryAddressPage(),
                    ),
                  );
                  print("About Us tapped");
                },
              ),
              buildTile(
                context,
                "assets/images/profile/my_orders.png",
                "My Orders",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MyOrdersPage()),
                  );
                  print("About Us tapped");
                },
              ),
              buildTile(
                context,
                "assets/images/profile/report_issues.png",
                "Report Issue",
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => MyRequests()));
                  print("Report Issue  tapped");
                },
              ),
              buildTile(
                context,
                "assets/images/profile/about_us.png",
                "About Us",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                  print("About Us tapped");
                },
              ),
              buildTile(
                context,
                "assets/images/profile/call.png",
                "Contact Us",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ContactUsPage()),
                  );
                  print("About Us tapped");
                },
              ),

              buildTile(
                context,
                "assets/images/profile/settings.png",
                "Settings",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                  print("About Us tapped");
                },
              ),
              // buildTile(
              //   context,
              //   "assets/images/profile/settings.png",
              //   "Settings",
              //   onTap: () {},
              // ),
              buildTile(
                context,
                "assets/images/profile/logout.png",
                "Logout",
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(
    CustomerDetails userDetails,
    BuildContext context,
  ) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (userDetails.profileImage != null &&
                        userDetails.profileImage!.isNotEmpty)
                    ? NetworkImage(
                      "${AppUrls.appUrl}/${userDetails.profileImage!.replaceAll("\\", "/")}",
                    )
                    : const NetworkImage(
                          'https://t3.ftcdn.net/jpg/06/19/26/46/360_F_619264680_x2PBdGLF54sFe7kTBtAvZnPyXgvaRw0Y.jpg',
                        )
                        as ImageProvider,
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Image load error: $exception');
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final customerIdString = prefs.getString('customerId');

        if (customerIdString != null) {
          // Await the result from EditProfilePage
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                      EditProfilePage(customerId: int.parse(customerIdString)),
            ),
          );

          // If we got a result (meaning profile was updated), refresh the data
          if (result != null && mounted) {
            _fetchCustomerDetails(); // Call your data fetching method
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load profile information'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          "assets/images/profile/edit.png",
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  Widget buildTile(
    BuildContext context,
    String imagePath,
    String title, {
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ), // Reduced padding
      leading: Image.asset(
        imagePath,
        height: screenWidth * 0.05,
        width: screenWidth * 0.05,
      ),
      title: Text(
        title,
        style: GoogleFonts.beVietnamPro(
          fontSize: screenWidth * 0.0356,
          letterSpacing: -0.5,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: getFontRegularSize(context),
      ),
      onTap: onTap,
      dense: true, // Reduces the vertical height of the tile
      isThreeLine: false, // Removes extra space for possible third line
    );
  }
}

Widget _buildShimmerLoading(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;

  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Row(
      children: [
        // Shimmer for Profile Avatar
        CircleAvatar(radius: 30, backgroundColor: Colors.white),
        SizedBox(width: width * 0.04),

        // Shimmer for User Details Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for User Name
              Container(
                width: width * 0.4,
                height: getFontRegular55Size(context),
                color: Colors.white,
              ),
              const SizedBox(height: 4),

              // Shimmer for Mosque Name with Icon
              Row(
                children: [
                  Container(
                    height: height * 0.030,
                    width: width * 0.07,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: width * 0.3,
                    height: getFontRegular35Size(context),
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Shimmer for Mosque Location
              Container(
                width: width * 0.5,
                height: getDynamicFontSize(context, 0.040),
                color: Colors.white,
              ),
            ],
          ),
        ),
        // Shimmer for Edit Profile Button (Optional, can be omitted if not critical during load)
      ],
    ),
  );
}

class CustomerDetails {
  final int customerId;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? _mosqueName;
  final String? _mosqueLocation;
  final String? phoneNumber;

  CustomerDetails({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    String? mosqueName,
    String? mosqueLocation,
    this.phoneNumber,
  }) : _mosqueName = mosqueName,
       _mosqueLocation = mosqueLocation;

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      customerId: json['customerId'] ?? 0, // Default to 0 if null
      firstName: json['firstName'] ?? '', // Default to empty string if null
      lastName: json['lastName'] ?? '', // Default to empty string if null
      profileImage: json['profileImagePath'], // Allow null
      mosqueName: json['mosqueName'] as String?,
      mosqueLocation: json['mosqueLocation'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  String get mosqueName => _mosqueName ?? "Mosque";
  String get mosqueLocation => _mosqueLocation ?? "Location";
}

void navigateToHomeScreen(BuildContext context) {
  Navigator.pushReplacement(
    // ✅ Replaces current screen only
    context,
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}
