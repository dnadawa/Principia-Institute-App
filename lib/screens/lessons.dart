import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/marquee.dart';

class Lessons extends StatefulWidget {
  final String subject;

  const Lessons({Key key, this.subject}) : super(key: key);

  @override
  _LessonsState createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: widget.subject,color: Colors.white,),
      ),
      body: Padding(
        padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
              Card(
                elevation: 6,
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
                          child: SizedBox(
                              //height: ScreenUtil().setHeight(250),
                              child: Image.asset('images/maths.png')),
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
                                child: Center(child: CustomText(text: 'Trigonometry',color: Colors.white,size: ScreenUtil().setSp(35),)),
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
                                child: MarqueeWidget(child: CustomText(text: 'Ends in 2020/11/16 @ 8.30 a.m',color: Colors.red,size: ScreenUtil().setSp(25))),
                              ),
                            ),
                          ],
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
