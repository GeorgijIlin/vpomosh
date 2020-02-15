import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {

  final FirebaseUser user;
  final VoidCallback onSignedOut;
  UserProfilePage({this.user, this.onSignedOut});

  @override
  _UserProfilePageState createState() => _UserProfilePageState(
    user: this.user,
    onSignedOut: this.onSignedOut,
  );
}

class _UserProfilePageState extends State<UserProfilePage> {

  final FirebaseUser user;
  final VoidCallback onSignedOut;
  _UserProfilePageState({this.user, this.onSignedOut});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Профиль'),
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: null,
    );
  }
  _signOut() async {
    try {
      await _auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}
