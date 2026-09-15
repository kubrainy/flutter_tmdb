import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/media_item.dart';
import 'home_screen.dart';
import 'media_list_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _tabs = [
    HomePage(onNavigateToTab: _goToTab),
    const MediaListScreen(title: 'Filmler', mediaType: MediaType.movie),
    const MediaListScreen(title: 'Diziler', mediaType: MediaType.tv),
    const ProfileScreen(),
  ];

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SizedBox(
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: -30,
              child: Container(
                width: 220,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.pinkAccent.withValues(alpha: 0.55),
                      Colors.purpleAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: 54,
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _navItem(
                          icon: Icons.home_rounded,
                          selected: _selectedIndex == 0,
                          onPressed: () => setState(() => _selectedIndex = 0),
                        ),
                        _navItem(
                          icon: Icons.movie_outlined,
                          selected: _selectedIndex == 1,
                          onPressed: () => setState(() => _selectedIndex = 1),
                        ),
                        _navItem(
                          icon: Icons.live_tv,
                          selected: _selectedIndex == 2,
                          onPressed: () => setState(() => _selectedIndex = 2),
                        ),
                        _navItem(
                          icon: Icons.person_outline,
                          selected: _selectedIndex == 3,
                          onPressed: () => setState(() => _selectedIndex = 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      alignment: Alignment.center,
      onPressed: onPressed,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? Colors.white : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
