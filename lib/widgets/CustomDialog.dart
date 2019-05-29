import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomDialog extends StatelessWidget {
  final Widget description, btn;
  final String title;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.btn,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[card(context), circularImage(context)],
    );
  }

  circularImage(context) {
    return Positioned(
      left: Consts.padding,
      right: Consts.padding,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: Consts.avatarRadius,
        child: Icon(
          Icons.person,
          size: 42.0,
          color: Colors.white,
        ),
      ),
    );
  }

  card(context) {
    return Container(
      padding: EdgeInsets.only(
        top: Consts.avatarRadius + Consts.padding,
        bottom: Consts.padding,
        left: Consts.padding,
        right: Consts.padding,
      ),
      margin: EdgeInsets.only(top: Consts.avatarRadius),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(Consts.padding),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Text(title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,),
          SizedBox(height: 16.0),
          description,
          SizedBox(height: 24.0),
          Align(
            alignment: Alignment.bottomRight,
            child: btn,
          ),
        ],
      ),
    );
  }
}

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 30.0;
}
