import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:principia/main.dart';
import 'package:principia/widgets/custom-text.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    //Timer(Duration(seconds: 5),()=>Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp()),(Route<dynamic> route)=>false)
    //);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/splash.gif'),
            Align(
                alignment: Alignment.bottomCenter,
                child: CustomText(text: 'Developed by DigiWrecks',size: ScreenUtil().setHeight(30),)),
          ],
        ),
      ),
    );
  }
}
