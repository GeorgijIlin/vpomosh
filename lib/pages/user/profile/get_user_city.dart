import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GetUserCity extends StatefulWidget {

  final FirebaseUser user;
  GetUserCity({this.user});

  @override
  _GetUserCityState createState() => _GetUserCityState(user: this.user);
}

class _GetUserCityState extends State<GetUserCity> {

  final FirebaseUser user;
  _GetUserCityState({this.user});

  final TextEditingController _cityNameController = new TextEditingController();

  String searchString;

  List cities = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: new AppBar(
          title: new TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Поиск по городам',
            ),
            controller: _cityNameController,

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
                _cityNameController.clear();
              },
            ),
          ],
          backgroundColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            child: new StreamBuilder<QuerySnapshot>(
              stream: (searchString == null || searchString.trim() == '')
                  ? Firestore.instance.collection('data').document('users').collection('cities')
                  .orderBy('cityName').snapshots()
                  : Firestore.instance.collection('data').document('users').collection('cities')
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
                return new ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) => _buildSearchItem(context, snapshot.data.documents[index], ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchItem(BuildContext context, DocumentSnapshot document) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new ListTile(
          title: new Text('${document['cityName']}'),
          onTap: () async {
            _cityNameController.text = document['cityName'];

            await Firestore.instance
                .collection('users')
                .document(user.uid)
                .updateData({'userCity': document['cityName']});

            var city = {
              'name': document['cityName'],
            };

            cities.add(city);

            if (cities.isEmpty){
              return;
            }
            Navigator.pop(context, cities);
          },
        ),
//        new Divider(),
      ],
    );
  }

}
