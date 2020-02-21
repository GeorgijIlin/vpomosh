import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vpomosh/pages/user/chat_room_page.dart';

class UserSearchPage extends StatefulWidget {

  final FirebaseUser user;
  UserSearchPage({this.user});

  @override
  _UserSearchPageState createState() => _UserSearchPageState(user: this.user);
}

class _UserSearchPageState extends State<UserSearchPage> {

  final FirebaseUser user;
  _UserSearchPageState({this.user});

  final TextEditingController _seachItemController = new TextEditingController();

  String searchString;

  List items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: new AppBar(
          title: new TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(Icons.search),
              hintText: 'Поиск по услугам',
              hintStyle: TextStyle(
                fontSize: 20,
              ),
            ),
            controller: _seachItemController,
            style: TextStyle(
              fontSize: 20,
            ),
            onChanged: (value) {
              setState(() {
                searchString = value.toLowerCase();
              });
            },
          ),
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),

          textTheme: TextTheme(
              title: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              )
          ),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.clear),
              onPressed: () {
                _seachItemController.clear();
              },
            ),
          ],
          backgroundColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: new StreamBuilder<QuerySnapshot>(
              stream: (searchString == null || searchString.trim() == '')
                  ? Firestore.instance.collection('ads').where('isActive', isEqualTo: true)
                  .orderBy('timestamp').snapshots()
                  : Firestore.instance.collection('ads').where('isActive', isEqualTo: true)
                  .where('searchIndex', arrayContains: searchString)
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
                  padding: EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) => _buildSearchItem(context, snapshot.data.documents[index], ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchItem(BuildContext context, DocumentSnapshot ad) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: new ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ad['images'].length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: Image.network(
                          ad['images'][index],
                          fit: BoxFit.fill,
                        ),
                      );
                    }),
              ),
              ListTile(
                title: Text('${ad['adServiceName']}'),
                subtitle: Text('${ad['adCategoryName']}'),
                trailing: Text('${ad['price']} ₽'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      DateFormat('dd MMM kk:mm','ru').format(DateTime.fromMillisecondsSinceEpoch(int.parse(ad['timestamp']))),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    FlatButton(
                      child: Text(
                        'Написать',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomPage(
                              peerId: ad['ownerId'],
                              currentId: user.uid,
                              peerName: ad['ownerName'],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
