import 'package:flutter/material.dart';
import 'package:viraeshop_admin/services/admin_chat_service.dart';
import 'package:viraeshop_admin/screens/chat/admin_chat_screen.dart'; // Will create next
import 'package:viraeshop_api/viraeshop_api.dart'; // ChatModel
import 'package:intl/intl.dart';

class ApprovalDashboardScreen extends StatefulWidget {
  static const String path = '/approval_dashboard';
  const ApprovalDashboardScreen({Key? key}) : super(key: key);

  @override
  _ApprovalDashboardScreenState createState() =>
      _ApprovalDashboardScreenState();
}

class _ApprovalDashboardScreenState extends State<ApprovalDashboardScreen> {
  final AdminChatService _chatService = AdminChatService();
  late Future<List<ChatModel>> _pendingChatsFuture;

  @override
  void initState() {
    super.initState();
    _refreshChats();
  }

  void _refreshChats() {
    setState(() {
      _pendingChatsFuture = _chatService.fetchPendingChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Negotiation Approvals")),
      body: FutureBuilder<List<ChatModel>>(
        future: _pendingChatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(child: Text("No pending approvals"));
          }

          return ListView.builder(
            itemCount: chats.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final product =
                  chat.product; // Assuming model has this from include
              final customer = chat.customer;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                      product != null ? product['name'] : 'Unknown Product'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Customer: ${customer != null ? customer['firstName'] : 'Unknown'}"),
                      Text(
                          "Offer: \$${chat.negotiatedPrice} for ${chat.negotiatedQuantity} units"),
                      Text("Status: ${chat.status}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminChatScreen(chat: chat),
                      ),
                    );
                    _refreshChats(); // Refresh on return
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
