import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/profile/user_profile_edit_page.dart';

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
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(user.uid)
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
            color: Colors.white,
            alignment: FractionalOffset.center,
            child: new Center(
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? new CupertinoActivityIndicator()
                  : new CircularProgressIndicator(),
            ),
          );

        final document = snapshot.data;

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
          body: Padding(
            padding: EdgeInsets.only(top: 16),
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: document['userImage'] != null
                        ? new CachedNetworkImage(
                      imageUrl: document['userImage'],
                      imageBuilder: (context, imageProvider) => Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(Colors.white, BlendMode.colorBurn),
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Theme.of(context).platform == TargetPlatform.iOS
                          ? new CupertinoActivityIndicator()
                          : new CircularProgressIndicator(),
                      errorWidget: (context, url, error) => new Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: new Text('[Нет фото]')),
                      ),
                    )
                        : new Image.asset("assets/images/def.png"),
                  ),
                  title: Text('${document['userName']}',
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text('Редактирование профиля'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileEditPage(user: user),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
