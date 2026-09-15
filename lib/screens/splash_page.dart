import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tmdb/core/widgets/brand_logo.dart';
import 'main_nav_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return; 
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(fontSize: 44),
            const SizedBox(height: 16),
            const Text(
              'The Movie Database',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 0.5,
                color: Color(0xFF9A93B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
