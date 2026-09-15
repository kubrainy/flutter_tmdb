import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo ({super.key , this.fontSize = 20, this.showText = true});
  final double fontSize;
  final bool showText;

  @override
  Widget build(BuildContext context){
    final pill = Container(
      width: fontSize *2.3,
      height: fontSize * 0.6,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(fontSize * 0.3),
      ),
    );

    if (!showText) return pill;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('TMDB',
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800 , letterSpacing: 1.5),),
        SizedBox(width: fontSize *0.4),
        pill,
      ],
    );
 }
}