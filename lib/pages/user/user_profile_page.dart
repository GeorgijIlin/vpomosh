import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vpomosh/pages/user/get_user_city.dart';

class UserProfilePage extends StatefulWidget {

  final FirebaseUser user;
  final VoidCallback onSignedOut;
  UserProfilePage({this.user, this.onSignedOut});

  @override
  _UserProfilePageState createState() => _UserProfilePageState(
    user: this.user,
    onSignedOut: this.onSignedOut,
  );
}

class _UserProfilePageState extends State<UserProfilePage> {

  final FirebaseUser user;
  final VoidCallback onSignedOut;
  _UserProfilePageState({this.user, this.onSignedOut});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  SharedPreferences prefs;
  String userImage = '';
  bool isLoading = false;
  File userFile;
  List cities = [];

  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _userCityController = new TextEditingController();

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
            color: Colors.white,
            alignment: FractionalOffset.center,
            child: new Center(
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? new CupertinoActivityIndicator()
                  : new CircularProgressIndicator(),
            ),
          );

        final document = snapshot.data;

        _userNameController.text = document['userName'];
        _userCityController.text = document['userCity'];

        return Scaffold(
          appBar: AppBar(
            title: new Text('ПРОФИЛЬ'),
            automaticallyImplyLeading: false,
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
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => _signOut(),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: new ListView(
            children: <Widget>[
              new Container(
                height: MediaQuery.of(context).size.height / 4,
                child: new Align(
                  alignment: Alignment.center,
                  child: new Stack(
                    children: <Widget>[
                      Container(
                        child: document['userImage'] != null
                            ? new CachedNetworkImage(
                          imageUrl: document['userImage'],
                          imageBuilder: (context, imageProvider) => Container(
                            width: 150,
                            height: 150,
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
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: new Text('[Нет фото]')),
                          ),
                        )
                            : CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 45,
                          child: Image.asset("assets/images/def.png"),
                        ),
                      ),
                      new Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: new Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          child: new ClipOval(
                            child: Material(
                              color: Theme.of(context).primaryColor, // button color
                              child: InkWell(
                                splashColor: Colors.black, // inkwell color
                                child: SizedBox(width: 35, height: 35, child: Icon(Icons.edit, size: 20, color: Colors.white,)),
                                onTap: () => _getUserImage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new ListTile(
                leading: new Icon(Icons.person, color: Theme.of(context).primaryColor,),
                title: new TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  textInputAction: TextInputAction.go,
                  decoration: new InputDecoration(
                    labelText: 'Имя',
                    suffixIcon: new IconButton(
                      icon: new Icon(Icons.check),
                      onPressed: () async {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        await Firestore.instance
                            .collection('users')
                            .document(user.uid)
                            .updateData({
                          "userName": _userNameController.text,
                        });
                      },
                    ),
                  ),
                  controller: _userNameController,
                ),
              ),
              new ListTile(
                leading: new Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                title: new IgnorePointer(
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      labelText: 'Город',
//                        hintText: 'Выберите город',
                    ),
                    controller: _userCityController,
                  ),
                ),
                onTap:() async {
                  cities = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GetUserCity(user: user),
                    ),
                  );
                  _userCityController.text = cities[0]['name'];
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future _getUserImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        userFile = image;
        _uploadUserFile(userFile);
      });
    }
  }

  Future _uploadUserFile(File file) async {
    var uuid = new Uuid().v1();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child("user_image_$uuid.jpg");
    StorageUploadTask uploadTask = ref.putFile(file);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          userImage = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(user.uid)
              .updateData({
            'userImage': userImage,
          }).then((data) async {
            await prefs.setString('userImage', userImage);
          });
        });
      } else {
      }
    });
  }

  _signOut() async {
    try {
      await _auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}
