import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAdsPage extends StatefulWidget {

  final FirebaseUser user;
  UserAdsPage({this.user});

  @override
  _UserAdsPageState createState() => _UserAdsPageState(user: this.user);
}

class _UserAdsPageState extends State<UserAdsPage> {

  final FirebaseUser user;
  _UserAdsPageState({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Объявления'),
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
