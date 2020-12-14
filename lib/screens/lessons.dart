import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:principia/screens/past-lessons.dart';
import 'package:principia/screens/video.dart';
import 'package:principia/widgets/button.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/marquee.dart';
import 'package:principia/widgets/toast.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/mailer.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Lessons extends StatefulWidget {
  final String subject;
  final String phone;
  final String name;
  const Lessons({Key key, this.subject, this.phone, this.name}) : super(key: key);

  @override
  _LessonsState createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  List<DocumentSnapshot> data;
  StreamSubscription<QuerySnapshot> subscription;
  DateTime now;


  getData(){
    subscription = FirebaseFirestore.instance.collection('lessons').where('payed', arrayContains: widget.phone).where('subject', isEqualTo: widget.subject).snapshots().listen((datasnapshot){
      setState(() {
        data = datasnapshot.docs;
        //getCount();
      });
    });
  }

  // List testCounts = [];
  //
  // getCount() async {
  //   testCounts.clear();
  //   for(int i=0;i<data.length;i++){
  //     var sub = await FirebaseFirestore.instance.collection('lessons').doc(data[i].id).collection('payed').where('phone', isEqualTo: widget.phone).get();
  //     var count = sub.docs;
  //     if(count.isNotEmpty){
  //       print('count is :'+count[0]['count'].toString());
  //       setState(() {
  //         testCounts.add(count[0]['count']);
  //       });
  //     }
  //   }
  // }

  getNetworkTime() async {
    now = await NTP.now();
    getData();
  }

  requestCard(BuildContext context, String name,String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(text: 'You can request this lesson if you missed it! Once admin approved it, you can see that lesson on Past Lessons section for a limited time!',align: TextAlign.center,color: Colors.black,),
                SizedBox(height: ScreenUtil().setHeight(50),),
                Button(text: 'Request Now!',color: Color(0xffF89D13),onclick: () async {
                  ToastBar(text: 'Please wait...',color: Colors.orange).show();
                  String username = 'principiagalle@gmail.com';
                  String password = 'admin@principia';

                  final smtpServer = gmail(username, password);
                  // Create our message.
                  final message = Message()
                    ..from = Address(username, 'Principia Edu')
                    ..recipients.add('assist.principia@gmail.com')
                    ..subject = 'New Request for expired lesson!'
                    ..text = 'The User ${widget.phone} requested access for lesson $name ($id)';

                  try {
                    final sendReport = await send(message, smtpServer);
                    print('Message sent: ' + sendReport.toString());
                    ToastBar(text: 'Message Sent!',color: Colors.green).show();
                    Navigator.pop(context);
                  } on MailerException catch (e) {
                    print('Message not sent.');
                    ToastBar(text: 'Something went wrong!',color: Colors.red).show();
                    for (var p in e.problems) {
                      print('Problem: ${p.code}: ${p.msg}');
                    }
                  }
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNetworkTime();
    //getData();
    //Timer(Duration(seconds: 1), ()=>getData());

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
        title: CustomText(text: widget.subject,color: Colors.white,),
        actions: [
          IconButton(icon: Icon(Icons.fast_rewind_rounded),onPressed: (){
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => PastLessons(phone: widget.phone,subject: widget.subject,name: widget.name,)),
            );
          },)
        ],
      ),
      body: Padding(
        padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
        child: data!=null?
        data.isNotEmpty?AnimationLimiter(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context,i){
              int viewCount;
              int adminCount = data[i]['adminCount'];
              //List countList = data[i]['count'];
              //List payedList = data[i]['payed'];
              String id = data[i]['videoId'];
              String title = data[i]['name'];
              String image = data[i]['image'];
              String description = data[i]['description'];
              //int index = payedList.indexOf(widget.phone);
              DateTime expired = DateTime.parse(data[i]['expired']);
              String formattedExpiredDate = DateFormat('yyyy/MM/dd @ hh:mm a').format(expired);
              String status;
              // if(testCounts[i]>=adminCount){
              //   status = 'out-of-views';
              // }
              if(expired.isBefore(now)){
                status = 'session-expired';
              }
              else{
                status = 'ongoing';
              }

              return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: SlideAnimation(
                      child: GestureDetector(
                        onTap: () async {
                          ProgressDialog pr = ProgressDialog(context);
                          pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
                          pr.style(
                              message: 'Please wait...',
                              borderRadius: 10.0,
                              backgroundColor: Colors.white,
                              progressWidget: Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).scaffoldBackgroundColor),)),
                              elevation: 10.0,
                              insetAnimCurve: Curves.easeInOut,
                              messageTextStyle: TextStyle(
                                  color: Colors.black, fontSize: ScreenUtil().setSp(35), fontWeight: FontWeight.bold)
                          );
                          await pr.show();
                          bool isOutOfViews = false;
                          var sub = await FirebaseFirestore.instance.collection('lessons').doc(data[i].id).collection('payed').where('phone', isEqualTo: widget.phone).get();
                          var count = sub.docs;
                          if(count.isNotEmpty){
                            setState(() {
                              viewCount = count[0]['count'];
                              if(viewCount>=adminCount) {
                                isOutOfViews = true;
                              }
                            });
                          }

                          if(isOutOfViews){
                            await pr.hide();
                            ToastBar(text: 'You have reached maximum attempts to watch the lesson!',color: Colors.red).show();
                          }
                          else if(status=='session-expired'){
                            await pr.hide();
                            requestCard(context,title,data[i].id);
                          }
                          else{
                            await pr.hide();
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    content: CustomText(text: 'Are you sure you want to watch this lesson?',color: Colors.black,),
                                    actions: [
                                      FlatButton(onPressed: () async {
                                        // countList[index] = countList[index]+1;
                                        // await FirebaseFirestore.instance.collection('lessons').doc(data[i].id).update({
                                        //   'count' : countList
                                        // });
                                        await pr.show();
                                        await FirebaseFirestore.instance.collection('lessons').doc(data[i].id).collection('payed').doc(widget.phone).update({
                                          'count': viewCount+1
                                        });
                                        //getCount();
                                        await pr.hide();
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(builder: (context) => VideoScreen(
                                            videoId: id,
                                            title: title,
                                            description: description,
                                            id: data[i].id,
                                            phone: widget.phone,
                                            name: widget.name,
                                          )),
                                        );
                                      }, child: CustomText(text: 'Yes',color: Colors.black,)),
                                      FlatButton(onPressed: () async {
                                        Navigator.pop(context);
                                      }, child: CustomText(text: 'No',color: Colors.black,)),
                                    ],
                                  );
                                }
                            );
                          }
                          },
                        child: Card(
                          elevation: 5,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                                        color: Colors.white
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                                      child: SizedBox(
                                        //height: ScreenUtil().setHeight(250),
                                          child: CachedNetworkImage(
                                            imageUrl: image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset('images/logo.png'),
                                          )),
                                    ),
                                  ),
                                ),
                                SizedBox(width: ScreenUtil().setHeight(15),),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        //height: ScreenUtil().setHeight(130),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                          child: Center(child: CustomText(text: title,color: Colors.white,size: ScreenUtil().setSp(35),)),
                                        ),
                                      ),
                                      SizedBox(height: ScreenUtil().setHeight(15),),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(ScreenUtil().setHeight(15)),
                                          child: MarqueeWidget(child: CustomText(text: status=='out-of-views'?'View Attempts Reached':status=='session-expired'?'Session Expired':'Ends in $formattedExpiredDate',color: Colors.red,size: ScreenUtil().setSp(25))),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ));
            },

          ),
      ):Center(child: CustomText(text: 'There are no available lessons right now!',),):Center(child: CircularProgressIndicator(),),
      ),
    );
  }
}
