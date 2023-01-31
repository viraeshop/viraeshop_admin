import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/decoration.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:viraeshop_api/apiCalls/messages.dart';

class Message extends StatefulWidget {  
  final String name;
  final String userId;
  final num totalUnreadMessages;
  final String customerToken;
  Message({
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
  late User loggedIn;
  void getCurrentUser() {
    final user = _auth.currentUser!;
    try {
      loggedIn = user;
      debugPrint(loggedIn.email);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    updateRead(widget.userId, widget.totalUnreadMessages);
    getCurrentUser();
    super.initState();
  }

  final TextEditingController messageController = TextEditingController();
  String message = '';
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: _generalCrud.getChatMessages(widget.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Text(
                          'Fetching messages',
                          style: kProductNameStylePro,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Failed to Fetch messages',
                          style: kProductNameStylePro,
                        ),
                      );
                    } else {
                      final messages = snapshot.data!.docs;
                      return messages.isEmpty
                          ? const Center(
                              child: Text(
                                'No messages yet!',
                                style: kProductNameStylePro,
                              ),
                            )
                          : ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Container(
                                  // padding: EdgeInsets.all(0),
                                  child: messages[i].get('sender') ==
                                          loggedIn.email
                                      ? BubbleSpecialThree(
                                          text: messages[i].get('message'),
                                          color: kNewTextColor,
                                          tail: false,
                                          isSender: true,
                                          textStyle: const TextStyle(
                                            fontFamily: 'SourceSans',
                                            fontSize: 15.0,
                                            color: kBackgroundColor,
                                            // fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : BubbleSpecialThree(
                                          text: messages[i].get('message'),
                                          color: kProductCardColor,
                                          tail: false,
                                          isSender: false,
                                          textStyle: const TextStyle(
                                            fontFamily: 'SourceSans',
                                            fontSize: 15.0,
                                            color: kBackgroundColor,
                                            // fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                );
                              },
                              shrinkWrap: true,
                            );
                    }
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        border: Border.all(color: kSubMainColor),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: messageController,
                        style: kProductNameStylePro,
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        100.0,
                      ),
                      color: kNewTextColor,
                    ),
                    child: Center(
                      child: IconButton(
                          onPressed: () async{
                            String message = messageController.text;
                            messageController.clear();
                            FirebaseFirestore.instance
                              .collection('messages')
                              .doc(widget.userId)
                              .collection('messages')
                              .add({
                            'message': message,
                            'sender': loggedIn.email,
                            'date': Timestamp.now(),
                            'isFromCustomer': true,
                            'tokens': widget.customerToken,
                            'isInitialMessage': false,
                          });
                            try{
                              await MessageCalls().sendNotificationFromAdmin({
                                'tokenId': widget.customerToken,
                                'message': message,
                              }, jWTToken);
                            } catch(e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: kBackgroundColor,
                            size: 18.0,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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
