import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:principia/screens/announcements.dart';
import 'package:principia/screens/homepage.dart';
import 'package:principia/screens/profile.dart';
import 'package:principia/screens/register.dart';
import 'package:principia/screens/update.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  String name;
  String stream;
  List subjects;
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
  List splittedNames = ['Loading', 'Loading'];
  checkLoggedDevice() async {
    await getDeviceID();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    subscription = FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: widget.phone).snapshots().listen((datasnapshot){
      setState(() {
        devices = datasnapshot.docs;
        name = devices[0]['name'];
        stream = devices[0]['stream'];
        subjects = devices[0]['subjects'];
        splittedNames = name.split(' ');
      });
      if(devices[0]['deviceId']!=deviceID){
        prefs.setString('phone', null);
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => Register()), (Route<dynamic> route) => false);
      }
    });
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    String version = packageInfo.version;
    var sub = await FirebaseFirestore.instance.collection('info').where('key', isEqualTo: 'buildNumber').get();
    var info = sub.docs;
    await FirebaseFirestore.instance.collection('version').doc(widget.phone).set({
      'name': name,
      'phone': widget.phone,
      'version': version,
      'buildNumber': buildNumber
    });
    if(int.parse(buildNumber)<int.parse(info[0]['buildNumber'])){
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => UpdateScreen()), (Route<dynamic> route) => false);
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoggedDevice();
    tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
    getPackageInfo();
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
          Icon(Icons.home, size: 30,color: Colors.white,),
          Icon(Icons.chat, size: 30,color: Colors.white),
          Icon(Icons.person, size: 30,color: Colors.white),
        ],
        onTap: (index) {
          tabController.animateTo(index);
          },
      ),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
        subjects!=null?HomePage(name: splittedNames,stream: stream,subjects: subjects,phone: widget.phone,fullname: name,):Center(child: CircularProgressIndicator(),),
        Announcements(subjects: subjects),
        Profile(phone: widget.phone,subjects: subjects,stream: stream,),
        ],
      ),
    );
  }
}
