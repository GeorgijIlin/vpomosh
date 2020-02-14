import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  HomePage({this.user, this.onSignedOut});

  @override
  _HomePageState createState() => _HomePageState(
    user: this.user,
    onSignedOut: this.onSignedOut,
  );
}

PageController pageController;

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  _HomePageState({this.user, this.onSignedOut});

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null)
            if (snapshot.hasError)
              return new Container(
                color: Colors.white,
                alignment: FractionalOffset.center,
                child: new Center(
                  child: new Text('Ошибка: ${snapshot.error}'),
                ),
              );
          if (!snapshot.hasData)
            return new Container(
              color: Colors.white,
              alignment: FractionalOffset.center,
              child: new Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
              ),
            );

          final document = snapshot.data;

          if (document['userType'] == 1) {
            return Scaffold(
              appBar: AppBar(
                title: new Text('Admin Home Page'),
                automaticallyImplyLeading: false,
                centerTitle: true,
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
              body: Center(
                child: Text('Admin HomePage'),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.yellow,
                title: Text(
                  "User Home Page",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              body: Center(
                child: Text('Admin HomePage'),
              ),
            );
          }
        }
    );
  }
}
