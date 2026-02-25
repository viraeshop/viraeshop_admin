import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/notification_ticker.dart';
import 'package:viraeshop_admin/screens/messages_screen/messages.dart';
import 'package:viraeshop_admin/services/admin_chat_service.dart';
import 'package:viraeshop_api/viraeshop_api.dart';

class UsersMessagesScreen extends StatefulWidget {
  static const String path = '/messages';
  const UsersMessagesScreen({super.key});

  @override
  _UsersMessagesScreenState createState() => _UsersMessagesScreenState();
}

class _UsersMessagesScreenState extends State<UsersMessagesScreen> {
  final AdminChatService _chatService = AdminChatService();
  late Future<List<ChatModel>> _chatListFuture;

  @override
  void initState() {
    super.initState();
    _refreshChats();
    // Re-fetch the list when global message pushes in (simplest approach for immediate UI updates)
    _chatService.onGlobalMessageReceived = (message) {
      if (mounted) {
        _refreshChats();
      }
    };
  }

  void _refreshChats() {
    setState(() {
      _chatListFuture = _chatService.fetchAllChats();
    });
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
      body: SafeArea(
        child: Container(
          color: kBackgroundColor,
          child: FutureBuilder<List<ChatModel>>(
              future: _chatListFuture,
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
                  final chatsList = snapshot.data ?? [];
                  if (chatsList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages found',
                        style: kProductNameStylePro,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatsList.length,
                    itemBuilder: (context, i) {
                      final chat = chatsList[i];
                      final customer = chat.customer;
                      final String name = customer != null
                          ? "\${customer['firstName']} \${customer['lastName']}"
                          : 'Unknown Customer';

                      // Using a dummy ticker, or extract unread count from chat if added
                      num totalMessage = 0;

                      return ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Message(
                                name: name,
                                chatId: chat.id, // Pass the chat UUID
                              ),
                            ),
                          );
                          _refreshChats(); // Refresh unread state upon returning
                        },
                        leading: CircleAvatar(
                          backgroundColor: kSubMainColor,
                          child: Text(
                            name.characters.isNotEmpty
                                ? name.characters.first
                                : '?',
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
                          name,
                          style: kProductNameStylePro,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat.messages != null && chat.messages!.isNotEmpty
                                  ? chat.messages!.first.content ??
                                      'Sent an attachment'
                                  : 'Tap to send message',
                              style: kProductNameStylePro,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              }),
        ),
      ),
    );
  }
}
