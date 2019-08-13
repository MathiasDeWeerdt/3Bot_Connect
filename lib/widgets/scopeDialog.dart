import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';



void changeValue(value) {
  print('TAPPED: ${value}');
  value = !value;
}

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
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
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
          child: SwitchListTile(
            value: true,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (bool val) => changeValue(val),
            title: Text( 
              keys[index]?.toUpperCase(), 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(val),
            secondary: const Icon(Icons.keyboard_arrow_right, size: 32,),),
        );
      });
}
