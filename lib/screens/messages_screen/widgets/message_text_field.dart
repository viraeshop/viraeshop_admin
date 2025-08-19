import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

import '../../../configs/image_picker.dart';
import '../../../reusable_widgets/image/image_picker_service.dart';
import 'chat_image_preview.dart';

class MessageTextField extends StatelessWidget {
  const MessageTextField({
    super.key,
    required this.textController,
    required this.customerId,
    this.hintText = 'Type message here..',
    this.onSend,
  });
  final TextEditingController textController;
  final String hintText;
  final String customerId;
  final void Function()? onSend;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        children: [
          InkWell(
            child: const Icon(
              Icons.camera_alt,
              color: kNewMainColor,
              size: 24,
            ),
            onTap: () {
              ImagePickerService imagePickerService = ImagePickerService();
              imagePickerService.pickImage(context).then((image) {
                if(image != null){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ChatImagePreview(
                          image: image,
                          customerId: customerId,
                        );
                      },
                    ),
                  );
                }
              });
            },
          ),
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: kBackgroundColor,
              ),
              child: TextField(
                controller: textController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintMaxLines: 1,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10,
                  ),
                  hintStyle: const TextStyle(fontSize: 16),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 0.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.black26,
                      width: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: InkWell(
              onTap: onSend,
              child: const Icon(
                Icons.send,
                color: kNewMainColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
