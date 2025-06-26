import 'package:flutter/material.dart';
import 'package:prayerunitesss/ui/screens/subscription/subscription_details_page.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:prayerunitesss/utils/custom_appbar.dart';

import '../../../model/api/customer/customer_all_details_model/customer_all_details.dart';
import '../../../service/api/customer/customer_service_api.dart';
import '../../../service/api/subscription/subscription_service.dart';

class MySubscriptionPage extends StatefulWidget {
  const MySubscriptionPage({super.key});

  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage> {
  late Future<CustomerAllDetails> _customerDetailsFuture;
  final CustomerServices _apiService = CustomerServices(
    baseUrl: AppUrls.appUrl,
  );

  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> plans = [];
  String? selectedPlan;
  String? selectedPlanId;
  double selectedPlanPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _customerDetailsFuture = _apiService.getAllCustomerDetails();
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchSubscriptionPlans() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await SubscriptionService.getSubscriptionPlans();
      setState(() {
        plans = data['data'];
        if (plans.isNotEmpty) {
          selectedPlan = plans[0]['planName'];
          selectedPlanId = plans[0]['planId'];
          selectedPlanPrice =
              double.tryParse(plans[0]['price'].toString()) ?? 0.0;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load subscription plans: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: CustomAppBar(
        title: "My Subscription",
        onBack: Navigator.of(context).pop,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: FutureBuilder<CustomerAllDetails>(
          future: _customerDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.data == null) {
              return const Center(
                child: Text('No subscription data available'),
              );
            }

            final customerData = snapshot.data!.data!;
            final subscriptions = _getSubscriptionsFromDevices(
              customerData.devices,
            );

            if (subscriptions.isEmpty) {
              return const Center(child: Text('No active subscriptions found'));
            }

            return ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    SubscriptionCard.fromApiData(
                      subscriptionData: subscription,
                      plans: plans,
                    ),
                    if (index == subscriptions.length - 1)
                      const SizedBox(height: 24),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<SubscriptionData> _getSubscriptionsFromDevices(
    List<CustomerDevice> devices,
  ) {
    final List<SubscriptionData> subscriptions = [];

    for (final device in devices) {
      if (device.subscription != null) {
        subscriptions.add(
          SubscriptionData(
            device: device,
            subscription: device.subscription!,
            mosque: device.mosque,
            startDate: device.subscription!.startDate, // Add the start date
          ),
        );
      }
    }

    return subscriptions;
  }
}

class SubscriptionData {
  final CustomerDevice device;
  final Subscriptionss subscription;
  final Mosquess? mosque;
  final String startDate; // Add this field

  SubscriptionData({
    required this.device,
    required this.subscription,
    this.mosque,
    required this.startDate, // Add to constructor
  });
}

class SubscriptionCard extends StatelessWidget {
  final String planTitle;
  final String amount;
  final String dateLabel;
  final String device;
  final String mosque;
  final String status;
  final String startDate; // Add this
  final String endDate; // Add this
  final Color statusColor;
  final Color statusBgColor;
  final String subscriptionId;
  final IconData icon;

  const SubscriptionCard({
    super.key,
    required this.planTitle,
    required this.amount,
    required this.dateLabel,
    required this.device,
    required this.mosque,
    required this.status,
    required this.startDate, // Add to constructor
    required this.endDate, // Add to constructor
    required this.statusColor,
    required this.statusBgColor,
    required this.icon,
    required this.subscriptionId,
  });

  factory SubscriptionCard.fromApiData({
    required SubscriptionData subscriptionData,
    required List<dynamic> plans,
  }) {
    final subscription = subscriptionData.subscription;
    final device = subscriptionData.device;
    final mosque = subscriptionData.mosque;

    // Determine status based on dates
    final endDate = DateTime.tryParse(subscription.endDate) ?? DateTime.now();
    final now = DateTime.now();
    final daysUntilExpiry = endDate.difference(now).inDays;

    String status;
    Color statusColor;
    Color statusBgColor;
    IconData icon;

    if (endDate.isBefore(now)) {
      status = 'Expired';
      statusColor = Colors.red;
      statusBgColor = const Color(0xFFFFEBEE);
    } else if (daysUntilExpiry <= 7) {
      status = 'Expiring Soon';
      statusColor = Colors.orange;
      statusBgColor = const Color(0xFFFFF3E0);
    } else {
      status = 'Active';
      statusColor = Colors.green;
      statusBgColor = const Color(0xFFE6F4EA);
    }

    // Determine icon based on device type
    if (device.deviceName.toLowerCase().contains('mobile')) {
      icon = Icons.mobile_friendly_rounded;
    } else if (device.deviceName.toLowerCase().contains('speaker')) {
      icon = Icons.speaker;
    } else {
      icon = Icons.devices_other;
    }

    // Get the plan details
    final plan = plans.firstWhere(
      (plan) => plan['planId'] == subscription.planID,
      orElse:
          () => {
            'planName': 'Unknown Plan',
            'price': subscription.paidAmount,
            'currency': 'KWD ',
          },
    );

    // Format amount with currency
    final currency = plan['currency'] ?? 'KWD ';
    final amount = '$currency${subscription.paidAmount.toStringAsFixed(3)}';

    return SubscriptionCard(
      planTitle: plan['planName'],
      amount: amount,
      dateLabel: 'Expires: ${_formatDate(subscription.endDate)}',
      device: device.deviceName,
      mosque: mosque?.mosqueName ?? 'Unknown Mosque',
      status: status,
      statusColor: statusColor,
      statusBgColor: statusBgColor,
      icon: icon,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      subscriptionId: subscription.subscriptionID.toString(),
    );
  }

  static String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString) ?? DateTime.now();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SubscriptionDetailsPage(
                  planTitle: planTitle,
                  amount: amount,
                  status: status,
                  statusColor: statusColor,
                  statusBgColor: statusBgColor,
                  startDate: startDate,
                  endDate: endDate,
                  deviceName: device,
                  mosqueName: mosque,
                  subscriptionId: int.tryParse(subscriptionId) ?? 0,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: Colors.grey[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${planTitle} Device Subscription',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(dateLabel, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Default color for device name
                  fontSize: 14, // Adjust font size as needed
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '$device - ',
                    style: TextStyle(color: Color(0xFF119B21)),
                  ), // Device name in green
                  TextSpan(
                    text: mosque,
                    style: const TextStyle(
                      color: Colors.black,
                    ), // Mosque name in black
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
