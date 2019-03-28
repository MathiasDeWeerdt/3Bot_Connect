import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:threebotlogin_app/main.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:threebotlogin_app/screens/HomeScreen.Dart';
import 'package:threebotlogin_app/widgets/PinField.dart';
import 'package:threebotlogin_app/services/userService.dart';
import 'package:threebotlogin_app/services/connectionService.dart';
import 'package:threebotlogin_app/services/cryptoService.dart';
class ScanScreen extends StatefulWidget {
  final Widget scanScreen;
  ScanScreen({Key key, this.scanScreen}) : super(key: key);
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  QRReaderController controller;
  AnimationController animationController;
  Animation<double> verticalPosition;
  AnimationController sliderAnimationController;
  Animation<double> offset;
  String qrData = '';
  String pin;
  String helperText = "In order to finish registration, scan QR code";


  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
      duration: new Duration(seconds: 1),
      vsync: this,
    );
    animationController.addListener(() {
      this.setState(() {});
    });
    sliderAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    sliderAnimationController.addListener(() {
      this.setState(() {});
    });
    offset = Tween<double>(begin: 0.0, end: 500.0).animate(CurvedAnimation(
        parent: sliderAnimationController, curve: Curves.bounceOut));

    animationController.forward();
    verticalPosition = Tween<double>(begin: 10.0, end: 200.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear))
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          animationController.reverse();
        } else if (state == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
    onNewCameraSelected(cameras[0]);
  }
  Widget finder () {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Container(
    width: w,
    height: MediaQuery.of(context).size.height,
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: Container(
            width: w  / controller.value.aspectRatio,
            height: h,
            child: QRReaderPreview(controller), // this is my CameraPreview
          ),
        ),
      ),
    ),
  );
  }

  Widget finderx() {
    return Stack(
      alignment: FractionalOffset.topCenter,
      children: <Widget>[
        finder(),
        qrData == ''
            ? Center(
                child: Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 100),
                child: Stack(
                  children: <Widget>[
                    SizedBox(
                      height: 200.0,
                      width: 300.0,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2.0)),
                      ),
                    ),
                    Positioned(
                      top: verticalPosition.value,
                      child: Container(
                        width: 300.0,
                        height: 2.0,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ))
            : BackdropFilter(
                child: new Container(
                  decoration:
                      new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              ),
      ],
    );
  }

  Widget content() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff0f296a),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              padding: EdgeInsets.only(top: 12.0, bottom: 12),
              width: double.infinity,
              child: Text(
                'REGISTRATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
              ),
            )),
        Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  child: Center(child: Text(helperText))
                ),
                SizedBox(
                  height: offset.value,
                  width: double.infinity,
                  child: PinField(callback: (p) => pinFilledIn(p)),
                ),
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      finderx(),
      Align(
        // alignment: Alignment(0, MediaQuery.of(context).size.width * controller.value.aspectRatio),
        alignment: Alignment.bottomCenter,
        child: content()
      )
    ]));
  }

  Future pinFilledIn(String value) async {
    if (pin == null) {
      setState(() {
        pin = value;
        helperText = 'Confirm pin';
      });
    } else if (pin != value){
      setState(() {
        pin = null;
        helperText = 'Pins do not match, choose pin';
      });
    } else if (pin ==value) {
      var hash = jsonDecode(qrData)['hash'];
      savePin(pin);
      savePrivateKey(jsonDecode(qrData)['privateKey']);
      var signedHash = signHash(hash);
      sendSignedHash(hash, await signedHash);
      Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  void onCodeRead(dynamic value) {
    setState(() {
      qrData = value;
      helperText = "Choose new pin";
    });
    animationController.stop();
    sliderAnimationController.forward();
    controller.stopScanning();
    sendScannedFlag(jsonDecode(qrData)['hash']);

  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new QRReaderController(cameraDescription, ResolutionPreset.low,
        [CodeFormat.qr, CodeFormat.pdf417], onCodeRead);

    try {
      await controller.initialize();
      controller.startScanning();
    } on QRReaderException catch (e) {}
  }
}
