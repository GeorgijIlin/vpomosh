import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpomosh/widgets/walkthrough.dart';


class WalkPage extends StatefulWidget {

  final SharedPreferences prefs;
  final List<Walkthrough> pages = [
    Walkthrough(
      title: "Экран_1",
      color: Colors.white,
      description: "Описание_1",
    ),

    Walkthrough(
      title: "Экран_2",
      color: Colors.white,
      description: "Описание_2",
    ),
  ];

  WalkPage({this.prefs});

  @override
  _WalkPageState createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper.children(
        autoplay: false,
        index: 0,
        loop: false,
        pagination: new SwiperPagination(
          margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
          builder: new DotSwiperPaginationBuilder(
              color: Colors.black26,
              activeColor: Colors.black,
              size: 6.5,
              activeSize: 8.0),
        ),
        control: SwiperControl(
          iconPrevious: null,
          iconNext: null,
        ),
        children: _getPages(context),
      ),
    );
  }

  List<Widget> _getPages(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.pages.length; i++) {
      Walkthrough page = widget.pages[i];
      widgets.add(
        new Container(
          color: page.color,
          child: new Column(
            children: <Widget>[
              _buildTitle(page),
              _buildSubtitle(page),
            ],
          ),
        ),
      );
    }
    widgets.add(
      new Container(
        color: Colors.white,
        child: new Column(
          children: <Widget>[
            new  Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: new Text(
                  'Экран_3',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.none,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                  ),
                ),
              ),
            ),


            new Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: new Text(
                  'Описание_3',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: "Roboto",
                  ),
                ),
              ),
            ),

            new Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: new FlatButton(
                  onPressed: () {
                    widget.prefs.setBool('seen', true);

                    Navigator.of(context).pushNamed("/root");

                  },
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    'Поехали',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return widgets;
  }

  Widget _buildSubtitle(page) {
    return new Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Text(
          page.description,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            decoration: TextDecoration.none,
            fontSize: 15.0,
            fontWeight: FontWeight.w300,
            fontFamily:'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(page) {
    return new Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: new Text(
          page.title,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.none,
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            fontFamily: "Roboto",
          ),
        ),
      ),
    );
  }
}