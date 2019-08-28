import 'package:flutter/material.dart';

class ReuseableTextStep extends StatelessWidget {
  ReuseableTextStep({@required this.titleText, @required this.extraText});

  final String titleText;
  final String extraText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          titleText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 8.5),
            child: ListView(
              children: <Widget>[
                Container(
                  child: Center(
                    child: Text(
                      extraText,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                ),
              ],
            )),
        Divider(
          height: 50,
        ),
      ],
    );
  }
}
