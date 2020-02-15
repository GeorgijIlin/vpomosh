import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserMessagesPage extends StatefulWidget {

  final FirebaseUser user;
  UserMessagesPage({this.user});

  @override
  _UserMessagesPageState createState() => _UserMessagesPageState(user: this.user);
}

class _UserMessagesPageState extends State<UserMessagesPage> {

  final FirebaseUser user;
  _UserMessagesPageState({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Сообщения'),
        automaticallyImplyLeading: false,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: null,
    );
  }
}
