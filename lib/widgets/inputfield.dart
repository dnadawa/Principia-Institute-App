import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class InputField extends StatelessWidget {

  final String hint;
  final TextInputType type;
  final bool ispassword;
  final TextEditingController controller;
  final int length;


  const InputField({Key key, this.hint, this.type, this.ispassword=false, this.controller, this.length}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color blackColor = Color(0xff52575D);
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: blackColor,
    );
    return Padding(
      padding:  EdgeInsets.only(top: 20),
      child: TextField(
        style: textStyle,
        maxLength: length,
        cursorColor: blackColor,
        keyboardType: type,
        controller: controller,
        obscureText: ispassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: textStyle,
          enabledBorder:UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor, width: 5),
          ),

        ),
      ),
    );
  }
}