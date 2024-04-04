import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/chat/chat_service.dart';
import '../../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String initials;
  final Color color;


  const ChatPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.initials,
    required this.color
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final ChatService chatService = ChatService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    void sendMessage() async {
      if (messageController.text.isNotEmpty) {
        await chatService.sendMessage(widget.userId, messageController.text.toString());

        messageController.clear();
      }
    }


    // Message interface
    Widget _messageItem(DocumentSnapshot document) {
      Map<String, dynamic> message = document.data()! as Map<String, dynamic>;
      var alignment = message['senderId'] == auth.currentUser!.uid
          ? Alignment.centerRight
          : Alignment.centerLeft;

      return Container(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: (message['senderId'] == auth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: (message['senderId'] == auth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  MessageBubble(
                    message: message['message'],
                    isMe: message['senderId'] == auth.currentUser!.uid,
                  ),
                ]
            ),
          )
      );
    }


    // Message List
    Widget _messageList() {
      return StreamBuilder(
        stream: chatService.getMessage(widget.userId, auth.currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return _messageItem(snapshot.data!.docs[index]);
            },
          );
        },
      );
    }


    // For message input
    Widget _messageInput() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  print(result.files.first.path);
                }
              },
              iconSize: 24,
            ),
            Expanded(
              child: TextField(
                maxLines: null,
                controller: messageController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(15),
                  hintText: 'Поиск',
                  hintStyle: const TextStyle(
                    color: Color(0xff9DB7CB),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send),
              iconSize: 24,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic),
              iconSize: 24,
            )
          ],
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: widget.color,
              child: Text(
                widget.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10,),
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messageList(),
          ),

          _messageInput(),
        ],
      ),
    );
  }
}

