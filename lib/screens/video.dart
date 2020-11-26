import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vimeoplayer/vimeoplayer.dart';

class VideoScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String description;
  final String id;
  final String phone;
  final String name;

  const VideoScreen({Key key, this.videoId, this.title, this.description, this.id, this.phone, this.name}) : super(key: key);
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List dataList;
  GlobalKey conSize = GlobalKey();
  OverlayEntry entry;
  getResources() async {
    var sub = await FirebaseFirestore.instance.collection('lessons').doc(widget.id).collection('files').get();
    setState(() {
      dataList = sub.docs;
    });
  }

  showOverlay(BuildContext context){
    double appBarHeight = MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
    double height = appBarHeight;
    final RenderBox renderBoxRed = conSize.currentContext.findRenderObject();
    double videoHeight = renderBoxRed.size.height + appBarHeight - 25;
    OverlayState overlayState = Overlay.of(context);
    entry = OverlayEntry(
        builder: (context){
          return AnimatedPositioned(
            duration: Duration(seconds: 10),
            top: height,
            left: MediaQuery.of(context).size.width/4,
            child: Material(
                type: MaterialType.transparency,
                child: Text('${widget.phone}\n${widget.name}',style: TextStyle(color: Colors.white54,fontSize: 10),)),
          );
        }
    );
    overlayState.insert(entry);
    //Timer(Duration(milliseconds: 100),()=>overlayState.setState(() {height=videoHeight -25;}));s
    Timer.periodic(Duration(seconds: 11), (timer) {
      overlayState.setState(() {
          videoHeight = renderBoxRed.size.height + appBarHeight - 25;
          appBarHeight = MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
          height==videoHeight?height=appBarHeight:height=videoHeight;
        });
      // else{
      //   overlayState.setState(() {
      //     width = MediaQuery.of(context).size.width/4;
      //     videoHeight = renderBoxRed.size.height + appBarHeight - 25;
      //     appBarHeight = MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
      //     height==videoHeight?height=appBarHeight:height=videoHeight;
      //   });
      // }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResources();
    Timer(Duration(seconds: 7), (){showOverlay(context);});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xff52575D),
        title: CustomText(text: widget.title,color: Colors.white,),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          entry.remove();
          Navigator.pop(context);
        }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VimeoPlayer(id: widget.videoId, looping: false,autoPlay: false,key: conSize,),
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setHeight(30)),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                color: Color(0xffF89D13),
                child: Column(
                  children: [
                    Padding(
                      padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                      child: CustomText(
                        text: widget.title,
                        size: ScreenUtil().setSp(45),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                          color: Colors.white
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(ScreenUtil().setHeight(30)),
                          child: CustomText(text: widget.description,align: TextAlign.start,),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setHeight(30)),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                color: Color(0xffF89D13),
                child: Column(
                  children: [
                    Padding(
                      padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                      child: CustomText(
                        text: 'Attachments',
                        size: ScreenUtil().setSp(45),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                          color: Colors.white
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                        child: dataList!=null?
                        dataList.isNotEmpty?
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: dataList.length,
                          itemBuilder: (context,i){
                            String name = dataList[i]['name'];
                            String url = dataList[i]['url'];
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              elevation: 5,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage('images/tute.png'),
                                ),
                                title: CustomText(text: name,),
                                trailing: IconButton(icon: Icon(Icons.download_rounded,color: Colors.black,), onPressed: () async {
                                  if (await canLaunch(url)) {
                                  await launch(url);
                                  } else {
                                  throw 'Could not launch $url';
                                  }
                                }),
                              ),
                            );
                          },
                        ):Center(child: CustomText(text: 'No attachments available!',))
                            :Center(child: CircularProgressIndicator(),),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
