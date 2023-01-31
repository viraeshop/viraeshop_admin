import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/notification_ticker.dart';
import 'package:viraeshop_admin/screens/messages_screen/messages.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

class UsersMessagesScreen extends StatefulWidget {
  static final String path = '/messages';
  UsersMessagesScreen();

  @override
  _UsersMessagesScreenState createState() => _UsersMessagesScreenState();
}

class _UsersMessagesScreenState extends State<UsersMessagesScreen> {
  GeneralCrud _generalCrud = GeneralCrud();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(FontAwesomeIcons.chevronLeft),
          iconSize: 20.0,
          color: kSubMainColor,
        ),
        title: const Text(
          'Chat Screen',
          style: kTextStyle1,
        ),
        centerTitle: false,
      ),
      body: Container(
        color: kBackgroundColor,
        child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('messages').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                );
              } else if (snapshot.hasError) {
                print('error: ${snapshot.error}');
                return const Center(
                  child: Text(
                    'No messages',
                    style: kProductNameStyle,
                  ),
                );
              } else {
                final data = snapshot.data!.docs;
                List chatsList = [];
                for (var element in data) {
                  chatsList.add(element.data());
                }
                return ListView.builder(
                  itemCount: chatsList.length,
                  itemBuilder: (context, i) {
                    num totalMessage = chatsList[i]['totalUnread'];
                    String name = chatsList[i]['name'];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Message(
                              name: chatsList[i]['name'],
                              userId: chatsList[i]['userId'],
                              totalUnreadMessages: totalMessage,
                              customerToken: chatsList[i]['customerToken'],
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: kSubMainColor,
                        child: Text(
                          name.characters.first,
                          style: kDrawerTextStyle2,
                        ),
                      ),
                      trailing: Column(
                        children: [
                          totalMessage != 0
                              ? NotificationTicker(
                                  value: totalMessage.toString())
                              : const SizedBox(),
                          const Icon(Icons.arrow_right),
                        ],
                      ),
                      title: Text(
                        '${chatsList[i]['name']}',
                        style: kProductNameStylePro,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${chatsList[i]['userId']}',
                            style: kProductNameStylePro,
                          ),
                          const Text(
                            'Tap to send message',
                            style: kProductNameStylePro,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }),
      ),
    );
  }
}
