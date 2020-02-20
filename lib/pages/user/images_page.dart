import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';


class ImagesPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot category, service, owner;
  final String price;
  final String address;

  ImagesPage({this.user, this.category, this.service, this.price, this.address, this.owner});

  @override
  _ImagesPageState createState() => _ImagesPageState(
    user: this.user,
    category: this.category,
    service: this.service,
    price: this.price,
    address: this.address,
    owner: this.owner,
  );
}

class _ImagesPageState extends State<ImagesPage> {

  final FirebaseUser user;
  final DocumentSnapshot category, service, owner;
  final String price;
  final String address;

  _ImagesPageState({this.user, this.category, this.service, this.price, this.address, this.owner});

  List<Asset> images = List<Asset>();
  bool _isLoading = false;
  bool _isDesabled = false;
  List urls = [];
  int _count = 0;

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return Padding(
          padding: EdgeInsets.all(3.0),
          child: AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          ),
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 8,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

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

        return Scaffold(
          appBar: AppBar(
            title: Text('Загрузите фотографии'),
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
          body: Column(
            children: <Widget>[
              _isLoading == true ? LinearProgressIndicator() : Container(height: 0.0),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  child: FlatButton(
                    child: Text(
                      "Выбрать изображения",
                      style: TextStyle(color: _isDesabled != true ? Colors.black : Colors.grey),
                    ),
                    onPressed: _isDesabled != true ? loadAssets : () {},
                  ),
                ),
              ),
              Expanded(
                child: buildGridView(),
              )
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            margin: EdgeInsets.symmetric(vertical: 40),
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width - 50,
              height: 50,
              child: RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0)),
                elevation: 0.0,
                color: images.length != 0
                    ? _isDesabled != true ? Theme.of(context).primaryColor
                    : Colors.grey[400] : Colors.grey[400],
                child: new Text(
                  'Разместить',
                  style: TextStyle(fontSize: 18, color: _isDesabled != true ? Colors.white : Colors.white),
                ),
                onPressed: () async {
                  if (_isDesabled != true) {

                    setState(() {
                      _isDesabled = true;
                      _isLoading = true;
                    });

                    for (var i = 0; i < images.length; i++){
                      var uuid = new Uuid().v1();
                      ByteData byteData = await images[i].getByteData();
                      List<int> imageData = byteData.buffer.asUint8List();
                      StorageReference ref = FirebaseStorage.instance.ref().child('ads').child('${user.uid}').child('${DateTime.now().millisecondsSinceEpoch.toString()}').child("$uuid.png");
                      StorageUploadTask uploadTask = ref.putData(imageData);
                      StorageTaskSnapshot storageTaskSnapshot;
                      storageTaskSnapshot = await uploadTask.onComplete;
                      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
                      urls.add(downloadUrl);
                      downloadUrl = '';
                    }
                    _saveData(document);
                  } else {

                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveData(document) async {

    await Firestore.instance.collection('users').document(user.uid).updateData({
      'userView': 1,
    }).then((_) {
      _saveAd(document);
    }).then((_) {
      _isLoading = false;
      Navigator.pushNamed(context, '/root');
    });
  }

  void _saveAd(document) async {
    CollectionReference reference = Firestore.instance.collection('ads');
    await reference.add({
      // Ad
      'timestamp': new DateTime.now().millisecondsSinceEpoch.toString(),
      'isActive': true,
      'images': urls,
      'adCategoryName': category['category'],
      'adCategorySearchIndex': category['searchIndex'],
      'adServiceName': service['service'],
      'adServiceSearchIndex': service['searchIndex'],
      'price': price,
      'address': address,

      // owner
      'ownerId': user.uid,
      'ownerName': document['userName'],
      'ownerPhone': document['userPhone'],
      //
    }).then((doc) {
      String docId = doc.documentID;
      reference.document(docId).updateData({'adId': docId});
    }).then((_) {
      setState(() {
        urls.clear();
        images.clear();
      });
    });
  }


}

