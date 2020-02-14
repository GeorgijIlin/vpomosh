import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAgreementPage extends StatefulWidget {

  final FirebaseUser user;
  UserAgreementPage({this.user});

  @override
  _UserAgreementPageState createState() => _UserAgreementPageState(
    user: this.user,
  );
}

class _UserAgreementPageState extends State<UserAgreementPage> {

  final FirebaseUser user;
  _UserAgreementPageState({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Условия использования'),
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
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('1.Что такое Vpomosh'),
              subtitle: Text('Vpomosh — это мобильное приложение, представляющее собой совокупность содержащихся в информационной системе объектов интеллектуальной собственности Компании и информации (административного и пользовательского контента) (по тексту Условий — «Vpomosh»).'),
            ),
            ListTile(
              title: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: FlatButton(
                  child: Text('СОГЛАСЕН/-НА'),
                  onPressed: () {
                    _updateUserAgreement().then((value) {
                      Navigator.of(context).pushNamed("/root");
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _updateUserAgreement() async {
    await Firestore.instance.collection('users').document(user.uid).updateData({
      'isAgree': true,
    });
  }
}
