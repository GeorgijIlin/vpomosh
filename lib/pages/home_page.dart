import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/user_ads_page.dart';
import 'package:vpomosh/pages/user/user_new_ad_page.dart';
import 'package:vpomosh/pages/user/user_messages_page.dart';
import 'package:vpomosh/pages/user/user_profile_page.dart';
import 'package:vpomosh/pages/user/user_search_page.dart';

class HomePage extends StatefulWidget {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  HomePage({this.user, this.onSignedOut});

  @override
  _HomePageState createState() => _HomePageState(
    user: this.user,
    onSignedOut: this.onSignedOut,
  );
}

PageController pageController;

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  _HomePageState({this.user, this.onSignedOut});

  PageController pageController;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
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

          final document = snapshot.data;

          if (document['userType'] == 1) {
            return Scaffold(
              appBar: AppBar(
                title: new Text('Admin Home Page'),
                automaticallyImplyLeading: false,
                centerTitle: true,
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
              ),
              backgroundColor: Colors.white,
              body: Center(
                child: Text('Admin HomePage'),
              ),
            );
          } else {
            return Scaffold(
              body: new PageView(
                children: [
                  new Container(color: Colors.white, child: UserSearchPage(user: user)),
                  new Container(color: Colors.white, child: UserAdsPage(user: user)),
                  new Container(color: Colors.white, child: UserNewAdPage(user: user)),
                  new Container(color: Colors.white, child: UserMessagesPage(user: user)),
                  new Container(color: Colors.white, child: UserProfilePage(user: user, onSignedOut: onSignedOut)),
                ],
                controller: pageController,
                physics: new NeverScrollableScrollPhysics(),
                onPageChanged: onPageChanged,
              ),
              bottomNavigationBar: new Container(
                height: Theme.of(context).platform == TargetPlatform.iOS ? 100.0 : 64.0,
                child: new Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                    primaryColor: Colors.redAccent,
                    textTheme: Theme.of(context).textTheme.copyWith(
                      caption: new TextStyle(color: Colors.black),
                    ),
                  ),
                  child: BottomNavigationBar(items: [
                    BottomNavigationBarItem(
                      icon: new Icon(Icons.search, size: 25.0, color: (_page == 0) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      title: Text('Поиск', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,),),
                      backgroundColor: Colors.white,
                    ),
                    BottomNavigationBarItem(
                      icon: new Icon(Icons.list, size: 25.0, color: (_page == 1) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      title: Text('Объявления', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
                      backgroundColor: Colors.white,
                    ),
                    BottomNavigationBarItem(
                      icon: new Icon(Icons.add_circle, size: 40.0, color: (_page == 2) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      title: Text('Разместить', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
                      backgroundColor: Colors.white,
                    ),
                    BottomNavigationBarItem(
                      icon: new Icon(Icons.message, size: 25.0, color: (_page == 3) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      title: Text('Сообщения', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
                      backgroundColor: Colors.white,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person, size: 25.0, color: (_page == 4) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      title: Text('Профиль', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
                      backgroundColor: Colors.white,
                    ),
                  ],
                    fixedColor: Theme.of(context).primaryColor,
                    type: BottomNavigationBarType.shifting,
                    onTap: navigationTapped,
                    currentIndex: _page,
                  ),
                ),
              ),
            );
          }
        }
    );
  }
  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
