import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vpomosh/pages/user/images_page.dart';

class SearchAddressPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot category, service;
  final String price;

  SearchAddressPage({this.user, this.category, this.service, this.price});

  @override
  _SearchAddressPageState createState() => _SearchAddressPageState(
    user: this.user,
    category: this.category,
    service: this.service,
    price: this.price,
  );
}

class _SearchAddressPageState extends State<SearchAddressPage> {

  final FirebaseUser user;
  final DocumentSnapshot category, service;
  final String price;

  _SearchAddressPageState({this.user, this.category, this.service, this.price});

  final TextEditingController _addressController = new TextEditingController();
  bool disableButton = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_printLatestValue);
  }

  _printLatestValue() {
    print("Second text field: ${_addressController.text}");
    if (_addressController.text.length != 0) {
      setState(() {
        disableButton = true;
      });
    } else {
      setState(() {
        disableButton = false;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor,),
              suffixIcon: new IconButton(
                icon: new Icon(Icons.clear, color: Colors.grey, size: 16,),
                onPressed: () => _addressController.clear(),
              ),
              fillColor: Colors.white,
              hintStyle: TextStyle(color: Colors.grey),
              hintText: "Ваш адрес",
            ),
            autofocus: true,
            controller: _addressController,
          ),
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
              color: disableButton
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              child: new Text('Дальше', style: TextStyle(fontSize: 18, color: Colors.white)),
              onPressed: () {
                if (disableButton) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagesPage(
                        user: user,
                        service: service,
                        category: category,
                        price: price,
                        address: _addressController.text,
                      ),
                    ),
                  );
                } else {

                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
