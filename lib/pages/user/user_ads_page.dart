import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/active_ads_page.dart';
import 'package:vpomosh/pages/user/history_ads_page.dart';
import 'package:intl/date_symbol_data_local.dart';

class UserAdsPage extends StatefulWidget {

  final FirebaseUser user;
  UserAdsPage({this.user});

  @override
  _UserAdsPageState createState() => _UserAdsPageState(user: this.user);
}

class _UserAdsPageState extends State<UserAdsPage> with SingleTickerProviderStateMixin {

  final FirebaseUser user;
  _UserAdsPageState({this.user});

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    initializeDateFormatting('ru', null);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('ads')
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError)
          return new Container(
            color: Colors.white,
            alignment: FractionalOffset.center,
            child: new Center(
              child: new Text('Error: ${snapshot.error}'),
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

        return Scaffold(
          appBar: AppBar(
            title: new Text('Мои объявления'),
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
            bottom: TabBar(
              unselectedLabelColor: Theme.of(context).primaryColor.withOpacity(0.5),
              labelColor: Colors.amber,
              tabs: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Активные',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('История',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            bottomOpacity: 1,
          ),
          backgroundColor: Colors.white,
          body: TabBarView(
            children: <Widget>[
              ActiveAdsPage(user: user),
              HistoryAdsPage(user: user),
            ],
            controller: _tabController,
          ),
        );
      },
    );
  }
}
