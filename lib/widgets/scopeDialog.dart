import 'package:flutter/material.dart';

showScopeDialog(context, List<dynamic> scope, String appId, callback) {
  var stringScope = List<String>.from(scope).join(', ');
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text("Do you want to share following information with " + appId + "?"),
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

// class ScopeDialog extends StatefulWidget {
//   ScopeDialog({Key key}) : super(key: key);

//   _ScopeDialogState createState() => _ScopeDialogState();
// }

// class _ScopeDialogState extends State<ScopeDialog> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//        child: child,
//     );
//   }
// }