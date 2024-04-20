import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth/auth_service.dart';
import '../chat_page/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  late String lastMessage = 'Последнее сообщение';

  void getLastMessage() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('chat_rooms')
          .doc('messages') // Assuming 'messages' is the document ID
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        lastMessage = querySnapshot.docs.first.get('message');
        print(lastMessage);
      } else {
        print('No messages found');
      }
    } catch (e) {
      print('Error getting last message: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getLastMessage();
  }

  void _logout() async {
    final authService = Provider.of<AuthenticationService>(context, listen: false);
    authService.logout();
  }

  Container _searchField() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _performSearch(value);
        },
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
          prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.search,
                color: Color(0xff9DB7CB),
                size: 24,
              )
          ),
        ),
      ),
    );
  }

  void _performSearch(String value) {
    if (_searchTimer != null && _searchTimer!.isActive) {
      _searchTimer!.cancel();
    }
    String query = value.trim();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _usersCollection
          .where('name', arrayContains: query)
          .get()
          .then((value) {
      });
    });
  }


  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Произошла ошибка');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('Нет данных'),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }


  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.email != data['email']) {
      String initials = _getInitials(data['name']);
      Color color = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  userId: data['uid'],
                  userName: data['name'],
                  userEmail: data['email'],
                  initials: initials,
                  color: color,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: color,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          title: Text(
            data['name'],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            lastMessage,
            style: const TextStyle(
                color: Color(0xff5E7A90),
                fontSize: 12,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    String initials = '';

    if (nameParts.isNotEmpty) {
      initials += nameParts[0][0].toUpperCase();

      if (nameParts.length > 1) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    return initials;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
                'Чаты',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 32
                )
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _logout();
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: Column(
          children: [
            _searchField(),
            const SizedBox(height: 20,),
            Expanded(
              child: _buildUserList(),
            ),
          ],
        )
    );
  }

}

