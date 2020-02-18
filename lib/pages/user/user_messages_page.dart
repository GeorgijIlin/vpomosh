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
      body: Stack(
        children: <Widget>[
          Container(
            child: new StreamBuilder(
              stream: Firestore.instance
                  .collection("users")
                  .document(user.uid)
                  .collection("messages")
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

                if (snapshot.data.documents.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
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
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) => buildItem(
                      context: context,
                      document: snapshot.data.documents[index],
                    ),
                  );
                }
              },
            ),
          ),
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

  Widget buildItem({BuildContext context, document}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: ListTile(
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
            ) ,
            trailing: new Icon(Icons.chevron_right, color: Colors.black,),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    peerId: document['userId'],
                    currentId: widget.user.uid,
                    peerName: document['userName']!= null
                        ? document['userName']
                        : 'Имя',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
