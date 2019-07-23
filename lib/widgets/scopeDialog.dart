import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

showScopeDialog(context, Map<dynamic, dynamic> scope, String appId, callback, {cancelCallback}) {
  // flutter defined function
  print('scope is    ' + jsonEncode(scope));
  showDialog(
    context: context,
    builder: (BuildContext context) => CustomDialog(
          title: '$appId \n would like to access',
          description: scopeList(context, scope),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: cancelCallback
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: callback,
            )
          ],
        ),
  );
}

Widget scopeList(context, Map<dynamic, dynamic> scope) {
  print(scope);
  print(scope.length);
  var keys = scope.keys.toList();

  return ListView.builder(
      itemCount: scope.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext ctxt, index) {
        var val = scope[keys[index]];
        print(keys[index]);
        print(val);
        if (keys[index] == 'email') {
          val = scope[keys[index]]['email'];
        } else if(keys[index] == 'keys') {
          val = 'Cryptographic key pair';
        }
        return Container(
          margin: EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.keyboard_arrow_right,
                  size: 32.0,
                  color: Colors.black,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    keys[index]?.toUpperCase(),
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    val,
                    textAlign: TextAlign.left,
                  )
                ],
              )
            ],
          ),
        );
      });
}
