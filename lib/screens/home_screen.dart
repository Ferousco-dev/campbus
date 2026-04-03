import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/user/user_dashboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions_section.dart';

import '../screens/notifications_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/purchases_screen.dart';
import '../screens/transactions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Please sign in to view your dashboard.',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: UserDashboardService.userStream(user.uid),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final fullName = data['fullName'] as String? ??
            user.displayName ??
            'User';
        final balance =
            (data['walletBalance'] as num?)?.toDouble() ?? 0;

        return StreamBuilder<List<TransactionModel>>(
          stream: UserDashboardService.recentTransactionsStream(user.uid),
          builder: (context, txSnapshot) {
            final transactions = txSnapshot.data ?? [];
            final credits = transactions
                .where((t) => t.isCredit)
                .fold(0.0, (sum, t) => sum + t.amount);
            final debits = transactions
                .where((t) => !t.isCredit)
                .fold(0.0, (sum, t) => sum + t.amount);

            return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: false,
              toolbarHeight: 60,
              title: Row(
                children: [
                   // ... logo text ...
                   Image.asset(
                    'assets/images/logo.png',
                    height: 28,
                    errorBuilder: (_, __, ___) => Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.directions_bus_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Campus Wallet',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: Stack(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Content
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 4),

                // Balance Card
                BalanceCard(
                  balance: balance,
                  totalCredits: credits,
                  totalDebits: debits,
                  userName: fullName.split(' ').first,
                ),

                const SizedBox(height: 20),

                // Stats
                StatsRow(
                  totalCredits: credits,
                  totalDebits: debits,
                ),

                const SizedBox(height: 24),

                // Quick Actions
                QuickActionsGrid(
                  onWalletTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                  },
                  onShopTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                  },
                  onPurchasesTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()));
                  },
                ),

                const SizedBox(height: 24),

                // Recent Transactions
                RecentTransactionsSection(
                  transactions: transactions,
                  onViewAll: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
                  },
                ),

                const SizedBox(height: 28),
              ]),
            ),
          ],
        ),
      ),
    );
          },
        );
      },
    );
  }
}
