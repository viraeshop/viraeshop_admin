import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/chat_image_preview.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/guest_chat_bubble.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/image_bubble.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/me_chat_bubble.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:viraeshop_api/apiCalls/messages.dart';

import '../../configs/image_picker.dart';

class Message extends StatefulWidget {
  final String name;
  final String userId;
  final num totalUnreadMessages;
  final String customerToken;
  const Message({super.key, 
    required this.name,
    required this.userId,
    required this.totalUnreadMessages,
    required this.customerToken,
  });

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final GeneralCrud _generalCrud = GeneralCrud();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  late User userAuthInfo;
  Map adminInfo = Hive.box('adminInfo').toMap();
  final String placeholderImage =
      'https://www.clipartmax.com/png/small/150-1509532_say-hi-to-us-avatar-support.png';
  @override
  void initState() {
    // TODO: implement initState
    updateRead(widget.userId, widget.totalUnreadMessages);
    userAuthInfo = _auth.currentUser!;
    super.initState();
  }

  final TextEditingController messageController = TextEditingController();
  String message = '';
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(
          widget.name ?? '',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
        actions: const [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: kBackgroundColor,
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              heightFactor: 0.9,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _generalCrud.getChatMessages(widget.userId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      if (kDebugMode) {
                        print(snapshot.error);
                      }
                      return const Center(
                        child: Text(
                          'Failed to Fetch messages',
                          style: kBigErrorTextStyle,
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.active) {
                      final messages = snapshot.data?.docs ?? [];
                      if (messages.isNotEmpty) {
                        return ListView.builder(
                          itemCount: messages.length,
                          //shrinkWrap: true,
                          reverse: true,
                          itemBuilder: (context, i) {
                            Timestamp timestamp = messages[i].get('date');
                            String time = GetTimeAgo.parse(timestamp.toDate());
                            Map<String, dynamic> data =
                                messages[i].data() as Map<String, dynamic>;
                            bool isImage = data['isImage'] ?? false;
                            if (messages[i].get('sender') == userAuthInfo.uid) {
                              if (isImage) {
                                return ChatImageWidget(
                                  profileImage: adminInfo['profileImage'] ??
                                      placeholderImage,
                                  isGuest: false,
                                  url: data['imageLink'],
                                  time: time,
                                );
                              } else {
                                return MeChatBubble(
                                  profileImage: adminInfo['profileImage'] ??
                                      placeholderImage,
                                  message: messages[i].get('message') ?? '',
                                  time: time,
                                );
                              }
                            } else {
                              if (isImage) {
                                return ChatImageWidget(
                                  isGuest: true,
                                  url: data['imageLink'],
                                  time: time,
                                  profileImage:
                                      data['profileImage'] ?? placeholderImage,
                                );
                              } else {
                                return GuestMessage(
                                  profileImage:
                                      data['profileImage'] ?? placeholderImage,
                                  message: messages[i].get('message'),
                                  time: time,
                                  customerName: widget.name,
                                );
                              }
                            }
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'No messages yet',
                            style: kProductNameStylePro,
                          ),
                        );
                      }
                    } else {
                      return Center(
                        child: LoadingAnimationWidget.bouncingBall(
                          color: kNewMainColor,
                          size: 40,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: MessageBar(
                sendButtonColor: kNewMainColor,
                onTextChanged: null,
                onSend: (_) async {
                  String message = _;
                  await FirebaseFirestore.instance
                      .collection('messages')
                      .doc(widget.userId)
                      .collection('messages')
                      .add({
                    'message': message,
                    'sender': userAuthInfo.uid,
                    'date': Timestamp.now(),
                    'isFromCustomer': false,
                    'isInitialMessage': false,
                    'tokens': widget.customerToken,
                    'adminName': adminInfo['name'],
                    'profileImage':
                        adminInfo['profileImage'] ?? placeholderImage,
                  });
                  try {
                    await MessageCalls().sendNotificationFromCustomer({
                      'message': message,
                    });
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: InkWell(
                      child: const Icon(
                        Icons.camera_alt,
                        color: kNewMainColor,
                        size: 24,
                      ),
                      onTap: () {
                        pickFile().then((image) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatImagePreview(
                                  image: image!,
                                  customerId: widget.userId,
                                );
                              },
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

Future<void> updateRead(String docId, num readMessages) async {
  await FirebaseFirestore.instance
      .collection('messages')
      .doc(docId)
      .update({'totalUnreadMessages': 0});
  DocumentReference documentReference =
      FirebaseFirestore.instance.collection('notifications').doc('newMessages');
  return FirebaseFirestore.instance.runTransaction((transaction) async {
    // Get the document
    DocumentSnapshot snapshot = await transaction.get(documentReference);

    if (!snapshot.exists) {
      throw Exception("not found!");
    }
    var data = snapshot.get('totalMessages');
    var newTotal = data - readMessages;
    // Perform an update on the document
    transaction.update(documentReference, {'totalMessages': newTotal});
    // Return the new count
    return newTotal;
  });
}
