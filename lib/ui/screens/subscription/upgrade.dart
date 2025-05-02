import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:prayerunitesss/providers/auth_providers.dart';
import 'package:prayerunitesss/service/api/subscription/subscription_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/api/subscription_model.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = 'Monthly';
  int? selectedPlanId;
  List<dynamic> plans = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
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

  Future<void> _subscribeToPlan() async {
    if (selectedPlanId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerIdString = prefs.getString('customerId');

      if (customerIdString != null && selectedPlanId != null) {
        final result = await SubscriptionService.subscribeToPlan(
          customerId: customerIdString,
          planId: selectedPlanId!,
        );

        // Optional: parse or use result if needed
        print("Subscription result: $result");

        if (!mounted) return;
        Navigator.of(context).pop(); // Dismiss loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Add this line to go back to the previous page
        Navigator.of(context).pop();

      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer ID or Plan ID is missing.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : _buildContent(authProvider),
          ),
          if (!isLoading && errorMessage.isEmpty) _buildSubscriptionButton(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ],
      ),
    );
  }

  Widget _buildContent(AuthProvider authProvider) {
    return ListView(
      children: [
        Stack(
          children: [
            Image.asset("assets/images/upgrade/upgrade_top.png"),
            Positioned(
              top: 40,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
            ),
          ],
        ),
        _buildHeader(),
        if (authProvider.isDemoUser) _buildCurrentPlanCard(),
        ...plans.map((plan) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SubscriptionCard(
            title: plan['planName'],
            price: '${plan['price']} ${plan['currency']}',
            duration: plan['description'],
            tag: plan['status'] ? 'Active' : 'Inactive',
            selected: selectedPlan == plan['planName'],
            onTap: () {
              setState(() {
                selectedPlan = plan['planName'];
                selectedPlanId = plan['planId'];
              });
            },
          ),
        )),
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.beVietnamPro(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: Colors.black,
            ),
            children: [
              const TextSpan(text: 'Your '),
              TextSpan(
                text: 'Masjid',
                style: GoogleFonts.beVietnamPro(color: const Color(0xFFA1812E)),
              ),
              const TextSpan(text: '. Your '),
              TextSpan(
                text: 'Connection',
                style: GoogleFonts.beVietnamPro(color: const Color(0xFF2E7D32)),
              ),
              const TextSpan(text: '. Your Time'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Join Saut Al-Salaah for premium live audio streaming.\nStay connected to your masjid anytime, anywhere.\nSubscribe today.',
          style: GoogleFonts.beVietnamPro(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  Widget _buildCurrentPlanCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF006400)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'My Current Plan',
                    style: GoogleFonts.beVietnamPro(color: Colors.white),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Expires on:',
                        style: GoogleFonts.beVietnamPro(color: Colors.white),
                      ),
                      TextSpan(
                        text: ' 25 Apr 2024',
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFFF4DE8B),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Monthly',
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '1000 KWD',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' / month',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Features Unlocks",
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
              _buildFeatureItem('Full access to live prayer audio'),
              _buildFeatureItem('Prayer notifications & reminders'),
              _buildFeatureItem('Priority updates'),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plans.firstWhere(
                        (plan) => plan['planName'] == selectedPlan,
                    orElse: () => {'planName': ''},
                  )['planName'],
                  style: GoogleFonts.beVietnamPro(color: const Color(0xFF2E7D32)),
                ),
                Text(
                  '${plans.firstWhere(
                        (plan) => plan['planName'] == selectedPlan,
                    orElse: () => {'price': '', 'currency': ''},
                  )['price']} ${plans.firstWhere(
                        (plan) => plan['planName'] == selectedPlan,
                    orElse: () => {'currency': ''},
                  )['currency']}',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _subscribeToPlan,
            icon: Image.asset(
              "assets/images/upgrade/king.png",
              height: 20,
              width: 20,
            ),
            label: Text(
              'Subscribe',
              style: GoogleFonts.beVietnamPro(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}