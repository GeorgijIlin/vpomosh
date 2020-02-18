import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vpomosh/pages/user/search_address_page.dart';

class AddressPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot category, service;
  final String price;

  AddressPage({this.user, this.category, this.service, this.price});

  @override
  _AddressPageState createState() => _AddressPageState(
    user: this.user,
    category: this.category,
    service: this.service,
    price: this.price,
  );
}

class _AddressPageState extends State<AddressPage> {

  final FirebaseUser user;
  final DocumentSnapshot category, service;
  final String price;

  _AddressPageState({this.user, this.category, this.service, this.price});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Укажите адрес'),
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
      body: SearchAddressPage(
        user: user,
        service: service,
        category: category,
        price: price,
      ),
    );
  }
}
