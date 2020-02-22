import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/chat_room_page.dart';

class UserMessagesPage extends StatefulWidget {

  final FirebaseUser user;
  UserMessagesPage({this.user});

  @override
  _UserMessagesPageState createState() => _UserMessagesPageState(user: this.user);
}

class _UserMessagesPageState extends State<UserMessagesPage> {

  final FirebaseUser user;
  _UserMessagesPageState({this.user});

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Сообщения'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        textTheme: TextTheme(
          title: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection("users")
            .document(user.uid)
            .collection('chats')
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

          final chats = snapshot.data.documents;

          if (chats.length == 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Image.asset('assets/images/empty.png'),
                ),
                ListTile(
                  title: new Text(
                    'Нет чатов',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) => buildChatItem(
                  context: context,
                  document: chats[index],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildChatItem({BuildContext context, document}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${document['userName'][0]}'),
            ),
          ),
          title: Text(
            '${document['userName']}',
            style: TextStyle(color: Colors.black),
          ),
          trailing: new Icon(Icons.chevron_right, color: Colors.black,),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatRoomPage(
                      peerId: document['userId'],
                      currentId: user.uid,
                      peerName: document['userName'],
                      user: user,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }
}
