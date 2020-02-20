import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HistoryAdsPage extends StatefulWidget {

  final FirebaseUser user;
  HistoryAdsPage({this.user});

  @override
  _HistoryAdsPageState createState() => _HistoryAdsPageState(
    user: this.user,
  );
}

class _HistoryAdsPageState extends State<HistoryAdsPage> {

  final FirebaseUser user;
  _HistoryAdsPageState({this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('ads')
//          .where('')
          .snapshots(),
      builder: (context, snapshot) {
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
            alignment: FractionalOffset.center,
            child: Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator()
            ),
          );

        final ads = snapshot.data.documents;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text('HISTORY'),
          ),
        );
      },
    );
  }
}
