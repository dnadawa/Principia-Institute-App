import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:principia/screens/homepage.dart';
import 'package:principia/screens/register.dart';
import 'package:principia/widgets/custom-text.dart';

class HomeStructure extends StatefulWidget {
  final String phone;

  const HomeStructure({Key key, this.phone}) : super(key: key);
  @override
  _HomeStructureState createState() => _HomeStructureState();
}

class _HomeStructureState extends State<HomeStructure> with SingleTickerProviderStateMixin {
  List<DocumentSnapshot> devices;
  StreamSubscription<QuerySnapshot> subscription;
  TabController tabController;
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

  checkLoggedDevice() async {
    await getDeviceID();
    subscription = FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: widget.phone).snapshots().listen((datasnapshot){
      setState(() {
        devices = datasnapshot.docs;
      });
      if(devices[0]['deviceId']!=deviceID){
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => Register()),
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoggedDevice();
    tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Theme.of(context).scaffoldBackgroundColor,
        animationDuration: Duration(milliseconds: 400),
        height: 60,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.compare_arrows, size: 30),
        ],
        onTap: (index) {
          tabController.animateTo(index);
          },
      ),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
        HomePage(),
        HomePage(),
        HomePage(),
        ],
      ),
    );
  }
}
