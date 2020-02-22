import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/chat_screen.dart';

class ChatRoomPage extends StatefulWidget {

  final FirebaseUser user;
  final String peerId;
  final String currentId;
  final String peerName;

  ChatRoomPage({
    this.peerId,
    this.currentId,
    this.peerName,
    this.user,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState(
    peerId: this.peerId,
    currentId: this.currentId,
    peerName: this.peerName,
    user: this.user,
  );
}

class _ChatRoomPageState extends State<ChatRoomPage> {

  final String peerId;
  final String currentId;
  final String peerName;
  final FirebaseUser user;

  _ChatRoomPageState({
    this.peerId,
    this.currentId,
    this.peerName,
    this.user,
  });

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('$peerName'),
        automaticallyImplyLeading: true,
        centerTitle: false,
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
      body:  Stack(
        children: <Widget>[
          Container(
            child: new StreamBuilder(
              stream: Firestore.instance
                  .collection("users")
                  .document(user.uid)
                  .collection("chats")
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData)
                  return new Container(
                    alignment: FractionalOffset.center,
                    child: Center(
                        child: Theme.of(context).platform == TargetPlatform.iOS
                            ? new CupertinoActivityIndicator()
                            : new CircularProgressIndicator()
                    ),
                  );

                return Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) => buildItem(
                        context: context,
                        document: snapshot.data.documents[index],
                      ),
                    )
                );

                /*if (snapshot.data.documents.length == 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Image.asset('assets/images/empty.png'),
                      ),
                      ListTile(
                        title: new Text(
                          'Нет сообщений',
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
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) => buildItem(
                        context: context,
                        document: snapshot.data.documents[index],
                      ),
                    )
                  );
                }*/
              },
            ),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
              ),
              color: Colors.white.withOpacity(0.8),
            )
                : Container(),
          )
        ],
      ),
    );
  }

  Widget buildItem({BuildContext context, DocumentSnapshot document, }) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: new Container(
            child: new CircleAvatar(
              child: document['userName'] != null
                  ? new Text('${document['userName'][0]}')
                  : new Text('${document['userName']}'),
            ),
          ),
          title: document['userName'] != null
              ? new Text(
            '${document['userName']}',
            style: TextStyle(color: Colors.black),
          )
              : new Text(
            'Имя',
            style: TextStyle(color: Colors.black),
          ),
          trailing: new Icon(Icons.chevron_right, color: Colors.black,),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(
                      peerId: peerId,
                      currentId: currentId,
                      peerName: peerName,
                    ),
              ),
            );
          },
        ),
        Divider(),
      ],
    );
  }
}