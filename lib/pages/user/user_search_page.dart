import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSearchPage extends StatefulWidget {

  final FirebaseUser user;
  UserSearchPage({this.user});

  @override
  _UserSearchPageState createState() => _UserSearchPageState(user: this.user);
}

class _UserSearchPageState extends State<UserSearchPage> {

  final FirebaseUser user;
  _UserSearchPageState({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Поиск'),
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
