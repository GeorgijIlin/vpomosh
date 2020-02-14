import "package:flutter/material.dart";

class Walkthrough {
  IconData icon;
  String title;
  Color color;
  String description;
  Widget extraWidget;
  String illustration;
  
  Walkthrough({this.icon, this.title, this.color, this.description, this.extraWidget, this.illustration}) {
    if (extraWidget == null) {
      extraWidget = new Container();
    }
  }
}