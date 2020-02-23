import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vpomosh/pages/user/active_ad_detail_page.dart';
import 'package:like_button/like_button.dart';

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

  bool _isFavorited = false;

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
            body: Padding(
              padding: EdgeInsets.only(top: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) => _buildItem(context, ads[index]),
              ),
            ),
          );
        }

      },
    );
  }

  Widget _buildItem(BuildContext context, ad) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveAdDetailPage(
              user: user,
              ad: ad,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Stack(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: '${ad['images'][0]}',
                  imageBuilder: (context, imageProvider) => Center(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Theme.of(context).platform == TargetPlatform.iOS ? Center(child: CupertinoActivityIndicator()) : Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                ),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: LikeButton(
                      size: 30,
                      circleColor: CircleColor(
                        start: Colors.white, end: Colors.white,),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: Colors.white,
                        dotSecondaryColor: Colors.white,
                      ),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.white : Colors.white,
                          size: 30,
                        );
                      },
                      onTap: onLikeButtonTapped,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${ad['adServiceName']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child:
                    Text(
                      '${ad['price']} ₽',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM kk:mm','ru').format(DateTime.fromMillisecondsSinceEpoch(int.parse(ad['timestamp']))),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async{
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;

    return !isLiked;
  }
}
