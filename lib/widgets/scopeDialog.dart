import 'package:flutter/material.dart';

showScopeDialog(context, List<dynamic> scope, String appId, callback) {
  var stringScope = List<String>.from(scope).join(', ');
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text(appId + " wants to access following scope"),
        content: Text(stringScope),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          FlatButton(
            child: Text("Ok"),
            onPressed: callback,
          ),
        ],
      );
    },
  );
}