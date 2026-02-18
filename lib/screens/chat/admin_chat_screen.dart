import 'package:flutter/material.dart';
import 'package:viraeshop_admin/services/admin_chat_service.dart';
import 'package:viraeshop_api/viraeshop_api.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class AdminChatScreen extends StatefulWidget {
  final ChatModel chat;
  const AdminChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final AdminChatService _chatService = AdminChatService();
  final TextEditingController _controller = TextEditingController();
  final List<MessageModel> _messages = []; // Load history here
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatService.connect("ADMIN_TOKEN"); // Replace
    _chatService.joinChat(widget.chat.id);

    // Listen for messages (omitted for brevity, similar to customer app)
    // Fetch History (omitted for brevity)
  }

  Future<void> _handleDecision(String action) async {
    setState(() => _isLoading = true);
    final success = await _chatService.decideOffer(widget.chat.id, action);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Offer ${action}ed")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Action failed")));
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Negotiation: ${widget.chat.negotiatedPrice}")),
      body: Column(
        children: [
          // Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Offered Price: \$${widget.chat.negotiatedPrice}"),
                    Text("Quantity: ${widget.chat.negotiatedQuantity}"),
                  ],
                ),
                if (widget.chat.status == 'pending_approval')
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _handleDecision('reject'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text("Reject"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleDecision('approve'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text("Approve"),
                      ),
                    ],
                  )
              ],
            ),
          ),

          Expanded(
            child: Center(
                child: Text(
                    "Chat History Placeholder\n(Implement fetch history like Customer App)")),
          ),

          // Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Reply to customer...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Send message logic
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
