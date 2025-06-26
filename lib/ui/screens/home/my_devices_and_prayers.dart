import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/api/customer/customer_all_details_model/customer_all_details.dart';
import '../../../model/api/prayer/prayer_times.dart';
import '../../../providers/prayer_provider/prayer_timing_provider.dart';
import '../../widgets/prayer_card.dart';
import 'my_devices/my_devices_ui.dart';

class MyDevicesAndPrayers extends StatelessWidget {
  const MyDevicesAndPrayers({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.prayers,
    required PrayerController prayerController,
    required this.selectedDate,
    required this.prayerTimes,
    this.customerDetails,
  }) : _prayerController = prayerController;

  final double screenHeight;
  final double screenWidth;
  final List<Map<String, dynamic>> prayers;
  final PrayerController _prayerController;
  final DateTime selectedDate;
  final PrayerTimes prayerTimes;
  final CustomerAllDetails? customerDetails; // Make nullable

  int getTotalDevicesCount() {
    return customerDetails?.data?.devices.length ?? 0; // Fallback to 4 if null
  }

  int getConnectedDevicesCount() {
    if (customerDetails?.data?.devices == null) {
      return 0; // Fallback to 3 if null
    }
    return customerDetails!.data!.devices
        .where((device) => device.mosque != null)
        .length;
  }

  // Check if user has any active subscription
  bool get hasActiveSubscription {
    if (customerDetails?.data?.devices == null) return false;
    return customerDetails!.data!.devices.any(
      (device) => device.subscription?.subscriptionStatus == true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 0, color: Colors.yellow, thickness: 5),

              // Show different content based on subscription status
              if (hasActiveSubscription)
                _buildActiveSubscriptionContent(context)
              else
                _buildNoSubscriptionContent(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionContent(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DevicesCountCard(
            customerDetails: customerDetails,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final customerIdString = prefs.getString('customerId');
              if (customerIdString != null) {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MyDevicesPage()),
                );
              }
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
            child: Text(
              "🙌 Stay Aligned with the Call of Prayer",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
                letterSpacing: -0.4,
              ),
            ),
          ),

          // Conditionally show Upgrade Now button if there's an active subscription
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.035,
              vertical: screenHeight * 0.005,
            ),
            child: Text(
              "Check today's prayer timings and stay connected to your masjid, wherever you are.",
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: screenWidth * 0.0356,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: screenHeight * 0.01),
              itemCount: prayers.length,
              itemBuilder: (context, index) {
                final prayer = prayers[index];
                return PrayerCard(
                  imagePath: _prayerController.getImagePath(prayer['name']),
                  title: prayer['name'],
                  arabic: prayer['arabic'],
                  time: prayer['time'],
                  status: _prayerController.getPrayerStatus(
                    prayer['name'],
                    selectedDate,
                    prayerTimes,
                  ),
                  statusColor: _prayerController.getStatusColor(
                    _prayerController.getPrayerStatus(
                      prayer['name'],
                      selectedDate,
                      prayerTimes,
                    ),
                  ),
                  trailingIcon:
                      _prayerController.getPrayerStatus(
                                prayer['name'],
                                selectedDate,
                                prayerTimes,
                              ) ==
                              "Upcoming"
                          ? Icons.notifications
                          : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionContent(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // Devices count card (optional - you can choose to show or hide this)
          DevicesCountCard(
            customerDetails: customerDetails,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final customerIdString = prefs.getString('customerId');
              if (customerIdString != null) {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MyDevicesPage()),
                );
              }
            },
          ),

          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  itemCount: prayers.length,
                  itemBuilder: (context, index) {
                    final prayer = prayers[index];
                    return PrayerCard(
                      imagePath: _prayerController.getImagePath(prayer['name']),
                      title: prayer['name'],
                      arabic: prayer['arabic'],
                      time: prayer['time'],
                      status: _prayerController.getPrayerStatus(
                        prayer['name'],
                        selectedDate,
                        prayerTimes,
                      ),
                      statusColor: _prayerController.getStatusColor(
                        _prayerController.getPrayerStatus(
                          prayer['name'],
                          selectedDate,
                          prayerTimes,
                        ),
                      ),
                      trailingIcon:
                          _prayerController.getPrayerStatus(
                                    prayer['name'],
                                    selectedDate,
                                    prayerTimes,
                                  ) ==
                                  "Upcoming"
                              ? Icons.notifications
                              : null,
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      // Optionally, add a message here like "Subscribe to see prayer times"
                      // child: Text("Subscribe to see prayer times", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DevicesCountCard extends StatelessWidget {
  final CustomerAllDetails? customerDetails;
  final VoidCallback? onTap;

  const DevicesCountCard({super.key, this.customerDetails, this.onTap});

  int getTotalDevicesCount() {
    return customerDetails?.data?.devices.length ?? 0;
  }

  int getConnectedDevicesCount() {
    if (customerDetails?.data?.devices == null) return 0;
    return customerDetails!.data!.devices
        .where((device) => device.mosque != null)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final totalDevices = getTotalDevicesCount();
    final connectedDevices = getConnectedDevicesCount();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF2E7D32),
                      radius: 24,
                      child: Image.asset(
                        "assets/images/devices.png",
                        height: 24,
                        width: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "My Devices ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF797979),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Total devices count
                              Text(
                                "$totalDevices",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Spacer to push connected devices to the right
                              Spacer(),
                              // Connected devices badge
                              if (connectedDevices > 0)
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 60,
                                  ), // Leave space for next1 icon
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF4FFF5),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "Connected Devices - $connectedDevices",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Image.asset(
                  "assets/images/next1.png",
                  height: 30,
                  width: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
