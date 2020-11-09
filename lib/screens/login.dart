import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:principia/widgets/animated-transition.dart';
import 'package:principia/widgets/button.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/inputfield.dart';
import 'package:principia/widgets/toast.dart';
import 'home-structure.dart';
import 'otp-verification-login.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{

  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  AnimationController _controller;
  Animation<double> _animation;
  String deviceID;
  getDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceID = androidInfo.androidId;
    }
    else{
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceID = iosInfo.identifierForVendor;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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
        appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
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
                              CustomText(text: 'Log into your account',size: ScreenUtil().setSp(60),align: TextAlign.start,),
                              Center(
                                child: SizedBox(
                                    width: ScreenUtil().setHeight(300),
                                    height: ScreenUtil().setWidth(300),
                                    child: Image.asset('images/login.png')),
                              ),
                              InputField(hint: 'Phone Number (07xxxxxxxx)',type: TextInputType.phone,controller: phone,length: 10,),
                              InputField(hint: 'Password',controller: password,ispassword: true,),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                                child: Button(text: 'Login',onclick: () async {
                                  ToastBar(text: 'Please wait...',color: Colors.orange).show();
                                  await getDeviceID();
                                  var sub = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phone.text).get();
                                  var users = sub.docs;
                                  if(users.isNotEmpty){
                                    if(users[0]['password']==password.text){
                                      if(users[0]['deviceId']==deviceID){
                                        Navigator.of(context).pushAndRemoveUntil(
                                            SlideDownRoute(page: HomeStructure(phone: phone.text,)), (Route<dynamic> route) => false);
                                      }
                                      else{
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(builder: (context) => OTPLogin(phone: phone.text,)),
                                        );
                                      }
                                    }
                                    else{
                                      ToastBar(text: 'Password wrong!',color: Colors.red).show();
                                    }
                                  }
                                  else{
                                    ToastBar(text: 'User not found!',color: Colors.red).show();
                                  }
                                }),
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
