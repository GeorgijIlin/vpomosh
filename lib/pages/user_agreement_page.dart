import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class UserAgreementPage extends StatefulWidget {

  final SharedPreferences prefs;
  UserAgreementPage({this.prefs});


  @override
  _UserAgreementPageState createState() => _UserAgreementPageState(
    prefs: this.prefs,
  );
}

class _UserAgreementPageState extends State<UserAgreementPage> {

  final SharedPreferences prefs;
  _UserAgreementPageState({this.prefs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Условия использования'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 16),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('1.Что такое Vpomosh'),
              subtitle: Text('Vpomosh — это мобильное приложение, представляющее собой совокупность содержащихся в информационной системе объектов интеллектуальной собственности Компании и информации (административного и пользовательского контента) (по тексту Условий — «Vpomosh»).'),
            ),
            ListTile(
              title: Text('2.Что такое Vpomosh'),
              subtitle: Text('Vpomosh — это мобильное приложение, представляющее собой совокупность содержащихся в информационной системе объектов интеллектуальной собственности Компании и информации (административного и пользовательского контента) (по тексту Условий — «Vpomosh»).'),
            ),
            ListTile(
              title: Text('3.Что такое Vpomosh'),
              subtitle: Text('Vpomosh — это мобильное приложение, представляющее собой совокупность содержащихся в информационной системе объектов интеллектуальной собственности Компании и информации (административного и пользовательского контента) (по тексту Условий — «Vpomosh»).'),
            ),
            ListTile(
              title: Text('4.Что такое Vpomosh'),
              subtitle: Text('Vpomosh — это мобильное приложение, представляющее собой совокупность содержащихся в информационной системе объектов интеллектуальной собственности Компании и информации (административного и пользовательского контента) (по тексту Условий — «Vpomosh»).'),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: FlatButton(
                child: Text(
                  'СОГЛАСЕН',
                  style: TextStyle(color: Theme.of(context).primaryColor,),
                ),
                onPressed: () {
                  prefs.setBool('seen', true);
                  Navigator.of(context).pushNamed("/root");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
