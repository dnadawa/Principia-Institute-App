import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:principia/screens/contact.dart';
import 'package:principia/screens/lessons.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/marquee.dart';

class HomePage extends StatefulWidget {
  final List name;
  final String stream;
  final String phone;
  final List subjects;
  final String fullname;

  const HomePage({Key key, this.name, this.stream, this.subjects, this.phone, this.fullname}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DocumentSnapshot> data;
  StreamSubscription<QuerySnapshot> subscription;
  List subjectIcons = [];

  getData() async {
    subscription = FirebaseFirestore.instance.collection('streams').where('name', isEqualTo: widget.stream).snapshots().listen((datasnapshot){
      setState(() {
        data = datasnapshot.docs;
        List allSubIcon = data[0]['icons'];
        List allSubs = data[0]['subjects'];
        for(int i=0;i<widget.subjects.length;i++){
          int index = allSubs.indexOf(widget.subjects[i]);
          subjectIcons.add(allSubIcon[index]);
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Home',color: Colors.white,),
        actions: [
          IconButton(icon: Icon(Icons.help_outline), onPressed: (){
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => Contact()),
            );
          })
        ],
      ),
      body: Padding(
        padding:  EdgeInsets.all(ScreenUtil().setWidth(35)),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: ScreenUtil().screenHeight/6,
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.topRight,
                        child: Image.asset('images/home.png')
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Hello,',size: ScreenUtil().setSp(45),color: Theme.of(context).scaffoldBackgroundColor,),
                        SizedBox(height: ScreenUtil().setWidth(20),),
                        Container(
                          width: ScreenUtil().setWidth(480),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: MarqueeWidget(
                            child: CustomText(
                              text: widget.name[0],
                              size: ScreenUtil().setSp(50),
                              align: TextAlign.start,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                elevation: 5,
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(35)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: ScreenUtil().setWidth(60),
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: ScreenUtil().setWidth(55),
                          child: SizedBox(
                              width:  ScreenUtil().setWidth(70),
                              height:  ScreenUtil().setWidth(70),
                              child: Image.asset('images/homeicon.png')),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(30),),
                      Flexible(
                          child: CustomText(text: 'Select a subject to view the lessons',color: Colors.white,size: ScreenUtil().setSp(35),isBold: false,))
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(50)),
                child: Container(
                  width: double.infinity,
                  child: data!=null?CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      viewportFraction: 0.7,
                      enlargeCenterPage: true,
                      pauseAutoPlayOnTouch: true,
                      aspectRatio: 192/225,
                      initialPage: 0,
                      //height: ScreenUtil().setHeight(500)
                    ),
                    itemCount: widget.subjects.length,
                    itemBuilder: (context,i){
                      String image = subjectIcons[i];
                      String subject = widget.subjects[i];
                      return Padding(
                        padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              CupertinoPageRoute(builder: (context) => Lessons(subject: subject,phone: widget.phone,name: widget.fullname,)),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                                  child: SizedBox(
                                      height: ScreenUtil().setHeight(280),
                                      width: ScreenUtil().setHeight(280),
                                      child: CachedNetworkImage(
                                        imageUrl: image,
                                        placeholder: (context, url) => Image.asset('images/logo.png'),
                                      )),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xffF89D13),Color(0xffFFCB08)],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        ),
                                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                                        border: Border.all(color: Colors.white,width: 3)
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                                        child: CustomText(text: subject,color: Colors.white,size: ScreenUtil().setSp(50),),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ):Center(child: CircularProgressIndicator(),),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
