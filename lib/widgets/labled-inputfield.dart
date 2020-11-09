import 'package:flutter/material.dart';

class LabeledInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType type;

  const LabeledInputField({Key key, this.controller, this.hint, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.black,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold
        ),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor,width: 3),borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor,width: 3),borderRadius: BorderRadius.circular(10)),
          labelText: hint,
        ),
        keyboardType: type,
      ),
    );
  }
}
