import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:principia/widgets/animated-transition.dart';
import 'package:principia/widgets/button.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home-structure.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    Timer(Duration(milliseconds: 500),(){
      _controller.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(elevation: 0,backgroundColor: Colors.transparent,),
        body: Padding(
          padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(35),0,ScreenUtil().setWidth(35),ScreenUtil().setWidth(35)),
          child: Column(
            children: [
              Expanded(
                child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        )
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(35)),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: ScreenUtil().setHeight(30),),
                              CustomText(text: 'Contact us',size: ScreenUtil().setSp(60),align: TextAlign.start,),
                              Padding(
                                padding:  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(60)),
                                child: Center(
                                  child: SizedBox(
                                      width: ScreenUtil().setHeight(250),
                                      height: ScreenUtil().setWidth(250),
                                      child: Image.asset('images/contact.jpg')),
                                ),
                              ),
                              CustomText(text: 'If you have any problems or if you need any help, please contact us on following ways!',align: TextAlign.start,),
                              SizedBox(height: ScreenUtil().setHeight(25),),
                              Card(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                                  child: Column(
                                    children: [
                                      CustomText(text: 'Contact us through an email for further clarification about your problem. We will reply to you as soon as possible',isBold: false,align: TextAlign.start),
                                      SizedBox(height: ScreenUtil().setHeight(25),),
                                      Button(text: 'Send an email',color: Theme.of(context).scaffoldBackgroundColor,onclick: () async {
                                        var url = 'mailto:info@principia.edu.lk?subject=Principia Edu&body=';
                                        if (await canLaunch(url)) {
                                        await launch(url);
                                        } else {
                                        throw 'Could not launch $url';
                                        }
                                      },)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: ScreenUtil().setHeight(25),),
                              Card(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                                  child: Column(
                                    children: [
                                      CustomText(text: 'Make a phone call for solve your issue soon. Phone line available at following hours',isBold: false,align: TextAlign.start),
                                      SizedBox(height: ScreenUtil().setHeight(25),),
                                      CustomText(text: 'Mon - Fri : 8.30 a.m to 5.00 p.m',align: TextAlign.center,size: ScreenUtil().setSp(35)),
                                      SizedBox(height: ScreenUtil().setHeight(25),),
                                      Button(text: 'Make a phone call',color: Theme.of(context).scaffoldBackgroundColor,onclick: () async {
                                        var url = 'tel://+94775612032';
                                        if (await canLaunch(url)) {
                                        await launch(url);
                                        } else {
                                        throw 'Could not launch $url';
                                        }
                                      },)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: ScreenUtil().setHeight(25),),
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    var url = 'https://www.digiwrecks.com';
                                    if (await canLaunch(url)) {
                                    await launch(url);
                                    } else {
                                    throw 'Could not launch $url';
                                    }
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Developed by ',
                                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: ScreenUtil().setSp(30)),
                                      children: <TextSpan>[
                                        TextSpan(text: 'DigiWrecks', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.deepPurpleAccent)),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
