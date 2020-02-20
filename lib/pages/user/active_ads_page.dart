import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveAdsPage extends StatefulWidget {

  final FirebaseUser user;
  ActiveAdsPage({this.user});

  @override
  _ActiveAdsPageState createState() => _ActiveAdsPageState(
    user: this.user,
  );
}

class _ActiveAdsPageState extends State<ActiveAdsPage> {

  final FirebaseUser user;
  _ActiveAdsPageState({this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('ads')
          .where('ownerId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
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

        if (ads.length == 0) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Image.asset('assets/images/no_data.png'),
                ),
                ListTile(
                  title: new Text(
                    'Нет объвлений',
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
          return new Scaffold(
            backgroundColor: Colors.white,
            body: new ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildItem(context, ads[index]),
            ),
          );
        }

      },
    );
  }

  Widget _buildItem(BuildContext context, ad) {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            ListTile(
              leading: CachedNetworkImage(
                imageUrl: '${ad['images'][0]}',
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
              ),
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
                      'Подробнее',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
