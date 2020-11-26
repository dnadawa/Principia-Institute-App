import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:principia/screens/video.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/marquee.dart';
import 'package:principia/widgets/toast.dart';

class PastLessons extends StatefulWidget {
  final String subject;
  final String phone;
  final String name;
  const PastLessons({Key key, this.subject, this.phone, this.name}) : super(key: key);

  @override
  _PastLessonsState createState() => _PastLessonsState();
}

class _PastLessonsState extends State<PastLessons> {
  List<DocumentSnapshot> data;
  StreamSubscription<QuerySnapshot> subscription;
  DateTime now;

  getData(){
    subscription = FirebaseFirestore.instance.collection('lessons').where('past', arrayContains: widget.phone).where('subject', isEqualTo: widget.subject).snapshots().listen((datasnapshot){
      setState(() {
        data = datasnapshot.docs;
      });
    });

  }

  getNetworkTime() async {
    now = await NTP.now();
    getData();
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
        title: CustomText(text: 'Past Lessons',color: Colors.white,),

      ),
      body: Padding(
        padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
        child: data!=null?
        data.isNotEmpty?AnimationLimiter(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context,i){
              print(now);
              int adminCount = data[i]['adminCount'];
              List countList = data[i]['pastCount'];
              List pastList = data[i]['past'];
              String id = data[i]['videoId'];
              String title = data[i]['name'];
              String image = data[i]['image'];
              String description = data[i]['description'];
              int index = pastList.indexOf(widget.phone);
              DateTime expired = DateTime.parse(data[i]['pastExpired'][index]);
              String formattedExpiredDate = DateFormat('yyyy/MM/dd @ hh:mm a').format(expired);
              String status;
              if(countList[index]>=adminCount){
                status = 'out-of-views';
              }
              else if(expired.isBefore(now)){
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
                        onTap: (){
                          if(status=='out-of-views'){
                            ToastBar(text: 'You have reached maximum attempts to watch the lesson!',color: Colors.red).show();
                          }
                          else if(status=='session-expired'){
                            ToastBar(text: 'Session Expired!',color: Colors.red).show();
                          }
                          else{
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    content: CustomText(text: 'Are you sure you want to watch this lesson?',color: Colors.black,),
                                    actions: [
                                      FlatButton(onPressed: () async {
                                        countList[index] = countList[index]+1;
                                        await FirebaseFirestore.instance.collection('lessons').doc(data[i].id).update({
                                          'pastCount' : countList
                                        });
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
