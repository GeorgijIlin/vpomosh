import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/admin/admin_profile_page.dart';
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
                title: Text('Админ'),
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
              drawer: _buildDrawer(document),
              body: null,
            );
          } else {
            return Scaffold(
              body: new PageView(
                children: [
                  Container(color: Colors.white, child: document['userView'] == 1 ? UserAdsPage(user: user) : UserSearchPage(user: user)),
                  new Container(color: Colors.white, child: document['userView'] == 1 ? UserSearchPage(user: user) : UserAdsPage(user: user)),
                  new Container(color: Colors.white, child: UserNewAdPage(user: user, owner: document)),
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
                      icon: new Icon(document['userView'] == 1 ? Icons.list : Icons.search, size: 25.0, color: (_page == 0) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      title: Text(document['userView'] == 1 ? 'Объявления' : 'Поиск', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,),),
                      backgroundColor: Colors.white,
                    ),
                    BottomNavigationBarItem(
                      icon: new Icon(document['userView'] == 1 ? Icons.search : Icons.list, size: 25.0, color: (_page == 1) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      title: Text(document['userView'] == 1 ? 'Поиск' : 'Объявления', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
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

  Widget _buildDrawer(document) {
    return new Container(
      color: Colors.white,
      child: new Drawer(
        child: new ListView(
          children: <Widget>[
            ListTile(
              leading: CachedNetworkImage(
                imageUrl: document['userImage'],
                imageBuilder: (context, imageProvider) => Container(
                  width: 45,
                  height: 45,
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
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: new Icon(Icons.info_outline, color: Theme.of(context).primaryColor,)),
                ),
              ),
              title: new Text('${document['userName']}', style: TextStyle(color: Colors.black, fontSize: 18),),
              subtitle: Text('Профиль'),
              trailing: new Icon(Icons.chevron_right, color: Colors.black,),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminProfilePage(user: user, onSignedOut: onSignedOut),
                  ),
                );
              },
            ),
             Divider(color: Theme.of(context).primaryColor,),
          ],
        ),
      ),
    );
  }
}
