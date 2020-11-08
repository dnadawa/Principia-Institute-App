import 'package:flutter/material.dart';
import 'custom-text.dart';

class Button extends StatelessWidget {

  final onclick;
  final String text;
  final Color color;
  final Color textColor;
  final bool social;
  final double borderRadius;
  static const Color blackColor = Color(0xff52575D);
  Button({Key key, this.onclick, this.text, this.color: blackColor, this.social=false, this.borderRadius=30, this.textColor=Colors.white,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        onPressed: onclick,
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: color,
        splashColor: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(10),
        child: CustomText(text: text,size: 18,color: textColor,),
      ),
    );
  }
}