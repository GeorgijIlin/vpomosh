import 'package:flutter/material.dart';
import 'package:vpomosh/pages/user/chat_screen.dart';

class ChatRoomPage extends StatefulWidget {

  final String peerId;
  final String currentId;
  final String peerName;

  ChatRoomPage({
    this.peerId,
    this.currentId,
    this.peerName,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState(
    peerId: this.peerId,
    currentId: this.currentId,
    peerName: this.peerName,
  );
}

class _ChatRoomPageState extends State<ChatRoomPage> {

  final String peerId;
  final String currentId;
  final String peerName;

  _ChatRoomPageState({
    this.peerId,
    this.currentId,
    this.peerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('$peerName'),
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
      body: ChatScreen(
        peerId: peerId,
        currentId: currentId,
        peerName: peerName,
      ),
    );
  }
}