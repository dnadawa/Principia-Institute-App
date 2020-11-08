import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Color color;

  const HomePage({Key key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
    );
  }
}
