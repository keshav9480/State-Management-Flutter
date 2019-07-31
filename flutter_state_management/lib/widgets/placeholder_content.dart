
import 'package:flutter/cupertino.dart';

class PlaceholderContent extends StatelessWidget{

 final String title;
 final String message;
 PlaceholderContent({this.title:'Nothing Here', this.message:'Add new item to get started'});
 @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
          Text(
            message,
            style: TextStyle( fontSize: 24.0, fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}