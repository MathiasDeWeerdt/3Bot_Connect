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

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> getPermissions(app, scope) async {
    var json = jsonDecode(await getScopePermissions());
    var sc = scope[0];
    return json[app][sc];
  }

  Future<dynamic> changePermission(app, scope, value) async {
    // todo: check if app exists ??
    var json = jsonDecode(await getScopePermissions());
    print(json);
    var sc = scope[0];
    json[app][sc]['enabled'] = value;
    saveScopePermissions(jsonEncode(json));
  }

  Widget scopeList(context, Map<dynamic, dynamic> scope) {
    var keys = scope.keys.toList();
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
          return FutureBuilder(
              future: getPermissions(widget.appId, [keys[index]]),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return SwitchListTile(
                    value: snapshot.data['enabled'],
                    activeColor: (!snapshot.data['required']) ? Theme.of(context).primaryColor : Colors.grey,
                    onChanged: (bool val) {setState(() {
                      if (!snapshot.data['required']) {
                        changePermission(widget.appId, [keys[index]], val);
                      }
                    });},
                    title: Text(
                      keys[index]?.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(val),
                  );
                } else {
                  return new Container();
                }
              },
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
