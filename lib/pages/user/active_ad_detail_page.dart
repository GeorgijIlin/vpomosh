import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActiveAdDetailPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot ad;
  ActiveAdDetailPage({this.user, this.ad});

  @override
  _ActiveAdDetailPageState createState() => _ActiveAdDetailPageState(
    user: this.user,
    ad: this.ad,
  );
}

class _ActiveAdDetailPageState extends State<ActiveAdDetailPage> {

  final FirebaseUser user;
  final DocumentSnapshot ad;
  _ActiveAdDetailPageState({this.user, this.ad});

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
            alignment: FractionalOffset.center,
            child: Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator()
            ),
          );

        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: new Text('${ad['adServiceName']}'),
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
          body: ListView(
            children: <Widget>[
              ListTile(
                title: Text('Адрес'),
                subtitle: Text('${ad['address']}'),
              ),
              Divider(),
              ListTile(
                title: Text('Изображения'),
                subtitle: GridView.count(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: List.generate(ad['images'].length, (index) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: "${ad['images'][index]}",
                        placeholder: (context, url) => Center(child: Theme.of(context).platform == TargetPlatform.iOS
                            ? new CupertinoActivityIndicator()
                            : new CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Center(child: new Icon(Icons.error)),
                      ),
                    );
                  }),
                ),
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }
}
