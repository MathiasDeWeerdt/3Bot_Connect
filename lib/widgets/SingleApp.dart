import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/AppScreen.dart';

class SingleApp extends StatefulWidget {
  final Map app;
  SingleApp(this.app, {Key key}) : super(key: key);

  _SingleAppState createState() => _SingleAppState();
}

class _SingleAppState extends State<SingleApp> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: double.infinity,
      // padding: EdgeInsets.all(50),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: RawMaterialButton(
        child: Container(
          width: 0.7 * size.width,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/" + widget.app['bg']),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.hue)
            ),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            boxShadow: [
              new BoxShadow(
                  color: Colors.black, offset: Offset(1, 1), blurRadius: 2.0)
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(widget.app['name'], style: TextStyle(color: Colors.white, fontSize: 20,),textAlign: TextAlign.center,),
              SizedBox(height: 10,),
              Text(widget.app['subheading'], style: TextStyle(color: Colors.white, fontSize: 13,),textAlign: TextAlign.center,),
            ],
          ),
        ),
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => AppScreen(widget.app)));
        },
      ),
    );
  }
}
