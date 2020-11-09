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

import 'home-structure.dart';

class OTP extends StatefulWidget {
  final String name;
  final String phone;
  final String password;
  final String stream;
  final String year;
  final String institute;
  final List subjects;

  const OTP({Key key, this.name, this.phone, this.password, this.stream, this.year, this.institute, this.subjects}) : super(key: key);
  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _animation;
  bool showResend;
  TextEditingController code = TextEditingController();
  String gVerificationId;
  FirebaseAuth auth = FirebaseAuth.instance;

  sendOtp() async {
    var phone = widget.phone.substring(widget.phone.length - 9);
    await auth.verifyPhoneNumber(
      phoneNumber: '+94$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('verification completed');
        },
      verificationFailed: (FirebaseAuthException e) {
        print('verification failed'+e.toString());
        ToastBar(text: 'Too many Requests! Please Try Again Later!',color: Colors.red).show();
      },
      codeSent: (String verificationId, int resendToken) async {
        print('code sent');
        gVerificationId = verificationId;
        ToastBar(text: 'Code Sent!',color: Colors.orange).show();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          showResend = true;
        });
      },
    );
  }

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
    super.initState();
    showResend = false;
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
      sendOtp();
      getDeviceID();
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
                              CustomText(text: 'Verify phone',size: ScreenUtil().setSp(60),align: TextAlign.start,),
                              Padding(
                                padding:  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(60)),
                                child: Center(
                                  child: SizedBox(
                                      width: ScreenUtil().setHeight(300),
                                      height: ScreenUtil().setWidth(300),
                                      child: Image.asset('images/verify.png')),
                                ),
                              ),
                              CustomText(text: 'You will receieve a 6 digit code to verify your phone number. Enter the code to complete the verification',size: ScreenUtil().setSp(30),),
                              Padding(
                                padding:  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(50)),
                                child: PinInputTextField(
                                  decoration: BoxLooseDecoration(
                                    strokeColorBuilder: PinListenColorBuilder(Theme.of(context).scaffoldBackgroundColor, Theme.of(context).primaryColor),
                                  radius: Radius.circular(10),
                                    gapSpace: 5,
                                    strokeWidth: 2,
                                  ),
                                  controller: code,
                                  pinLength: 6,
                                ),
                              ),
                              Visibility(
                                visible: showResend,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(45)),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            showResend = false;
                                          });
                                          sendOtp();
                                        },
                                        child: CustomText(text: "Didn\'t received a code ? Resend",size: ScreenUtil().setSp(30),)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                                child: Button(text: 'Verify and Create account',onclick: () async {
                                  try{
                                    ToastBar(text: 'Please wait...',color: Colors.orangeAccent).show();
                                    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: gVerificationId, smsCode: code.text);
                                    await auth.signInWithCredential(phoneAuthCredential);

                                    await FirebaseFirestore.instance.collection('users').doc(widget.phone).set({
                                      'name': widget.name,
                                      'phone': widget.phone,
                                      'password': widget.password,
                                      'stream': widget.stream,
                                      'subjects': widget.subjects,
                                      'year': widget.year,
                                      'institute': widget.institute,
                                      'deviceId': deviceID
                                    });
                                    ToastBar(text: 'Registered Successfully!',color: Colors.green).show();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        SlideDownRoute(page: HomeStructure(phone: widget.phone,)), (Route<dynamic> route) => false);
                                  }
                                  on FirebaseAuthException catch(e){
                                    if(e.code == 'session-expired'){
                                      ToastBar(text: 'Code is expired!',color: Colors.red).show();
                                    }
                                    else if(e.code == 'invalid-verification-code'){
                                      ToastBar(text: 'Code is invalid!',color: Colors.red).show();
                                    }
                                  }
                                  catch(e){
                                    ToastBar(text: 'Something went wrong!',color: Colors.red).show();
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
