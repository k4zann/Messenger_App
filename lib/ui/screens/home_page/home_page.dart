import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth/auth_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _logout() async {
    final authenticateService = Provider.of<AuthenticationService>(context, listen: false);
    try {
      await authenticateService.logout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () {
            _logout();
          },
          icon: const Icon(Icons.logout),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'adsfasdf'
            )
          ]
        )
      ),
    );
  }
}
