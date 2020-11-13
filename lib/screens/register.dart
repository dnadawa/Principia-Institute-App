import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:principia/screens/login.dart';
import 'package:principia/screens/otp-verification.dart';
import 'package:principia/widgets/button.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/inputfield.dart';
import 'package:principia/widgets/toast.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController year = TextEditingController();

  String stream;
  String institute;
  double _opacity;
  List<DropdownMenuItem<String>> streamList = [];
  List<MultiSelectItem> subjectsList = [];
  List subs = [];


  getStreams() async {
        await Firebase.initializeApp();
        var sub = await FirebaseFirestore.instance.collection('streams').get();
        List streams = sub.docs;
        if(streams.isNotEmpty){
          stream = streams[0]['name'];
          for(int i=0;i<streams.length;i++){
            setState(() {
              streamList.add(
                DropdownMenuItem(child: CustomText(text:streams[i]['name'],color: Colors.white,),value: streams[i]['name'],),
              );
            });
          }
          getSubjects(stream);
        }
  }

  getSubjects(String name) async {
    subjectsList.clear();
    var sub = await FirebaseFirestore.instance.collection('streams').where('name', isEqualTo: name).get();
    var subjects = sub.docs;
    for(int i=0;i<subjects[0]['subjects'].length;i++){
      setState(() {
        subjectsList.add(
          MultiSelectItem(subjects[0]['subjects'][i],subjects[0]['subjects'][i])
        );
      });
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    institute = 'Principia - Galle';
    _opacity = 1;
    getStreams();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(35),ScreenUtil().setWidth(35),ScreenUtil().setWidth(35),0),
          child: Column(
            children: [
              Expanded(
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
                            CustomText(text: 'Register your account',size: ScreenUtil().setSp(60),align: TextAlign.start,),
                            Center(
                              child: SizedBox(
                                  width: ScreenUtil().setHeight(300),
                                  height: ScreenUtil().setWidth(300),
                                  child: Image.asset('images/register.jpg')),
                            ),
                            InputField(hint: 'Name',controller: name,),
                            InputField(hint: 'Phone Number (07xxxxxxxx)',type: TextInputType.phone,controller: phone,length: 10,),
                            InputField(hint: 'Password',controller: password,ispassword: true,),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
                              child: CustomText(text: 'Stream',size: ScreenUtil().setSp(35),),
                            ),
                            Center(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).primaryColor,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                                  child: DropdownButton(
                                    underline: Divider(color: Theme.of(context).primaryColor,height: 0,thickness: 0,),
                                    dropdownColor: Theme.of(context).primaryColor,
                                    iconEnabledColor: Colors.white,
                                    isExpanded: true,
                                    items: streamList,
                                    onChanged:(newValue){
                                      setState(() {
                                        _opacity = 0;
                                        stream = newValue;
                                        subs.clear();
                                        getSubjects(stream);
                                        Timer(Duration(milliseconds: 400), (){_opacity = 1;setState(() {});});
                                      });
                                    },
                                    value: stream,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(40),),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.fastOutSlowIn,
                              opacity: _opacity,
                              child: MultiSelectChipField(
                                title: Text('Subjects',style: TextStyle(color: Colors.white),),
                                headerColor: Theme.of(context).primaryColor,
                                chipShape: Border.all(color: Theme.of(context).primaryColor),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).primaryColor,width: 2),
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))
                                ),
                                selectedChipColor: Theme.of(context).scaffoldBackgroundColor,
                                selectedTextStyle: TextStyle(color: Colors.white),
                                items: subjectsList,
                                icon: Icon(Icons.check,color: Colors.white,),
                                onTap: (l){
                                  subs = l;
                                  print(subs);
                                  },
                              ),
                            ),

                            InputField(hint: 'A/L Year',controller: year,type: TextInputType.number,),

                            Padding(
                              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
                              child: CustomText(text: 'Institute',size: ScreenUtil().setSp(35),),
                            ),
                            Center(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                                  child: DropdownButton(
                                    underline: Divider(color: Theme.of(context).primaryColor,height: 0,thickness: 0,),
                                    dropdownColor: Theme.of(context).primaryColor,
                                    iconEnabledColor: Colors.white,
                                    isExpanded: true,
                                    items: <DropdownMenuItem>[
                                      DropdownMenuItem(child: CustomText(text: 'Principia - Galle',color: Colors.white,),value: 'Principia - Galle',),
                                      DropdownMenuItem(child: CustomText(text: 'Pubudu - Ambalangoda',color: Colors.white,),value: 'Pubudu - Ambalangoda',),
                                      DropdownMenuItem(child: CustomText(text: 'Sakya - Matara',color: Colors.white,),value: 'Sakya - Matara',),
                                    ],
                                    onChanged:(newValue){
                                      setState(() {
                                        institute = newValue;
                                      });
                                    },
                                    value: institute,
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                              child: Button(text: 'Register',onclick: () async {

                                if(name.text!=''&&phone.text!=''&&year.text!=''&&password.text!=''&&subs.length>0){
                                      if(phone.text.length == 10){
                                        var sub  = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phone.text).get();
                                        var numList = sub.docs;
                                        if(numList.isEmpty){
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(builder: (context) => OTP(
                                              name: name.text,
                                              institute: institute,
                                              password: password.text,
                                              phone: phone.text,
                                              stream: stream,
                                              year: year.text,
                                              subjects: subs,
                                            )),
                                          );
                                        }
                                        else{
                                          ToastBar(text: 'Phone number already registered!',color: Colors.red).show();
                                        }
                                      }
                                      else{
                                        ToastBar(text: 'Phone number must be 10 characters!',color: Colors.red).show();
                                      }
                                }
                                else{
                                  ToastBar(text: 'Please fill all fields!',color: Colors.red).show();
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(45)),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: CustomText(text: "Do you have an account? Log in",color: Colors.white, size: ScreenUtil().setSp(30),)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//Gradient Code
// decoration: BoxDecoration(
// gradient: RadialGradient(
// colors: [Color(0xffF89D13),Color(0xffFDDB3A)],
// radius: 4,
// center: Alignment.topCenter
// )
// ),