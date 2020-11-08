import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {

  final String text;
  final double size;
  final Color color;
  final TextAlign align;
  final bool isBold;
  final String font;
  const CustomText({Key key, this.text, this.size, this.color, this.align=TextAlign.center, this.isBold=true, this.font}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: color==null?Color(0xff52575D):color,
        fontFamily: font,
        fontWeight: isBold?FontWeight.bold:FontWeight.normal,
        fontSize: size,
      ),
    );
  }
}