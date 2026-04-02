import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ShopBannerCarousel extends StatefulWidget {
  const ShopBannerCarousel({super.key});

  @override
  State<ShopBannerCarousel> createState() => _ShopBannerCarouselState();
}

class _ShopBannerCarouselState extends State<ShopBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_BannerData> _banners = const [
    _BannerData(
      title: 'Cafeteria Vouchers',
      subtitle: 'Grab a ₦1,000 meal voucher — eat anywhere on campus!',
      icon: Icons.restaurant_rounded,
      gradient: [Color(0xFFE88B00), Color(0xFFF5A623)],
    ),
    _BannerData(
      title: 'Inteco WiFi',
      subtitle: 'Stay connected on campus for just ₦100/day',
      icon: Icons.wifi_rounded,
      gradient: [Color(0xFF00A36E), Color(0xFF00C6AE)],
    ),
    _BannerData(
      title: 'Past Questions Pack',
      subtitle: 'Get 5-year compiled answers — 40% off this week!',
      icon: Icons.quiz_rounded,
      gradient: [Color(0xFF6C3FD8), Color(0xFF9B5CF6)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (index) =>
                  setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return _BannerCard(data: banner);
              },
            ),
          ),
          const SizedBox(height: 10),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;

  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: data.gradient.first.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              data.icon,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
