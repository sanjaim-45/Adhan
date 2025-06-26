import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayerunitesss/providers/auth_providers.dart';
import 'package:prayerunitesss/ui/widgets/main_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/user_details_from_login/user_details.dart';
import '../../service/api/templete_api/api_service.dart';
import '../../service/api/tokens/token_service.dart';
import '../../utils/app_urls.dart';
import '../screens/login_page/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _initializeApp();
      }
    });
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshed =
          await ApiService(baseUrl: AppUrls.appUrl).refreshToken();
      if (refreshed) {
        TokenRefreshService().start();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // In SplashScreen._initializeApp()
  Future<void> _initializeApp() async {
    try {
      // Load user details first
      await Provider.of<UserDetailsProvider>(
        context,
        listen: false,
      ).loadUserDetails();

      final auth = Provider.of<AuthProvider>(context, listen: false);

      // Check if we should maintain session
      final shouldMaintain = await TokenService.shouldMaintainSession();

      if (shouldMaintain && await TokenService.hasRefreshToken()) {
        // Try to refresh token if we have internet
        final hasConnection =
            await TokenRefreshService().checkInternetConnection();

        if (hasConnection) {
          final refreshed = await _attemptTokenRefresh();
          if (refreshed) {
            await auth.softLogin();
            _navigateToHome();
            return;
          }
        } else {
          // Offline but have tokens - proceed to home
          if (auth.isLoggedIn == true) {
            _navigateToHome();
            return;
          }
        }
      }

      // Normal auth check
      await auth.checkAuthStatus();

      if (auth.isLoggedIn == true) {
        _navigateToHome();
      } else {
        setState(() => _showButton = true);
      }
    } catch (e) {
      setState(() => _showButton = true);
    }
  }

  void _navigateToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3B873E),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/spalsh_screen.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/logo.png',
                height: height * 0.2,
                width: width * 0.4,
              ),
            ),
          ),
          if (_showButton)
            Positioned(
              bottom: height * 0.05,
              left: width * 0.08,
              right: width * 0.08,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                offset: _showButton ? Offset.zero : const Offset(0, 0.5),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _showButton ? 1.0 : 0.0,
                  child: ElevatedButton(
                    onPressed: _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF3B873E),
                      padding: EdgeInsets.symmetric(vertical: height * 0.015),
                      textStyle: GoogleFonts.beVietnamPro(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.beVietnamPro(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
