import 'dart:ui';

import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/main.dart';

class Scanner extends StatefulWidget {
  final Widget scanner;
  final callback;
  final context;

  Scanner({Key key, this.scanner, this.callback, this.context})
      : super(key: key);

  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> with TickerProviderStateMixin {
  QRReaderController controller;
  AnimationController animationController;
  Animation<double> verticalPosition;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      duration: new Duration(seconds: 1),
      vsync: this,
    );
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
    animationController.addListener(() {
      this.setState(() {});
    });
    onNewCameraSelected(cameras[0]);
  }

  Widget finder() {
    var w = MediaQuery.of(widget.context).size.width;
    var h = MediaQuery.of(widget.context).size.height;
    return Container(
      width: w,
      height: h,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: controller.value.isInitialized && controller != null
                ? Container(
                    width: w / controller.value.aspectRatio,
                    height: h,
                    child: QRReaderPreview(controller),
                  )
                : Container(
                    color: Colors.black,
                    child: SizedBox(
                      height: h,
                      width: w,
                    ),
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
        animationController.isAnimating
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
                child: new AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  decoration:
                      new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              ),
      ],
    );
  }

  Future onCodeRead(dynamic value) async {
    HapticFeedback.mediumImpact();
    animationController.stop();
    controller.stopScanning();
    
    widget.callback(value);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    bool initiated = false;
    if (controller != null) {
      await controller.dispose();
    }
    controller = new QRReaderController(cameraDescription, ResolutionPreset.low, [CodeFormat.qr, CodeFormat.pdf417], onCodeRead);
    controller.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await controller.initialize();
      initiated = true;
    } on Exception catch (e) {
      print('-------------------------------------------------------------');
      print('-------------------------------------------------------------');
      print(e);
      print('-------------------------------------------------------------');
      print('-------------------------------------------------------------');
    }

    if (mounted && initiated) {
      setState(() {});
      controller.startScanning();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[finder(), finderx()],
    );
  }
}