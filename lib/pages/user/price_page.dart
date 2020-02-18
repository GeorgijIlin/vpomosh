import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vpomosh/pages/user/address_page.dart';

class PricePage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot category, service;

  PricePage({this.user, this.category, this.service});

  @override
  _PricePageState createState() => _PricePageState(
    user: this.user,
    category: this.category,
    service: this.service,
  );
}

class _PricePageState extends State<PricePage> {

  final FirebaseUser user;
  final DocumentSnapshot category, service;

  _PricePageState({this.user, this.category, this.service});

  final TextEditingController _priceController = new TextEditingController();
  bool disableButton = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_printLatestValue);
  }

  _printLatestValue() {
    print("Second text field: ${_priceController.text}");
    if (_priceController.text.length != 0) {
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
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Цена'),
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
        body: ListTile(
          leading: new Icon(Icons.attach_money, color: Theme.of(context).primaryColor,),
          title: new TextFormField(
            cursorColor: Theme.of(context).primaryColor,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.go,
            decoration: new InputDecoration(
                labelText: 'Цена',
                hintText: 'Введите цену'
            ),
            controller: _priceController,
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
                      builder: (context) => AddressPage(
                        user: user,
                        service: service,
                        category: category,
                        price: _priceController.text,
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
