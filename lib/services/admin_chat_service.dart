import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:viraeshop_api/viraeshop_api.dart'; // ChatModel, MessageModel

class AdminChatService {
  late IO.Socket socket;
  // TODO: Move base URL to config
  static const String _baseUrl =
      'http://localhost:3000'; // Admin usually web/desktop
  static const String _apiUrl = '$_baseUrl/api/chat';

  void connect(String token) {
    socket = IO.io(
        _baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .disableAutoConnect()
            .build());

    socket.connect();

    socket.onConnect((_) => print('Admin Connected to Socket'));
  }

  void joinChat(String chatId) {
    socket.emit('join_room', {'chatId': chatId});
  }

  void sendMessage(MessageModel message) {
    // Convert to map without id (server generates it) or use existing model toJson
    // For socket, we often send raw data
    final data = {
      'chatId': message.chatId,
      'senderId': message.senderId,
      'senderType': 'admin',
      'content': message.content,
      'type': 'text',
    };
    socket.emit('send_message', data);
  }

  Future<List<ChatModel>> fetchPendingChats() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/pending'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == true) {
          final List data = json['data'];
          return data.map((e) => ChatModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching pending chats: $e");
      return [];
    }
  }

  Future<bool> decideOffer(String chatId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/$chatId/decide'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error deciding offer: $e");
      return false;
    }
  }

  void dispose() {
    socket.dispose();
  }
}
