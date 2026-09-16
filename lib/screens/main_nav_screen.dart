import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/media_item.dart';
import 'home_screen.dart';
import 'media_list_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
final Set<int> _loadedTabs = {0};

void _goToTab(int index) {
  setState(() {
    _selectedIndex = index;
    _loadedTabs.add(index);
  });
}

Widget _buildTab(int index) {
  if (!_loadedTabs.contains(index)) {
    return const SizedBox.shrink();
  }
  switch (index) {
    case 0:
      return HomePage(onNavigateToTab: _goToTab);
    case 1:
      return const MediaListScreen(title: 'Filmler', mediaType: MediaType.movie);
    case 2:
      return const MediaListScreen(title: 'Diziler', mediaType: MediaType.tv);
    case 3:
      return const ProfileScreen();
    default:
      return const SizedBox.shrink();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(4, _buildTab),
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.accentPink],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.accentPink.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        color: Colors.transparent,
        elevation: 0,
        height: 56,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _navItem(
                icon: Icons.home_rounded,
                selected: _selectedIndex == 0,
                onPressed: () => _goToTab(0),
              ),
              _navItem(
                icon: Icons.movie_creation_rounded,
                selected: _selectedIndex == 1,
                onPressed: () => _goToTab(1),
              ),
              const SizedBox(width: 56),
              _navItem(
                icon: Icons.tv_rounded,
                selected: _selectedIndex == 2,
                onPressed: () => _goToTab(2),
              ),
              _navItem(
                icon: Icons.person_rounded,
                selected: _selectedIndex == 3,
                onPressed: () => _goToTab(3),
              ),
            ],
          ),
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
      icon: Icon(
        icon,
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
        size: selected ? 20 : 17,
      ),
    );
  }
}
