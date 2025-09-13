import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

import '../../../configs/image_picker.dart';

class ChatImagePreview extends StatefulWidget {
  final PlatformFile image;
  final String customerId;
  const ChatImagePreview(
      {super.key, required this.image, required this.customerId});

  @override
  State<ChatImagePreview> createState() => _ChatImagePreviewState();
}

class _ChatImagePreviewState extends State<ChatImagePreview> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kBlackColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    // width: size.width,
                    // fit: BoxFit.cover,
                    File(widget.image.path!),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30.0,
                      color: kBackgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: kNewMainColor,
            onPressed: () async {
              try{
                setState(() {
                  isLoading = true;
                });
                final uploadedImage = await uploadFile(
                  file: widget.image,
                  fileName: widget.image.name,
                  folder: 'messageImages/${widget.customerId}',
                );
                await FirebaseFirestore.instance
                    .collection('messages')
                    .doc(widget.customerId)
                    .collection('messages')
                    .add({
                  'message': '',
                  'imageLink': uploadedImage['url'],
                  'imageKey': uploadedImage['key'],
                  'isImage': true,
                  'sender': widget.customerId,
                  'date': Timestamp.now(),
                  'isFromCustomer': true,
                  'isInitialMessage': false,
                }).then((value){
                  Navigator.pop(context);
                });
              } catch (e){
                setState(() {
                  isLoading = false;
                });
                debugPrint(e.toString());
                showToast(e.toString());
              }
            },
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            child: const Icon(
              Icons.send,
              size: 30.0,
              color: kBackgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
