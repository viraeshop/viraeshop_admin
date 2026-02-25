import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/image/image_picker_service.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/chat_image_preview.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/guest_chat_bubble.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/image_bubble.dart';
import 'package:viraeshop_admin/screens/messages_screen/widgets/me_chat_bubble.dart';
import 'package:viraeshop_admin/services/admin_chat_service.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:viraeshop_api/viraeshop_api.dart';

import '../../configs/image_picker.dart';

class Message extends StatefulWidget {
  final String name;
  final String chatId;
  const Message({
    super.key,
    required this.name,
    required this.chatId,
  });

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final AdminChatService _chatService = AdminChatService();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  Map adminInfo = Hive.box('adminInfo').toMap();
  final String placeholderImage =
      'https://www.clipartmax.com/png/small/150-1509532_say-hi-to-us-avatar-support.png';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _setupSocketListener();
  }

  Future<void> _loadHistory() async {
    final history = await _chatService.fetchChatHistory(widget.chatId);
    if (mounted) {
      setState(() {
        // Reverse because UI builds from bottom
        _messages = history.reversed.toList();
        _isLoading = false;
      });
    }
  }

  void _setupSocketListener() {
    _chatService.socket.on("receive_message", (data) {
      if (mounted && data != null) {
        final newMessage = MessageModel.fromJson(data);
        if (newMessage.chatId == widget.chatId) {
          setState(() {
            _messages.insert(0, newMessage);
          });
        }
      }
    });
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
      body: SafeArea(
        child: Container(
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
                  child: _isLoading
                      ? Center(
                          child: LoadingAnimationWidget.bouncingBall(
                            color: kNewMainColor,
                            size: 40,
                          ),
                        )
                      : (_messages.isEmpty
                          ? const Center(
                              child: Text(
                                'No messages yet',
                                style: kProductNameStylePro,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _messages.length,
                              reverse: true,
                              itemBuilder: (context, i) {
                                final msg = _messages[i];
                                DateTime msgTime =
                                    msg.createdAt ?? DateTime.now();
                                String time = GetTimeAgo.parse(msgTime);
                                bool isAdmin = msg.senderType == 'admin';
                                bool isImage = msg.type == 'image';

                                if (isAdmin) {
                                  if (isImage) {
                                    return ChatImageWidget(
                                      profileImage: adminInfo['profileImage'] ??
                                          placeholderImage,
                                      isGuest: false,
                                      url: msg.content ?? '',
                                      time: time,
                                    );
                                  } else {
                                    return MeChatBubble(
                                      profileImage: adminInfo['profileImage'] ??
                                          placeholderImage,
                                      message: msg.content ?? '',
                                      time: time,
                                    );
                                  }
                                } else {
                                  if (isImage) {
                                    return ChatImageWidget(
                                      isGuest: true,
                                      url: msg.content ?? '',
                                      time: time,
                                      profileImage: placeholderImage,
                                    );
                                  } else {
                                    return GuestMessage(
                                      profileImage: placeholderImage,
                                      message: msg.content ?? '',
                                      time: time,
                                      customerName: widget.name,
                                    );
                                  }
                                }
                              },
                            )),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: MessageBar(
                  sendButtonColor: kNewMainColor,
                  onTextChanged: (_) {},
                  onSend: (_) async {
                    String messageText = _;
                    final newMessage = MessageModel(
                      id: "",
                      chatId: widget.chatId,
                      senderType: 'admin',
                      senderId: adminInfo['adminId']?.toString() ?? 'admin',
                      content: messageText,
                      type: 'text',
                    );
                    _chatService.sendMessage(newMessage);
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
                          ImagePickerService imagePickerService =
                              ImagePickerService();
                          imagePickerService.pickImage(context).then((image) {
                            if (image != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ChatImagePreview(
                                      image: image,
                                      customerId: widget.chatId,
                                    );
                                  },
                                ),
                              );
                            }
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}
