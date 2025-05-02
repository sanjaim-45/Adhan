import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:prayerunitesss/providers/auth_providers.dart';
import 'package:prayerunitesss/providers/user_details_from_login/user_details.dart';
import 'package:prayerunitesss/ui/screens/subscription/upgrade.dart';
import 'package:prayerunitesss/ui/widgets/spalsh_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserDetailsProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',

        theme: ThemeData(
          // fontFamily: "Neue-Plak",
          primaryColor: const Color(0xFF0C5E38),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home:  SplashScreen(),
      ),
    );
  }
}