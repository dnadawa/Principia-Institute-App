import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:principia/widgets/custom-text.dart';

class Announcements extends StatefulWidget {
  final List subjects;

  const Announcements({Key key, this.subjects}) : super(key: key);
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {

  List<DocumentSnapshot> data;
  StreamSubscription<QuerySnapshot> subscription;
  getData() async {
    subscription = FirebaseFirestore.instance.collection('chats').where('subjects', arrayContainsAny: widget.subjects).orderBy('timestamp', descending: true).snapshots().listen((datasnapshot){
      setState(() {
        data = datasnapshot.docs;
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
        title: CustomText(text: 'Announcements',color: Colors.white,),
      ),
      body: Padding(
        padding:  EdgeInsets.fromLTRB(ScreenUtil().setHeight(25),ScreenUtil().setHeight(30),ScreenUtil().setHeight(25),ScreenUtil().setHeight(40)),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                ),
                child: Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                  child: data!=null?
                  data.isNotEmpty?
                  AnimationLimiter(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context,i){
                        String message = data[i]['message'];
                        return AnimationConfiguration.staggeredList(
                            position: i,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              horizontalOffset: 50,
                              child: FadeInAnimation(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: AssetImage('images/logo_black.png'),
                                      backgroundColor: Colors.black,
                                    ),
                                    SizedBox(width: ScreenUtil().setWidth(10),),
                                    ChatBubble(
                                      clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
                                      backGroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                                        ),
                                        child: CustomText(text: message,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        );
                      },
                    ),
                  )
                      :Center(child: CustomText(text: 'There are no announcements!',color: Theme.of(context).primaryColor,size: ScreenUtil().setSp(35),isBold: false,))
                      :Center(child: CircularProgressIndicator(),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
