import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/service_page.dart';

class UserNewAdPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot owner;
  UserNewAdPage({this.user, this.owner});

  @override
  _UserNewAdPageState createState() => _UserNewAdPageState(
    user: this.user,
    owner: this.owner,
  );
}

class _UserNewAdPageState extends State<UserNewAdPage> {

  final FirebaseUser user;
  final DocumentSnapshot owner;
  _UserNewAdPageState({this.user, this.owner});

  String searchString;
  final TextEditingController _categoryController = new TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите категорию'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
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
                      _categoryController.clear();
                    },
                  ),
                  hintText: 'Поиск по категориям',
                  hintStyle: TextStyle(fontSize: 20),
                  icon: Icon(Icons.search),
                ),
                controller: _categoryController,
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
                  ? Firestore.instance.collection('data').document('users').collection('categories')
                  .orderBy('category').snapshots()
                  : Firestore.instance.collection('data').document('users').collection('categories')
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
            '${document['category'][0]}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      title: new Text(
        '${document['category']}',
        overflow: TextOverflow.fade,
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicePage(
              user: user,
              category: document,
              owner: owner,
            ),
          ),
        );
      },
    );
  }
}