// import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
//
// class PaymentService {
//   static const String _testApiKey =
//       "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL";
//   static Future<void> initialize() async {
//     await MFSDK.init(
//       _testApiKey,
//       MFCountry.KUWAIT,
//       MFEnvironment.TEST, // Change to LIVE for production
//     );
//
//     // Customize the payment UI
//     MFSDK.setUpActionBar(
//       toolBarTitle: 'Premium Subscription',
//       toolBarTitleColor: '#FFFFFF',
//       toolBarBackgroundColor: '#2E7D32',
//       isShowToolBar: true,
//     );
//   }
//
//   static Future<MFInitiateSessionResponse?> createPaymentSession() async {
//     try {
//       return await MFSDK.initSession(
//         MFInitiateSessionRequest(),
//         MFLanguage.ENGLISH,
//       );
//     } on MFError catch (mfError) {
//       throw PaymentException(
//         code: mfError.message ?? 'SESSION_ERROR',
//         message: mfError.message ?? 'Failed to create payment session',
//         details: mfError.message?.toString(),
//       );
//     } catch (e) {
//       throw PaymentException(
//         code: 'UNKNOWN_ERROR',
//         message: 'Failed to create payment session',
//         details: e.toString(),
//       );
//     }
//   }
//
//   static Future<Object> processPayment({
//     required double amount,
//     required int paymentMethodId,
//     String? sessionId,
//     MFCard? cardDetails,
//   }) async {
//     try {
//       final request = MFExecutePaymentRequest(invoiceValue: amount);
//       request.paymentMethodId = paymentMethodId;
//
//       if (sessionId != null) {
//         request.sessionId = sessionId;
//       }
//
//       if (cardDetails != null) {
//         final directRequest = MFDirectPaymentRequest(
//           executePaymentRequest: request,
//           card: cardDetails,
//           token: null,
//         );
//
//         return await MFSDK.executeDirectPayment(
//           directRequest,
//           MFLanguage.ENGLISH,
//           (invoiceId) => invoiceId.toString(),
//         );
//       }
//       return await MFSDK.executePayment(
//         request,
//         MFLanguage.ENGLISH,
//         (invoiceId) => invoiceId.toString(),
//       );
//     } on MFError catch (mfError) {
//       throw PaymentException(
//         code: mfError.message ?? 'PAYMENT_ERROR',
//         message: mfError.message ?? 'Payment processing failed',
//         details: mfError.message?.toString(),
//       );
//     } catch (e) {
//       throw PaymentException(
//         code: 'UNKNOWN_ERROR',
//         message: 'Payment processing failed',
//         details: e.toString(),
//       );
//     }
//   }
// }
//
// class PaymentException implements Exception {
//   final String code;
//   final String message;
//   final String? details;
//
//   PaymentException({required this.code, required this.message, this.details});
//
//   String get formattedMessage {
//     if (details != null) {
//       return '$message\n\nError code: $code\nDetails: $details';
//     }
//     return '$message\n\nError code: $code';
//   }
//
//   @override
//   String toString() => formattedMessage;
// }
