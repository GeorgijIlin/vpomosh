import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/price_page.dart';

class ServicePage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot category;

  ServicePage({this.user, this.category});

  @override
  _ServicePageState createState() => _ServicePageState(
    user: this.user,
    category: this.category,
  );
}

class _ServicePageState extends State<ServicePage> {

  final FirebaseUser user;
  final DocumentSnapshot category;

  _ServicePageState({this.user, this.category});

  String searchString;
  final TextEditingController _serviceController = new TextEditingController();

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите услугу'),
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey,),
                    onPressed: () {
                      _serviceController.clear();
                    },
                  ),
                  hintText: 'Поиск по услугам',
                  hintStyle: TextStyle(fontSize: 20),
                  icon: Icon(Icons.search),
                ),
                controller: _serviceController,
                style: TextStyle(fontSize: 20),
                onChanged: (value) {
                  setState(() {
                    searchString = value.toLowerCase();
                  });
                },
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: (searchString == null || searchString.trim() == '')
                  ? Firestore.instance.collection('data').document('users').collection('services')
//                  .where('category', isEqualTo: category['category'])
                  .orderBy('service').snapshots()
                  : Firestore.instance.collection('data').document('users').collection('services')
//                  .where('category', isEqualTo: category['category'])
                  .where('searchIndex', arrayContains: searchString)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return new Container(
                    alignment: FractionalOffset.center,
                    child: new Center(
                      child: Theme.of(context).platform == TargetPlatform.iOS
                          ? new CupertinoActivityIndicator()
                          : new CircularProgressIndicator(),
                    ),
                  );
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: new ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) => _buildSearchItem(context, snapshot.data.documents[index], ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSearchItem(BuildContext context, DocumentSnapshot document) {
    if (document['category'] != category['category']) {
      return Container(
        height: 0.0,
      );
    } else {
      return new ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor, //
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${document['service'][0]}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        title: new Text(
          '${document['service']}',
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 18),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PricePage(
              user: user,
              service: document,
              category: category,
            ),
          ),
        );
        },
      );
    }
  }
}
