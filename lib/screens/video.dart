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

  const VideoScreen({Key key, this.videoId, this.title, this.description, this.id}) : super(key: key);
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List dataList;

  getResources() async {
    var sub = await FirebaseFirestore.instance.collection('lessons').doc(widget.id).collection('files').get();
    setState(() {
      dataList = sub.docs;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResources();
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VimeoPlayer(id: widget.videoId, looping: false,autoPlay: false,),
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
