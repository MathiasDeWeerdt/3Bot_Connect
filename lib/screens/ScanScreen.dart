import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:threebotlogin_app/main.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanScreen extends StatefulWidget {
  final Widget scanScreen;
  ScanScreen({Key key, this.scanScreen}) : super(key: key);
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController controller;
  int _cameraIndex = 0;
  double offsetTop = -50; 
  @override
  void initState() {
    super.initState();
    _initCamera(_cameraIndex);
  }

  void _initCamera(int index) async {
    controller = CameraController(cameras[index], ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      // _showCameraException(e);
    }

    if (mounted) {
      setState(() {
        _cameraIndex = index;
      });
    }
  }

  // Widget finder() {
  //   return Container(
  //       key: _finder,
  //       child: controller.value.isInitialized
  //           ? AspectRatio(
  //               aspectRatio: controller.value.aspectRatio,
  //               child: CameraPreview(controller))
  //           : Text('Loading camera...'));
  // }

  Widget finder() {
    return Container(
        child: controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: QrCamera(qrCodeCallback: handleCode)
            )
          : Text('Loading camera...')
        );
  }

  Widget helperText() {
    return Container(
      width: double.infinity,
      child: Column(
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
                  'SCAN REGISTRATION QR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28),
                ),
              )),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.all(12),
            child: Text(
              'In order to finish your registration, please scan the QR'
            ),
          )
          
        ],
      ),
    );
  }

  Widget helperTextCard() {
    return Container(
        width: double.infinity,
        child: Card(
            color: Color(0xff0f296a),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    'SCAN REGISTRATION QR',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Text('data')
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      finder(),
      Transform.translate(
        offset: Offset(0.0, offsetTop),
        child: helperText(),
      )
    ]));
  }

  void handleCode(String code) {
    print('--------');
    print(code);
  }
}
