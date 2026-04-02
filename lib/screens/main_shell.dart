import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/card_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/wallet_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WalletScreen(),
    const ShopScreen(),
    const CardScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
