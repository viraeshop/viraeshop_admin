import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/clipper.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/shops_model.dart';
import 'package:viraeshop_admin/screens/shops.dart';

import '../../components/styles/text_styles.dart';
import '../advert/ads_card.dart';

class NotificationScreen extends StatefulWidget {
  static final String path = '/notifications';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kNewMainColor,
          elevation: null,
          // shape: RoundedRectangleBorder(),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(FontAwesomeIcons.chevronLeft),
            color: kBackgroundColor,
            iconSize: 20.0,
          ),
        ),
        body: Container(
          color: kBackgroundColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                height: size.height,
                width: size.width,
                color: kBackgroundColor,
                child: Stack(children: [
                  FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.7,
                    widthFactor: 1,
                    child: ClipPath(
                      clipper: MyClipper(),
                      child: Container(
                        color: kNewMainColor,
                      ),
                    ),
                  ),
                ]),
              ),
              FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 0.8,
                widthFactor: 0.9,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 3),
                        color: Colors.black26,
                        blurRadius: 3.0,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10.0),
                    color: kBackgroundColor,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('push_notifications').snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(
                          child: CircularProgressIndicator(color: kNewMainColor,),
                        );
                      }else if(snapshot.hasError){
                        print(snapshot.error);
                        return Text('${snapshot.error}', style: TextStyle(
                          color: kRedColor,
                          fontFamily: 'Montserrat',
                          fontSize: 15.0,
                          letterSpacing: 1.3,
                        ),);
                      }
                      else{
                        final data = snapshot.data!.docs;
                        List items = [];
                        if(data.isNotEmpty){
                          data.forEach((element) {
                          items.add(element.data());
                        });
                        }

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return NotificationCard(
                            image: items[index]['image'],
                            title: items[index]['title'],
                            subTitle: items[index]['subTitle'],
                            body: items[index]['body'],
                          );
                        },
                      );
                    }
                    }
                  ),
                ),
              ),
              FractionallySizedBox(
                heightFactor: 0.2,
                alignment: Alignment.bottomCenter,
                child: NotificationMaker(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class NotificationMaker extends StatefulWidget {
  NotificationMaker({Key? key}) : super(key: key);

  @override
  State<NotificationMaker> createState() => _NotificationMakerState();
}

class _NotificationMakerState extends State<NotificationMaker> {
  TextEditingController titleController = TextEditingController();

  TextEditingController subTitleController = TextEditingController();

  TextEditingController bodyController = TextEditingController();

  Uint8List imageBytes = Uint8List(0);

  String imageLink = '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                //height: 150.0,
                width: size.width * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: kTextBoxColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: size.width * 0.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextStyle(
                                  hintText: 'Title',
                                    title1Controller: titleController,
                                    textStyle: TextStyle(
                                      color: kSubMainColor,
                                      fontSize: 15.0,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  SizedBox(),
                                  CustomTextStyle(
                                  hintText: 'Sub-title',
                                    title1Controller: subTitleController,
                                    textStyle: TextStyle(
                                      color: kSubMainColor,
                                      fontSize: 15.0,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  SizedBox(),
                                  CustomTextStyle(
                                    lines: 3,
                                    width: size.width * 0.4,
                                    height: 70.0,
                                  hintText: 'Description',
                                    title1Controller: bodyController,
                                    textStyle: TextStyle(
                                      color: kSubMainColor,
                                      fontSize: 15.0,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  //SizedBox(),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    InkWell(
                      onTap: (){
                        getImageWeb().then((value){
                          setState(() {
                            imageBytes = value.item1!;
                            imageLink = value.item2!;
                          });
                        });
                      },
                      child: Container(
                        width: size.width * 0.2,
                        height: 120.0,
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: kNewYellowColor,
                          image: DecorationImage(
                            image: MemoryImage(imageBytes),
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: imageBytes.isEmpty ? Icon(Icons.add_a_photo, size: 30.0, color: kBackgroundColor,) : SizedBox(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: sendButton(
                  color: kNewMainColor,
                  width: 70.0,
                  title: 'Send',
                  onTap: (){
                    if(titleController.text != null && subTitleController.text != null && bodyController.text != null && imageLink.isNotEmpty){
                      FirebaseFirestore.instance.collection('push_notifications').add({
                    'title': titleController.text,
                    'subTitle': subTitleController.text,
                    'body': bodyController.text,
                    'image': imageLink,
                  }).then((value) {
                    titleController.clear();
                    subTitleController.clear();
                    bodyController.clear();
                    setState(() {
                      imageBytes.clear();
                      imageLink = '';
                    });
                  }).catchError((error){
                    print('push notifcation error: $error');
                    snackBar(text: '${error.message}', context: context, duration: 20);
                  });
                    }
                }),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {  
  NotificationCard({
    required this.title,
    required this.body,
    required this.image,
    required this.subTitle
  });
  final String title;
  final String subTitle;
  final String body;
  final String image;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      //height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: kTextBoxColor,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            width: size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title',
                  style: TextStyle(
                    color: kSubMainColor,
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$subTitle',
                  style: kProductNameStylePro,
                ),
                Text(
                  '$body',                  
                  style: TextStyle(
                    color: kSubMainColor,
                    fontFamily: 'SourceSans',
                    fontSize: 15,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10.0,
          ),          
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: '$image',
              height: 120.0,
              width: size.width * 0.2,
              fit: BoxFit.cover,
              errorWidget: (context, urls, widget) {
                return Image.asset(
                  'assets/default.jpg',
                  width: size.width * 0.2,
                  fit: BoxFit.cover,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
