import 'package:flutter/material.dart';

class ReuseableTextFieldStep extends StatelessWidget {
  ReuseableTextFieldStep(
      {@required this.titleText,
      @required this.labelText,
      @required this.controller,
      @required this.typeText,
      this.suffixText});

  final String titleText;
  final String labelText;
  final TextEditingController controller;
  final String suffixText;
  final TextInputType typeText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          titleText,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: TextField(
            keyboardType: typeText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: labelText,
              suffixText: suffixText,
              suffixStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            controller: controller,
          ),
        ),
        Divider(
          height: 50,
        ),
      ],
    );
  }
}
