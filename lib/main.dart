import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:prayerunitesss/providers/auth_providers.dart';
import 'package:prayerunitesss/providers/check_customer/customer_provider.dart';
import 'package:prayerunitesss/providers/device_request/device_request_provider.dart';
import 'package:prayerunitesss/providers/notification/notification_provider.dart';
import 'package:prayerunitesss/providers/subscription/subscription.dart';
import 'package:prayerunitesss/providers/subscription/subscription_provider.dart';
import 'package:prayerunitesss/providers/user_details_from_login/user_details.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:prayerunitesss/service/api/tokens/token_service.dart';
import 'package:prayerunitesss/ui/screens/login_page/login_page.dart';
import 'package:prayerunitesss/ui/widgets/main_screen.dart';
import 'package:prayerunitesss/ui/widgets/prayer_card.dart';
import 'package:prayerunitesss/ui/widgets/spalsh_screen.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:prayerunitesss/utils/firebase/default_firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late AudioHandler _audioHandler;

// Background message handler (must be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Add your background message handling logic here
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    name: 'adhan',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MFSDK.init(
    "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL",
    MFCountry.KUWAIT,
    MFEnvironment.TEST,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize audio service
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.yourcompany.yourapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService apiService = ApiService(baseUrl: AppUrls.appUrl);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize token refresh service if needed
    if (await TokenService.hasValidTokens() &&
        await TokenService.shouldMaintainSession()) {
      TokenRefreshService().start();
    }
  }

  @override
  void dispose() {
    TokenRefreshService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => UserDetailsProvider()..loadUserDetails(),
        ),
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => DeviceRequestProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProviders()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
        home: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SplashScreen();
            }

            final prefs = snapshot.data as SharedPreferences;
            final customerId = prefs.getString('customerId');

            return Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.isLoggedIn == null) return const SplashScreen();
                return (auth.isLoggedIn! && customerId != null)
                    ? const MainScreen()
                    : const LoginPage();
              },
            );
          },
        ),
      ),
    );
  }
}
