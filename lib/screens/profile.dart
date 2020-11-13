import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:principia/screens/register.dart';
import 'package:principia/widgets/button.dart';
import 'package:principia/widgets/custom-text.dart';
import 'package:principia/widgets/labled-inputfield.dart';
import 'package:principia/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final String phone;
  final List subjects;
  final String stream;
  const Profile({Key key, this.phone, this.subjects, this.stream}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String stream;
  String institute;
  double _opacity;
  List<DropdownMenuItem<String>> streamList = [];
  List<MultiSelectItem> subjectsList = [];
  List subs = [];

  TextEditingController name = TextEditingController();
  TextEditingController year = TextEditingController();

  List<DocumentSnapshot> devices;
  StreamSubscription<QuerySnapshot> subscription;

  getStreams() async {
    var sub = await FirebaseFirestore.instance.collection('streams').get();
    List streams = sub.docs;
    if(streams.isNotEmpty){
      stream = widget.stream;
      for(int i=0;i<streams.length;i++){
        setState(() {
          streamList.add(
            DropdownMenuItem(child: CustomText(text:streams[i]['name'],color: Theme.of(context).primaryColor,),value: streams[i]['name'],),
          );
        });
      }
      getSubjects(stream);
    }
  }

  getSubjects(String name) async {
    subjectsList.clear();
    subs.clear();
    var sub = await FirebaseFirestore.instance.collection('streams').where('name', isEqualTo: name).get();
    var subjects = sub.docs;
    for(int i=0;i<subjects[0]['subjects'].length;i++){
      setState(() {
        subjectsList.add(
            MultiSelectItem(subjects[0]['subjects'][i],subjects[0]['subjects'][i])
        );
      });
    }
  }
  List subjects;

  getData() async {
    subscription = FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: widget.phone).snapshots().listen((datasnapshot){
      setState(() {
        devices = datasnapshot.docs;
        name.text = devices[0]['name'];
        year.text = devices[0]['year'];
        institute = devices[0]['institute'];
        stream = devices[0]['stream'];
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    institute = 'Principia - Galle';
    subjects = widget.subjects;
    _opacity = 1;
    getStreams();
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
        title: CustomText(text: 'Profile',color: Colors.white,),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.all(ScreenUtil().setHeight(30)),
          child: Column(
            children: [
              SizedBox(
                  width: ScreenUtil().setHeight(250),
                  height: ScreenUtil().setHeight(250),
                  child: Image.asset('images/profile.jpg')
              ),
              SizedBox(height: ScreenUtil().setHeight(20)),
              LabeledInputField(hint: 'Name',controller: name,),
              // SizedBox(height: ScreenUtil().setHeight(20)),
              // Center(
              //   child: Container(
              //     width: double.infinity,
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(10),
              //         border: Border.all(color: Theme.of(context).scaffoldBackgroundColor,width: 3)
              //     ),
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
              //       child: DropdownButton(
              //         underline: Divider(color: Colors.white,height: 0,thickness: 0,),
              //         iconEnabledColor: Theme.of(context).primaryColor,
              //         isExpanded: true,
              //         items: streamList,
              //         onChanged:(newValue){
              //           setState(() {
              //             subjects.clear();
              //             _opacity = 0;
              //             stream = newValue;
              //             getSubjects(stream);
              //             Timer(Duration(milliseconds: 400), (){_opacity = 1;setState(() {});});
              //           });
              //         },
              //         value: stream,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: ScreenUtil().setHeight(20)),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                opacity: _opacity,
                child: MultiSelectChipField(
                  initialValue: subjects,
                  title: Text('Subjects',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                  headerColor: Theme.of(context).scaffoldBackgroundColor,
                  chipShape: Border.all(color: Theme.of(context).scaffoldBackgroundColor),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor,width: 2),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))
                  ),
                  selectedChipColor: Theme.of(context).primaryColor,
                  selectedTextStyle: TextStyle(color: Colors.white),
                  items: subjectsList,
                  icon: Icon(Icons.check,color: Colors.white,),
                  onTap: (l){
                    subs = l;
                    print(subs);
                  },
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(20)),
              LabeledInputField(hint: 'A/L Year',type: TextInputType.number,controller: year,),
              SizedBox(height: ScreenUtil().setHeight(20)),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor,width: 3)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                    child: DropdownButton(
                      underline: Divider(color: Colors.white,height: 0,thickness: 0,),
                      iconEnabledColor: Theme.of(context).primaryColor,
                      isExpanded: true,
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(child: CustomText(text: 'Principia - Galle',color: Theme.of(context).primaryColor,),value: 'Principia - Galle',),
                        DropdownMenuItem(child: CustomText(text: 'Pubudu - Ambalangoda',color: Theme.of(context).primaryColor,),value: 'Pubudu - Ambalangoda',),
                        DropdownMenuItem(child: CustomText(text: 'Sakya - Matara',color: Theme.of(context).primaryColor,),value: 'Sakya - Matara',),
                      ],
                      onChanged:(newValue){
                        setState(() {
                          institute = newValue;
                        });
                      },
                      value: institute,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(100)),
              Button(text: 'Update',onclick: () async {
                try{
                  await FirebaseFirestore.instance.collection('users').doc(widget.phone).update({
                    'name': name.text,
                    'stream': stream,
                    'subjects': subs,
                    'year': year.text,
                    'institute': institute
                  });
                  ToastBar(text: 'Data Updated!',color: Colors.green).show();
                }
                catch(e){
                  ToastBar(text: 'Something went wrong!',color: Colors.red).show();
                }
              },),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Button(text: 'Log Out',color: Colors.red,onclick: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('phone', null);
                Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(builder: (context) => Register()), (Route<dynamic> route) => false);
              },),
              SizedBox(height: ScreenUtil().setHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}
