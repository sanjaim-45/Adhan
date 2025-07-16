import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:prayerunitesss/providers/auth_providers.dart';
import 'package:prayerunitesss/service/api/subscription/subscription_service.dart';
import 'package:prayerunitesss/ui/screens/subscription/subscription_toggle_tabs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/api/devices/my_devices_model.dart';
import '../../../model/api/subscription_model.dart';
import '../../../service/api/devices_list/devices_list_api.dart';
import '../../../service/api/templete_api/api_service.dart';
import '../../../service/api/tokens/token_service.dart';
import '../../../utils/app_urls.dart';
import 'device_request/device_request_screen.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = 'Monthly';
  int? selectedPlanId;
  double selectedPlanPrice = 0.0;
  List<dynamic> plans = [];
  bool isLoading = true;
  String errorMessage = '';
  late MFGooglePayButton mfGooglePayButton;
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

  // Future<void> _subscribeToPlan() async {
  //   if (selectedPlanId == null) return;
  //
  //   final plan = plans.firstWhere((p) => p['planId'] == selectedPlanId);
  //   final double amount = double.tryParse(plan['price'].toString()) ?? 0.0;
  //
  //   try {
  //     // Show beautiful loading dialog
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder:
  //           (context) => PaymentLoadingDialog(
  //             amount: amount,
  //             planName: plan['planName'],
  //           ),
  //     );
  //
  //     // 1. First initiate payment to get payment methods
  //     MFInitiatePaymentRequest initiateRequest = MFInitiatePaymentRequest(
  //       invoiceAmount: amount,
  //       currencyIso: MFCurrencyISO.KUWAIT_KWD, // Changed to KWD
  //     );
  //
  //     final initiationResponse = await MFSDK.initiatePayment(
  //       initiateRequest,
  //       MFLanguage.ENGLISH,
  //     );
  //
  //     // Dismiss loading dialog
  //     if (!mounted)
  //       return; // Add return value here if the function expects one, or make it void
  //     Navigator.of(context).pop();
  //
  //     // Show payment method selection bottom sheet
  //     _showPaymentMethodSelection(initiationResponse.paymentMethods!, amount);
  //   } catch (error) {
  //     if (!mounted) return;
  //     Navigator.of(context).pop(); // Dismiss loading dialog
  //     String errorMessage = error.toString();
  //     if (error is MFError) {
  //       errorMessage = error.message ?? "An unknown error occurred.";
  //       // You can also access error.status, error.code, etc.
  //       // For example, if you want to show the code:
  //       // errorMessage += " (Code: ${error.code})";
  //     }
  //     _showPaymentError(errorMessage);
  //   }
  // }

  void _showPaymentMethodSelection(
    List<MFPaymentMethod> methods,
    double amount,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select Payment Method',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${amount.toStringAsFixed(2)} KWD',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ...methods
                      .map((method) => _buildPaymentMethodCard(method, amount))
                      .toList(),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              //  const SizedBox(height: 10),
              //],
            ),
          ),
    );
  }

  Widget _buildPaymentMethodCard(MFPaymentMethod method, double amount) {
    final methodName = method.paymentMethodEn ?? 'Unknown';
    final icon = _getPaymentMethodIcon(methodName);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (methodName.toLowerCase().contains('knet')) {
            _simulateKnetPaymentSuccess(amount, methodName);
          } else if (methodName.toLowerCase().contains('google pay')) {
            _initiateGooglePayPayment(amount);
          } else {
            _executePayment(method.paymentMethodId!, amount, methodName);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: icon,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  methodName,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initiateGooglePayPayment(double amount) async {
    try {
      // Close the payment method selection bottom sheet
      Navigator.of(context).pop();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PaymentProcessingDialog(methodName: 'Google Pay'),
      );

      // Step 1: Initiate a session for Google Pay
      MFInitiateSessionRequest initiateSessionRequest =
          MFInitiateSessionRequest();

      final sessionResponse = await MFSDK.initSession(
        initiateSessionRequest,
        MFLanguage.ENGLISH,
      );

      // Step 2: Setup Google Pay with the session ID
      await _setupGooglePayHelper(sessionResponse.sessionId, amount);
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog
      _handlePaymentError(error);
    }
  }

  Future<void> _setupGooglePayHelper(String sessionId, double amount) async {
    try {
      // Initialize the Google Pay button if not already done
      mfGooglePayButton = MFGooglePayButton();

      // Create Google Pay request
      MFGooglePayRequest googlePayRequest = MFGooglePayRequest(
        totalPrice: amount.toString(),
        merchantId: "01234567890123456789",
        merchantName: "Adhan",
        countryCode: MFCountry.KUWAIT,
        currencyIso: MFCurrencyISO.KUWAIT_KWD,
      );

      // Setup Google Pay helper
      await mfGooglePayButton.setupGooglePayHelper(
        sessionId,
        googlePayRequest,
        (invoiceId) {
          if (!mounted) return;
          Navigator.of(context).pop(); // Dismiss loading dialog
          _showPaymentSuccess(invoiceId, amount);
        },
      );

      // Show Google Pay button in a dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Pay with Google Pay"),
              content: SizedBox(height: 70, child: mfGooglePayButton),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog
      _handlePaymentError(error);
    }
  }

  Widget _getPaymentMethodIcon(String methodName) {
    if (methodName.toLowerCase().contains('visa') ||
        methodName.toLowerCase().contains('mastercard')) {
      return const Icon(Icons.credit_card, color: Color(0xFF2E7D32));
    } else if (methodName.toLowerCase().contains('knet')) {
      return Image.network(
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTv3is6GbaYDGTRPZ24aKhIt0Ocd98ivu1aQ&s",
      ); // Add your KNET logo asset
    } else if (methodName.toLowerCase().contains('apple pay')) {
      return const Icon(Icons.apple, color: Colors.black);
    } else {
      return const Icon(Icons.payment, color: Color(0xFF2E7D32));
    }
  }

  // New method to simulate KNET payment success
  Future<void> _simulateKnetPaymentSuccess(
    double amount,
    String methodName,
  ) async {
    Navigator.of(context).pop(); // Close payment method selection

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentProcessingDialog(methodName: methodName),
    );

    // Simulate a delay for processing
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.of(context).pop(); // Dismiss processing dialog

    // Generate a dummy invoice ID for simulation
    final dummyInvoiceId = 'SIM_KNET_${DateTime.now().millisecondsSinceEpoch}';
    _showPaymentSuccess(dummyInvoiceId, amount);
  }

  Future<void> _executePayment(
    int methodId,
    double amount,
    String methodName,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PaymentProcessingDialog(methodName: methodName),
      );

      if (methodName.toLowerCase().contains('google pay')) {
        // Special handling for Google Pay
        await _handleGooglePayPayment(methodId, amount);
      } else if (methodName.toLowerCase().contains('visa') ||
          methodName.toLowerCase().contains('mastercard')) {
        await _executeDirectPayment(methodId, amount, methodName);
      } else {
        await _executeRegularPayment(methodId, amount, methodName);
      }
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss processing dialog
      _handlePaymentError(error);
    }
  }

  Future<void> _handleGooglePayPayment(int methodId, double amount) async {
    try {
      // 1. Initiate Payment to get available methods
      final initiateResponse = await MFSDK.initiatePayment(
        MFInitiatePaymentRequest(
          invoiceAmount: amount,
          currencyIso: MFCurrencyISO.KUWAIT_KWD,
        ),
        MFLanguage.ENGLISH,
      );

      final googlePayMethod = initiateResponse.paymentMethods?.firstWhere(
        (method) =>
            method.paymentMethodEn?.toLowerCase().contains('google pay') ??
            false,
      );

      if (googlePayMethod == null) {
        throw Exception('Google Pay method not found');
      }

      // 2. Execute Payment using Google Pay method ID
      final executeRequest = MFExecutePaymentRequest(
        invoiceValue: amount,
        paymentMethodId: googlePayMethod.paymentMethodId!,
      );

      // The executePayment for some methods might return a URL to open.
      // It's better to handle the response type dynamically or check the method type.
      // For Google Pay, it's expected to return a URL.
      final dynamic paymentExecutionResult = await MFSDK.executePayment(
        executeRequest,
        MFLanguage.ENGLISH,
        (String invoiceId) {
          print("Invoice ID: $invoiceId");
        },
      );
      // Assuming executePayment returns MFExecutePaymentResponse which has `invoiceURL`
      // and `invoiceId`
      final MFExecutePaymentResponse executeResponse =
          paymentExecutionResult as MFExecutePaymentResponse;
      final String? paymentUrl = executeResponse.paymentURL;

      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw Exception('No payment URL received from MyFatoorah');
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading

      // 3. Open URL in your custom webview
      final paymentResult = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CustomWebView(url: paymentUrl)),
      );

      // 4. Check payment status using invoice ID
      final status = await MFSDK.getPaymentStatus(
        MFGetPaymentStatusRequest(
          key: executeResponse.invoiceId.toString(),
          keyType: MFKeyType.INVOICEID,
        ),
        MFLanguage.ENGLISH,
      );

      if (status.invoiceStatus == "Paid") {
        _showPaymentSuccess(executeResponse.invoiceId.toString(), amount);
      } else {
        throw Exception("Payment failed: ${status.invoiceStatus}");
      }
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _handlePaymentError(error);
    }
  }

  // Method for regular payments (KNET, etc.)
  Future<void> _executeRegularPayment(
    int methodId,
    double amount,
    String methodName,
  ) async {
    final executeRequest = MFExecutePaymentRequest(
      invoiceValue: amount,
      paymentMethodId: methodId,
    );

    final response = await MFSDK.executePayment(
      executeRequest,
      MFLanguage.ENGLISH,
      (invoiceId) {},
    );

    final status = await MFSDK.getPaymentStatus(
      MFGetPaymentStatusRequest(
        key: response.invoiceId.toString(),
        keyType: MFKeyType.INVOICEID,
      ),
      MFLanguage.ENGLISH,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // Dismiss processing dialog

    if (status.invoiceStatus == "Paid") {
      _showPaymentSuccess(response.invoiceId.toString(), amount);
    } else {
      throw Exception("Payment status: ${status.invoiceStatus}");
    }
  }

  // New method for direct card payments
  Future<void> _executeDirectPayment(
    int methodId,
    double amount,
    String methodName,
  ) async {
    // In a real app, you would collect these from a form
    final testCard = MFCard(
      cardHolderName: 'TEST USER',
      number: '5123450000000008', // Test card number
      expiryMonth: '05',
      expiryYear: '25',
      securityCode: '100',
    );

    final executeRequest = MFExecutePaymentRequest(
      invoiceValue: amount,
      paymentMethodId: methodId,
    );

    final directPaymentRequest = MFDirectPaymentRequest(
      executePaymentRequest: executeRequest,
      card: testCard,
      token: null, // Set to token if you have one
    );

    final response = await MFSDK.executeDirectPayment(
      directPaymentRequest,
      MFLanguage.ENGLISH,
      (invoiceId) {},
    );

    final status = await MFSDK.getPaymentStatus(
      MFGetPaymentStatusRequest(
        key: response.cardInfoResponse!.paymentId.toString(),
        keyType: MFKeyType.INVOICEID,
      ),
      MFLanguage.ENGLISH,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // Dismiss processing dialog

    if (status.invoiceStatus == "Paid") {
      _showPaymentSuccess(
        response.cardInfoResponse!.paymentId.toString(),
        amount,
      );
    } else {
      throw Exception("Payment status: ${status.invoiceStatus}");
    }
  }

  // Improved error handling
  void _handlePaymentError(dynamic error) {
    String errorMessage = "Payment failed. Please try again.";

    if (error is MFError) {
      errorMessage = error.message ?? errorMessage;
      // Log additional error details if needed
      debugPrint("MyFatoorah Error: ${error.code} - ${error.message}");
    } else if (error is Exception) {
      errorMessage = error.toString();
    }

    _showPaymentError(errorMessage);
  }

  void _showPaymentSuccess(String invoiceId, double amount) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF2E7D32),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Payment Successful!',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Invoice #$invoiceId',
                  style: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Text(
                  '${amount.toStringAsFixed(2)}KWD',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // You might want to refresh subscription status here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPaymentError(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Payment Failed',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'There was an issue processing your payment. Please try again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Text(
                  error.length > 50 ? '${error.substring(0, 50)}...' : error,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _subscribeToPlan(); // Retry
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _subscribeToPlan() async {
    if (selectedPlanId == null) return;

    // Get the access token from TokenService
    final accessToken = await TokenService.getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading while fetching devices
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch devices using the access token
      final devices =
          await DeviceService(
            apiService: ApiService(baseUrl: AppUrls.appUrl),
          ).getMyDevices();

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog

      // Show device selection bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => DeviceSelectionBottomSheet(
              devices: devices,
              onDeviceSelected: (deviceId) async {
                if (deviceId != null) {
                  await _completeSubscription(deviceId);
                }
              },
            ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch devices: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeSubscription(int deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final customerIdString = prefs.getString('customerId');

    if (customerIdString == null || selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer ID or Plan ID is missing.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await SubscriptionService.subscribeToPlan(
        customerId: customerIdString,
        planId: selectedPlanId!,
        deviceId: deviceId, // Add deviceId parameter to your service
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription successful!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
            child:
                isLoading
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
            Positioned(
              top: 50,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeviceRequestScreen(),
                    ),
                  );
                },
                icon: Image.asset(
                  "assets/images/device_request_black.png",
                  height: 18,
                  width: 18,
                ),
                label: Text(
                  'Device Request',
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildHeader(),
        ...plans.map(
          (plan) => Padding(
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
                  selectedPlanPrice =
                      double.tryParse(plan['price'].toString()) ?? 0.0;
                });
              },
            ),
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Join Saut Al-Salaah for premium live audio streaming.Stay connected to your masjid anytime, anywhere.Subscribe today.',
            style: GoogleFonts.beVietnamPro(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        SubscriptionToggleTabs(),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                ),
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
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  '${plans.firstWhere((plan) => plan['planName'] == selectedPlan, orElse: () => {'price': '', 'currency': ''})['price']} ${plans.firstWhere((plan) => plan['planName'] == selectedPlan, orElse: () => {'currency': ''})['currency']}',
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

// Add this new widget to your subscription_page.dart or create a new file
class DeviceSelectionBottomSheet extends StatefulWidget {
  final List<DeviceDropdown> devices;
  final Function(int?) onDeviceSelected;
  final int? selectedDeviceId;

  const DeviceSelectionBottomSheet({
    super.key,
    required this.devices,
    required this.onDeviceSelected,
    this.selectedDeviceId,
  });

  @override
  State<DeviceSelectionBottomSheet> createState() =>
      _DeviceSelectionBottomSheetState();
}

class _DeviceSelectionBottomSheetState
    extends State<DeviceSelectionBottomSheet> {
  int? _selectedDeviceId;

  @override
  void initState() {
    super.initState();
    // Initialize MyFatoorah SDK
    MFSDK.init(
      "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL",
      MFCountry.KUWAIT,
      MFEnvironment.TEST, // Change to LIVE for production
    );
    _selectedDeviceId = widget.selectedDeviceId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select a Device',
            style: GoogleFonts.beVietnamPro(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.devices.isEmpty)
            const Text('No devices available')
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.devices.length,
              itemBuilder: (context, index) {
                final device = widget.devices[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(
                          0,
                          1,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: RadioListTile<int>(
                    title: Text(device.deviceName),
                    value: device.deviceId,
                    groupValue: _selectedDeviceId,
                    onChanged: (value) {
                      setState(() {
                        _selectedDeviceId = value;
                      });
                    },
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _selectedDeviceId == null
                          ? null
                          : () {
                            widget.onDeviceSelected(_selectedDeviceId);
                            Navigator.pop(context);
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Add these dialog widgets to your file
class PaymentLoadingDialog extends StatelessWidget {
  final double amount;
  final String planName;

  const PaymentLoadingDialog({
    super.key,
    required this.amount,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 25),
            Text(
              'Processing Payment',
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              planName,
              style: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
            ),
            const SizedBox(height: 5),
            Text(
              '${amount.toStringAsFixed(2)} KWD',
              style: GoogleFonts.beVietnamPro(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentProcessingDialog extends StatelessWidget {
  final String methodName;

  const PaymentProcessingDialog({super.key, required this.methodName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 25),
            Text(
              'Completing Payment',
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Via $methodName',
              style: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
            ),
            const SizedBox(height: 5),
            Text(
              'Please wait...',
              style: GoogleFonts.beVietnamPro(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomWebView extends StatefulWidget {
  final String url;

  const CustomWebView({super.key, required this.url});

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Gateway"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                useShouldOverrideUrlLoading: true,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                allowContentAccess: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                supportMultipleWindows: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
                allowsBackForwardNavigationGestures: true,
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _isLoading = false;
              });

              // Check if this is a Google Pay URL and handle accordingly
              if (url != null && url.toString().contains('google.com/pay')) {
                await _handleGooglePayUrl(url.toString());
              }
            },
            onCreateWindow: (controller, createWindowRequest) async {
              // This handles pop-up windows
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: InAppWebView(
                        // Setting up the child webview for the popup
                        initialUrlRequest: URLRequest(
                          url: createWindowRequest.request.url,
                        ),
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            javaScriptEnabled: true,
                            javaScriptCanOpenWindowsAutomatically: true,
                          ),
                        ),
                        onCloseWindow: (controller) {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
              );
              return true;
            },
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint("WebView Console: ${consoleMessage.message}");
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _handleGooglePayUrl(String url) async {
    // You can add specific handling for Google Pay URLs here
    debugPrint("Google Pay URL detected: $url");

    // Optionally, you could launch Google Pay in an external browser
    // if the in-app webview isn't working properly
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
