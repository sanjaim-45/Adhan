import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_details_from_login/user_details.dart';
import '../screens/login_page/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    // Load user details when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserDetailsProvider>(context, listen: false).loadUserDetails();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _showButton = true;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) =>  LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size; // 📱 Get device size
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3B873E),
      body: Stack(
        children: [
          // Full screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/spalsh_screen.png',
              fit: BoxFit.cover,
            ),
          ),
          // Animated centered logo
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
                height: height * 0.2, // 📏 20% of screen height
                width: width * 0.4,    // 📏 40% of screen width
              ),
            ),
          ),
          // Animated "Get Started" Button (only after logo animation)
          if (_showButton)
            Positioned(
              bottom: height * 0.05,
              left: width * 0.08,
              right: width * 0.08,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut, // Smooth ease out
                offset: _showButton ? Offset(0, 0) : const Offset(0, 0.5), // 👈 Slide from bottom
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _showButton ? 1.0 : 0.0,
                  child: ElevatedButton(
                    onPressed: _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF3B873E),
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.015,
                      ),
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
