import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String planName;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.planName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  MFCardPaymentView? mfCardView;
  MFInitiateSessionResponse? _session;
  bool _isLoading = true;
  bool _isPaymentProcessing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      // 1. Initialize SDK first
      await MFSDK.init(
        "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL",
        MFCountry.KUWAIT,
        MFEnvironment.TEST,
      );

      // 2. Initialize session
      _session = await MFSDK.initSession(
        MFInitiateSessionRequest(customerIdentifier: "unique_customer_id_123"),
        MFLanguage.ENGLISH,
      );

      // 3. Initialize card view AFTER session is created
      mfCardView = MFCardPaymentView(cardViewStyle: _cardViewStyle());

      // 4. Load the card view with session
      await mfCardView!.load(_session!, (bin) {
        debugPrint("BIN detected: $bin");
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize payment: ${e.toString()}';
      });
      debugPrint("Payment initialization error: $_errorMessage");
    }
  }

  MFCardViewStyle _cardViewStyle() {
    MFCardViewStyle cardViewStyle = MFCardViewStyle();
    cardViewStyle.cardHeight = 200;
    cardViewStyle.hideCardIcons = false;
    cardViewStyle.input?.inputMargin = 5;
    cardViewStyle.label?.display = true;
    cardViewStyle.input?.fontFamily = MFFontFamily.Monaco;
    cardViewStyle.label?.fontWeight = MFFontWeight.Heavy;
    return cardViewStyle;
  }

  Future<void> _processPayment() async {
    if (_session == null || mfCardView == null) {
      setState(() {
        _errorMessage = 'Payment not properly initialized';
      });
      return;
    }

    setState(() {
      _isPaymentProcessing = true;
      _errorMessage = '';
    });

    try {
      var request = MFExecutePaymentRequest(invoiceValue: widget.amount);
      request.sessionId = _session?.sessionId;
      request.displayCurrencyIso = MFCurrencyISO.KUWAIT_KWD;
      request.paymentMethodId = 1; // KNET for testing

      final response = await mfCardView!.pay(request, MFLanguage.ENGLISH, (
        invoiceId,
      ) {
        debugPrint("Payment initiated with invoice ID: $invoiceId");
        _showSuccessScreen(invoiceId.toString());
        return invoiceId.toString();
      });

      debugPrint("Payment response: $response");
    } catch (e) {
      setState(() {
        _isPaymentProcessing = false;
        _errorMessage = 'Payment failed: ${e.toString()}';
      });
      debugPrint("Payment processing error: $_errorMessage");
    }
  }

  void _showSuccessScreen(String invoiceId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentSuccessScreen(
              invoiceId: invoiceId,
              amount: widget.amount,
              planName: widget.planName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: GoogleFonts.beVietnamPro()),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanInfo(),
                    const SizedBox(height: 24),
                    _buildEmbeddedPayment(),
                    const SizedBox(height: 24),
                    _buildPayButton(),
                  ],
                ),
              ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            Text(
              'Payment Error',
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              style: GoogleFonts.beVietnamPro(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.beVietnamPro(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.verified_user, color: Color(0xFF2E7D32), size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.planName,
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.amount.toStringAsFixed(2)} KWD',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 22,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddedPayment() {
    return Column(
      children: [
        const Text(
          'Enter your card details securely',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: mfCardView ?? const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPaymentProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
        ),
        child:
            _isPaymentProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  'PAY ${widget.amount.toStringAsFixed(2)} KWD',
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  final String invoiceId;
  final double amount;
  final String planName;

  const PaymentSuccessScreen({
    super.key,
    required this.invoiceId,
    required this.amount,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$planName Subscription',
                style: GoogleFonts.beVietnamPro(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '${amount.toStringAsFixed(2)} KWD',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Invoice ID: $invoiceId',
                style: GoogleFonts.beVietnamPro(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
