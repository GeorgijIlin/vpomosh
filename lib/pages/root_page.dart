import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/home_page.dart';
import 'package:vpomosh/pages/login_page.dart';
import 'package:vpomosh/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpomosh/pages/user_agreement_page.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with SingleTickerProviderStateMixin {

  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  FirebaseAuth _fbAuth;

  FirebaseUser _user;

  final newUser = new User(null, null, null, null, null, null, null, null, null, null);

  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    _getPrefs();

    _fbAuth = FirebaseAuth.instance;

    _fbAuth.currentUser().then((FirebaseUser user) {
      setState(() {
        authStatus = user == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;

      });
    });

    _fbAuth.onAuthStateChanged.listen((FirebaseUser user) {

      setState(() {
        if (user == null ) {
          authStatus = AuthStatus.NOT_LOGGED_IN;
        } else {
          authStatus = AuthStatus.LOGGED_IN;

          setState(() {
            _user = user;
          });
        }
        authStatus = user == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
          body: LayoutBuilder(builder: (context, constraint) {
            if (authStatus == AuthStatus.NOT_DETERMINED) {
              return _buildWaitingScreen();
            } else if (authStatus == AuthStatus.NOT_LOGGED_IN) {
              return new LoginPage();
            } else if (authStatus == AuthStatus.LOGGED_IN) {
              return _buildStream();
            } else {
              return _buildWaitingScreen();
            }

          })),
    );
  }

  Widget _buildStream() {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(_user.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.data != null)

            if (snapshot.hasError)
              return new Container(
                color: Colors.white,
                alignment: FractionalOffset.center,
                child: new Center(
                  child: new Text('Ошибка'),
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

          if (!snapshot.data.exists)
            return new Container(
              color: Colors.white,
              alignment: FractionalOffset.center,
              child: new Center(
                child: new ListTile(
                  title: new Text('Создаем ваш профиль', textAlign: TextAlign.center,),
                  subtitle: new Text('Пожалуйста, подождите немного', textAlign: TextAlign.center,),
                ),
              ),
            );


          return _buildState(snapshot.data);

        }
    );
  }

  Widget _buildState(document) {
    if (document['isAgree'] != false) {
      return new HomePage(
        user: _user,
        onSignedOut: _onSignedOut,
      );
    } else {
      return new UserAgreementPage(
        user: _user,
      );
    }
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.redAccent))),
    );
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    });
  }

  void _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

}
