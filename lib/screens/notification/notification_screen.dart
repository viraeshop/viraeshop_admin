import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop/notifications/notifications_bloc.dart';
import 'package:viraeshop/notifications/notifications_event.dart';
import 'package:viraeshop/notifications/notifications_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/clipper.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/shops_model.dart';
import 'package:viraeshop_admin/screens/supplier/shops.dart';
import 'package:viraeshop_api/apiCalls/notifications.dart';

import '../../components/styles/text_styles.dart';
import '../advert/ads_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationScreen extends StatefulWidget {
  static const String path = '/notifications';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with AutomaticKeepAliveClientMixin {
  List items = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    final notificationBloc = BlocProvider.of<NotificationsBloc>(context);
    notificationBloc.add(GetNotificationsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: kNewMainColor,
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kNewMainColor,
            elevation: null,
            // shape: RoundedRectangleBorder(),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(FontAwesomeIcons.chevronLeft),
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
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 3),
                          color: Colors.black26,
                          blurRadius: 3.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10.0),
                      color: kBackgroundColor,
                    ),
                    child: BlocConsumer<NotificationsBloc, NotificationsState>(
                        listener: (context, state) {
                          if (state is AddedNotificationState) {
                            setState(() {
                              isLoading = false;
                              items.add(state.response.result);
                            });
                          } else if (state is OnAddedErrorNotificationState) {
                            snackBar(
                              text: state.message,
                              context: context,
                              duration: 500,
                              color: kRedColor,
                            );
                          }
                        },
                    // }, buildWhen: (context, state) {
                    //   if (state is FetchedNotificationsState ||
                    //       state is OnErrorNotificationState) {
                    //     return true;
                    //   } else {
                    //     return false;
                    //   }
                    // },
                    builder: (context, state) {
                      if (state is OnErrorNotificationState) {
                        return Text(
                          state.message,
                          style: const TextStyle(
                            color: kRedColor,
                            fontFamily: 'Montserrat',
                            fontSize: 15.0,
                            letterSpacing: 1.3,
                          ),
                        );
                      } else if (state is LoadingNotificationState) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: kNewMainColor,
                          ),
                        );
                      } else {
                        if (state is FetchedNotificationsState) {
                          items.clear();
                          final data = state.notifications;
                          if (data.isNotEmpty) {
                            for (var element in data) {
                              items.add(element.toJson());
                            }
                          }
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
                    }),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: 0.2,
                  alignment: Alignment.bottomCenter,
                  child: NotificationMaker(
                    onSend: (){
                      setState(() {
                        isLoading = true;
                      });
                    },
                  ),
                ),
              ],
            ),
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
  const NotificationMaker({Key? key, required this.onSend}) : super(key: key);
  final void Function() onSend;
  @override
  State<NotificationMaker> createState() => _NotificationMakerState();
}

class _NotificationMakerState extends State<NotificationMaker> {
  TextEditingController titleController = TextEditingController();

  TextEditingController subTitleController = TextEditingController();

  TextEditingController bodyController = TextEditingController();

  Uint8List imageBytes = Uint8List(0);

  String imagePath = '';

  Map<String, dynamic> imageLinkData = {};
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is AddedNotificationState) {
          setState(() {
            titleController.clear();
            subTitleController.clear();
            bodyController.clear();
            imageBytes = Uint8List(0);
            imageLinkData.clear();
          });
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
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
                        padding: const EdgeInsets.all(10.0),
                        width: size.width * 0.43,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextStyle(
                              hintText: 'Title',
                              width: size.width * 0.4,
                              title1Controller: titleController,
                              textStyle: const TextStyle(
                                color: kSubMainColor,
                                fontSize: 15.0,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(),
                            CustomTextStyle(
                              height: 40,
                              width: size.width * 0.4,
                              hintText: 'Sub-title',
                              title1Controller: subTitleController,
                              textStyle: const TextStyle(
                                color: kSubMainColor,
                                fontSize: 15.0,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(),
                            CustomTextStyle(
                              lines: 3,
                              width: size.width * 0.4,
                              height: 70.0,
                              hintText: 'Description',
                              title1Controller: bodyController,
                              textStyle: const TextStyle(
                                color: kSubMainColor,
                                fontSize: 15.0,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            //SizedBox(),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      InkWell(
                        onTap: () {
                          if (kIsWeb) {
                            // getImageWeb('notifications').then((value) {
                            //   setState(() {
                            //     imageBytes = value.item1!;
                            //     imageLink = value.item2!;
                            //   });
                            // });
                          } else {
                            getImageNative('notifications').then((value) {
                              setState(() {
                                imagePath = value['path'];
                                imageLinkData = value['imageData'];
                              });
                            });
                          }
                        },
                        child: Container(
                          width: size.width * 0.2,
                          height: 120.0,
                          margin: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: kNewYellowColor,
                            image: imageBG(imageBytes, imagePath),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: imageBytes.isEmpty
                                ? const Icon(
                                    Icons.add_a_photo,
                                    size: 30.0,
                                    color: kBackgroundColor,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: sendButton(
                      color: kNewMainColor,
                      width: 70.0,
                      title: 'Send',
                      onTap: () {
                        if (titleController.text.isNotEmpty &&
                            subTitleController.text.isNotEmpty &&
                            bodyController.text.isNotEmpty) {
                          final notificationBloc =
                              BlocProvider.of<NotificationsBloc>(context);
                          final notification = {
                            'title': titleController.text,
                            'subTitle': subTitleController.text,
                            'body': bodyController.text,
                            'image': imageLinkData['url'],
                            'imageKey': imageLinkData['key'],
                          };
                          notificationBloc.add(
                            AddNotificationEvent(
                                token: jWTToken,
                                notificationModel: notification),
                          );
                          widget.onSend();
                        }
                      }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard(
      {required this.title,
      required this.body,
      required this.image,
      required this.subTitle,
      Key? key})
      : super(key: key);
  final String title;
  final String subTitle;
  final String body;
  final String image;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      //height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: kTextBoxColor,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            width: size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kSubMainColor,
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subTitle,
                  style: kProductNameStylePro,
                ),
                Text(
                  body,
                  style: const TextStyle(
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
          const SizedBox(
            width: 10.0,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: image,
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
