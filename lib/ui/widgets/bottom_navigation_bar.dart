import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -3), // Shadow above the nav bar
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.w500,
        ),
        selectedItemColor: const Color(0xFF0C5E38), // Green
        unselectedItemColor: Colors.black, // Black
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              currentIndex == 0
                  ? 'assets/images/bottom_navigaton/home/inactive_home.png'
                  : 'assets/images/bottom_navigaton/home/active_home.png',
              height: screenHeight * 0.025,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              currentIndex == 1
                  ? 'assets/images/bottom_navigaton/history/prayer_active.png'
                  : 'assets/images/bottom_navigaton/history/prayer_inactive.png',
              height: screenHeight * 0.025,
            ),
            label: 'Prayer Times',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              currentIndex == 2
                  ? 'assets/images/bottom_navigaton/profile/acitve_users.png'
                  : 'assets/images/bottom_navigaton/profile/li_user.png',
              height: screenHeight * 0.025,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
