import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

class PreferenceDialog extends StatefulWidget {
  PreferenceDialog(this.scope, this.appId, this.callback, {Key key})
      : super(key: key);

  final scope;
  final appId;
  final callback;

  _PreferenceDialogState createState() => _PreferenceDialogState();
}

class _PreferenceDialogState extends State<PreferenceDialog> {
  bool _value = true;
  bool _isDisabled = false;

  @override
  void initState() {
    handleInitPermissions();
    super.initState();
  }

  void handleInitPermissions() async {
      var initialMap = jsonDecode(await getScopePermissions());

      if (!initialMap.containsKey(widget.appId)) {
        var newHashMap = new HashMap();
        initialMap[widget.appId] = newHashMap;
        var keysOfScope = widget.scope.keys.toList();
        keysOfScope.forEach((var value) {
            newHashMap[value] = {'enabled': true, 'required': false};
        });
        print(initialMap);
      }
  }

  Future<bool> getPermissions(scope) async {
    print(scope);
    jsonDecode(await getScopePermissions());
    return true;
  }

  Widget scopeList(context, Map<dynamic, dynamic> scope) async{
    var keys = scope.keys.toList();
    //print(scope);
    return ListView.builder(
        itemCount: scope.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext ctxt, index) {
          var val = scope[keys[index]];
          if (keys[index] == 'email') {
            val = scope[keys[index]]['email'];
          } else if (keys[index] == 'keys') {
            val = 'Cryptographic key pair';
          }
          return Container(
            child: SwitchListTile(
              value: await getPermissions("test"),
              activeColor: (!_isDisabled) ? Theme.of(context).primaryColor : Colors.grey,
              onChanged: (bool val) {setState(() {
                print(_isDisabled);
                if (!_isDisabled) {
                  print('bools on ${val}');
                  _value = val;
                }
              });},
              title: Text(
                keys[index]?.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(val),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: '${widget.appId} \n would like to access',
      description: scopeList(context, widget.scope),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () =>
              Navigator.popUntil(context, ModalRoute.withName('/')),
        ),
        FlatButton(
          child: Text("Ok"),
          onPressed: widget.callback,
        )
      ],
    );
  }
}
