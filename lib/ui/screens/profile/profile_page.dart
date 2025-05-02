import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../../../utils/font_mediaquery.dart';
import '../about_us/about_us.dart';
import '../contact/contact_us.dart';
import '../login_page/login_page.dart';
import '../subscription/subscription.dart';
import '../subscription/upgrade.dart';
import '../transaction/transaction_history.dart';
import 'edit_profile_page.dart';
import 'notification_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final authProvider = Provider.of<AuthProvider>(context);
    final userDetails = Provider.of<UserDetailsProvider>(context).userDetails;
    final userDetailsProvider = Provider.of<UserDetailsProvider>(context);
    final subscription = userDetailsProvider.userDetails?.subscription;

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
            automaticallyImplyLeading: false, // Add this line

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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.08,
                    backgroundImage: AssetImage(
                      "assets/images/profile/profile.png",
                    ), // Replace with NetworkImage or asset
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userDetails?.fullName ?? "Loading...",
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegular55Size(context),
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/profile/masuthi.png",
                              height: height * 0.030,
                              width: width * 0.07,
                            ),
                            SizedBox(width: 4),
                            Text(
                              userDetails?.displayMosque ??
                                  "Sanjay Jaganathan VJ",
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.green,
                                fontSize: getFontRegular35Size(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          userDetails?.displayMosqueLocation ??
                              "Sanjay Jaganathan VJ",
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w400,
                            fontSize: getDynamicFontSize(context, 0.040),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final customerIdString = prefs.getString('customerId');

                      if (customerIdString != null) {
                        final customerId = int.parse(
                          customerIdString,
                        ); // Convert to int
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditProfilePage(customerId: customerId),
                          ),
                        );
                      } else {
                        print('No customerId found in SharedPreferences');
                      }
                    },
                    child: Image.asset(
                      "assets/images/profile/edit.png",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            //  Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Color(0xFF004408),
            //
            //         Color(0xFF2E7D32),
            //       ], // Using two different colors for the gradient
            //       begin: Alignment.centerRight,
            //       end: Alignment.centerLeft,
            //     ),
            //
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Container(
            //             decoration: BoxDecoration(
            //               color: Color(0xFF73A876),
            //
            //               borderRadius: BorderRadius.circular(5),
            //             ),
            //             padding: EdgeInsets.symmetric(
            //               horizontal: 5,
            //               vertical: 5,
            //             ),
            //             child: Text(
            //               "My Current Plan",
            //               style: GoogleFonts.beVietnamPro(
            //                 color: Colors.white,
            //                 fontSize: 12,
            //               ),
            //             ),
            //           ),
            //           const SizedBox(height: 8),
            //           Text(
            //             'Monthly',
            //             style: GoogleFonts.beVietnamPro(
            //               color: Colors.white,
            //               fontSize: 14,
            //             ),
            //           ),
            //           Text.rich(
            //             TextSpan(
            //               children: [
            //                 TextSpan(
            //                   text: '10 KWD',
            //                   style: GoogleFonts.beVietnamPro(
            //                     color: Colors.white,
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //                 TextSpan(
            //                   text: ' / month',
            //                   style: GoogleFonts.beVietnamPro(
            //                     color: Colors.white,
            //                     fontSize:
            //                         14, // Smaller font size for 'month'
            //                     fontWeight:
            //                         FontWeight
            //                             .normal, // Not bold for 'month'
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           Text.rich(
            //             TextSpan(
            //               children: [
            //                 TextSpan(
            //                   text: 'Expires on:',
            //                   style: GoogleFonts.beVietnamPro(
            //                     color: Colors.white,
            //                     fontSize: 12,
            //                   ),
            //                 ),
            //                 TextSpan(
            //                   text: ' 25 Apr 2024',
            //                   style: GoogleFonts.beVietnamPro(
            //                     color: Color(0xFFF4DE8B),
            //                     fontSize:
            //                         12, // Smaller font size for 'month'
            //                     fontWeight:
            //                         FontWeight
            //                             .normal, // Not bold for 'month'
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       Transform.translate(
            //         offset: Offset(
            //           MediaQuery.of(context).size.width *
            //               0.01, // 1% of screen width
            //           MediaQuery.of(context).size.height *
            //               0.03, // 3% of screen height
            //         ),
            //         child: ElevatedButton(
            //           onPressed: () {
            //             Navigator.of(context).push(
            //               MaterialPageRoute(
            //                 builder: (context) => SubscriptionPage(),
            //               ),
            //             );
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: const Color(0xFFD4AF37),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(30),
            //             ),
            //           ),
            //           child: Text(
            //             'Upgrade',
            //             style: GoogleFonts.beVietnamPro(
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            subscription != null
                ? Container()
                : Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                  // ListTile(
                  //   contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), // Reduced padding
                  //
                  //   leading: Image.asset(
                  //     "assets/images/upgrade/king.png",
                  //     height: width * 0.05,
                  //     width: height * 0.05,
                  //   ),
                  //
                  //   title: Row(
                  //     children: [
                  //
                  //       Text(
                  //         "Subscribe Now",
                  //         style: GoogleFonts.beVietnamPro(
                  //           fontSize:getFontRegularSize(context),
                  //           letterSpacing: -0.5,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   trailing: Icon(
                  //     Icons.arrow_forward_ios,
                  //     size: width * 0.038,
                  //     color: Colors.white,
                  //   ),
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) => SubscriptionPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ), // Reduced padding
                    leading: Image.asset(
                      "assets/images/upgrade/king.png",
                      height: width * 0.05,
                      width: width * 0.05,
                    ),
                    title: Text(
                      "Subscribe Now",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: getFontRegularSize(context),
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: getFontRegularSize(context),
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SubscriptionPage(),
                        ),
                      );
                    },
                    dense: true, // Reduces the vertical height of the tile
                    isThreeLine:
                        false, // Removes extra space for possible third line
                  ),
                ),

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
                  MaterialPageRoute(builder: (context) => MySubscriptionPage()),
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
                  MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
                );
              },
            ),
            buildTile(
              context,
              "assets/images/profile/about_us.png",
              "About Us",
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => AboutUsPage()));
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
              onTap: () {
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
                          padding: EdgeInsets.all(20),
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
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                              SizedBox(height: 15),

                              // Title
                              Text(
                                "Logout?",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),

                              // Message
                              Text(
                                "Are you sure you want to sign out?",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Cancel Button
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
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
                                  SizedBox(width: 15),

                                  // Logout Button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs
                                            .clear(); // Clears all stored data
                                        final authProvider =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            );
                                        authProvider.logout();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LoginPage(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
              },
            ),
          ],
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
        horizontal: 20,
      ), // Reduced padding
      leading: Image.asset(
        imagePath,
        height: screenWidth * 0.05,
        width: screenWidth * 0.05,
      ),
      title: Text(
        title,
        style: GoogleFonts.beVietnamPro(
          fontSize: getFontRegularSize(context),
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
