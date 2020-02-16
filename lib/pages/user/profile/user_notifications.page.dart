import 'package:flutter/material.dart';

class UserNotificationsPage extends StatefulWidget {
  @override
  _UserNotificationsPageState createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Уведомления',
          style: new TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: true,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),

        textTheme: TextTheme(
            title: TextStyle(
              color: Colors.black,
              fontSize: 22,
            )
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration( //                    <-- BoxDecoration
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 3,
                ),
              ),
              color: Colors.white,
            ),
            child: ListTile(
              title: Text('Новое сообщение'),
              trailing: Text('12:03 12.01.2020',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration( //                    <-- BoxDecoration
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 3,
                ),
              ),
              color: Colors.white,
            ),
            child: ListTile(
              title: Text('Новое сообщение'),
              trailing: Text('12:03 12.01.2020',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration( //                    <-- BoxDecoration
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 3,
                ),
              ),
              color: Colors.white,
            ),
            child: ListTile(
              title: Text('Новое сообщение'),
              trailing: Text('12:03 12.01.2020',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
