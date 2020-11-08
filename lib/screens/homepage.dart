import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/marquee.dart';

class HomePage extends StatelessWidget {

  String name = "Chathura Abeysirigunawardhana";


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    List a = name.split(' ');
    Widget myCard = Padding(
      padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
              child: SizedBox(
                  height: ScreenUtil().setHeight(280),
                  width: ScreenUtil().setHeight(280),
                  child: Image.asset('images/maths.png')),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  border: Border.all(color: Colors.white,width: 3)
                ),
                child: Center(
                  child: Padding(
                    padding:  EdgeInsets.all(ScreenUtil().setHeight(20)),
                    child: CustomText(text: 'Applied Maths',color: Colors.white,size: ScreenUtil().setSp(50),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Home',color: Colors.white,),
      ),
      body: Padding(
        padding:  EdgeInsets.all(ScreenUtil().setWidth(35)),
        child: Column(
          children: [
            Container(
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
                            text: 'Chathura',
                            size: ScreenUtil().setSp(50),
                            align: TextAlign.start,
                          ),
                        ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(480),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: MarqueeWidget(
                          child: CustomText(
                            text: 'Abeysirigunawardhana',
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              elevation: 7,
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

            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 0.7,
                enlargeCenterPage: true,
                pauseAutoPlayOnTouch: true,
                aspectRatio: 192/225,
                initialPage: 2,
                height: ScreenUtil().setHeight(500)
              ),
              items: [
                myCard,
                myCard,
                myCard
              ],
            ),
          ],
        ),
      ),
    );

  }
}
