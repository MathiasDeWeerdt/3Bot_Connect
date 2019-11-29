import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget bottom;
  final double padding;
  final Widget footer;

  const CustomScaffold(
      {Key key,
      @required this.body,
      this.title = '3Bot connect',
      this.bottom,
      this.footer,
      this.padding = 8.0})
      : super(key: key);

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: this.footer == null
                    ? BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24))
                    : BorderRadius.all(
                        Radius.circular(24),
                      ),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(padding),
                    child: body,
                  ),
                ),
              ),
            ),
            footer == null
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: padding),
                    color: Theme.of(context).primaryColor,
                    child: footer,
                  )
          ],
        ),
      ),
    );
  }
}
