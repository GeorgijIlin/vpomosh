import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';


class ImagesPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot category, service;
  final String price;
  final String address;

  ImagesPage({this.user, this.category, this.service, this.price, this.address});

  @override
  _ImagesPageState createState() => _ImagesPageState(
    user: this.user,
    category: this.category,
    service: this.service,
    price: this.price,
    address: this.address,
  );
}

class _ImagesPageState extends State<ImagesPage> {

  final FirebaseUser user;
  final DocumentSnapshot category, service;
  final String price;
  final String address;

  _ImagesPageState({this.user, this.category, this.service, this.price, this.address});

  List<Asset> images = List<Asset>();
  bool _isLoading = false;
  bool _isDesabled = false;
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
            onPressed: () {
              if (_isDesabled != true) {
                setState(() {
                  _isDesabled = true;
                  _isLoading = true;
                });
                images.forEach((asset) async {
                  _count = _count + 1;
                  print('_count: $_count');
                  var uuid = new Uuid().v1();
                  ByteData byteData = await asset.getByteData();
                  List<int> imageData = byteData.buffer.asUint8List();
                  StorageReference ref = FirebaseStorage.instance
                      .ref()
                      .child('ads')
                      .child('${user.uid}')
                      .child("$uuid.png");
                  StorageUploadTask uploadTask = ref.putData(imageData);
                  StorageTaskSnapshot storageTaskSnapshot;
                  uploadTask.onComplete.then((value) {
                    if (value.error == null) {
                      storageTaskSnapshot = value;
                      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {

                        setState(() {
                          _isLoading = false;
                        });

                        if (_count == images.length) {
                          setState(() {
                            _updateUserView();
                            Navigator.pushNamed(context, '/root');
                          });
                        }

                      });
                    } else {

                    }
                  });
                });
              } else {

              }
            },
          ),
        ),
      ),
    );
  }

  uploadFile() {
    images.forEach((asset) async {
      var uuid = new Uuid().v1();
      ByteData byteData = await asset.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child('ads')
          .child('${user.uid}')
          .child("$uuid.png");
      StorageUploadTask uploadTask = ref.putData(imageData);
      StorageTaskSnapshot storageTaskSnapshot;
      uploadTask.onComplete.then((value) {
        if (value.error == null) {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {

          });
        } else {

        }
      });
    });
  }

  void _updateUserView() async {
    await Firestore.instance.collection('users').document(user.uid).updateData({
      'userView': 1,
    });
  }

}

