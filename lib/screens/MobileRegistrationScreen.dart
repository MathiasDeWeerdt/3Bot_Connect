// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/widgets/ReusableTextStep.dart';
import 'package:threebotlogin/widgets/ReuseableTextFieldStep.dart';

class MobileRegistrationScreen extends StatefulWidget {
  @override
  _MobileRegistrationScreenState createState() =>
      _MobileRegistrationScreenState();
}

class _MobileRegistrationScreenState extends State<MobileRegistrationScreen> {
  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();

  int _index;
  bool isVisible = false;
  String phrase = '';
  String doubleName;

  String errorStepperText;

  Map<String, String> keys;

  @override
  void initState() {
    _index = 0;
    errorStepperText = '';
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  checkStep(currentStep) async {
    switch (currentStep) {
      case 0:
        var userKInfoResult;
        loadingDialog();
        if (doubleNameController.text != null ||
            doubleNameController.text != '') {
          doubleName = doubleNameController.text + '.3bot';
          userKInfoResult = await getUserInfo(doubleName);
          if (userKInfoResult.statusCode != 200) {
            setState(() {
              _index++;
            });
          } else {
            setState(() {
              errorStepperText = 'User exists already';
            });
          }
        } else {
          setState(() {
            errorStepperText = 'Doublename can\'t be empty';
          });
        }
        Navigator.pop(context);
        break;
      case 1:
        print(_index.toString() + "wtf");
        var emailValidation = validateEmail(emailController.text);
        setState(() {
          loadingDialog();
          if (emailValidation == null) {
            _index++;
          } else {
            errorStepperText = emailValidation;
          }
          Navigator.pop(context);
        });

        phrase = await generateSeedPhrase();
        break;
      case 2:
        setState(() {
          _index++;
        });
        keys = await getFromSeedPhrase(phrase);
        break;
      case 3:
        print(_index);
        loadingDialog();
        var response = await finishRegistration(doubleNameController.text,
            emailController.text, 'random', keys['publicKey']);
        if (response.statusCode == 200) {
          registrationToPin();
        } else {
          Navigator.popAndPushNamed(context, '/');
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Something went wrong')));
        }
        break;
      default:
        print('Whatcha doing here');
        break;
    }
  }

  void registrationToPin() async {
    updateDeviceId(await messaging.getToken(), doubleName, keys['privateKey']);

    var registrationData = {
      "privateKey": keys['privateKey'],
      "doubleName": doubleNameController.text + '.3bot',
      "emailVerified": false,
      "email": emailController.text,
      "phrase": phrase,
    };

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegistrationWithoutScanScreen(
                registrationData,
                resetPin: true)));
  }

  loadingDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                new CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                new Text("Loading"),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
    );
  }

  Widget registrationStepper() {
    return Stepper(
      controlsBuilder: (BuildContext context,
          {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
        return Row(
          children: <Widget>[
            FlatButton(
              onPressed: onStepContinue,
              child: const Text('CONTINUE'),
            ),
            FlatButton(
              onPressed: onStepCancel,
              child: const Text('CANCEL'),
            ),
            Text(
              errorStepperText,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.right,
            )
          ],
        );
      },
      type: StepperType.horizontal,
      steps: [
        Step(
          title: Text('3Bot'),
          subtitle: Text('Name'),
          content: ReuseableTextFieldStep(
            titleText: 'Hi! What is your 3bot name',
            labelText: 'Doublename',
            typeText: TextInputType.text,
            controller: doubleNameController,
            suffixText: '.3bot',
          ),
        ),
        Step(
          title: Text('Email'),
          content: ReuseableTextFieldStep(
            titleText: 'What is your email',
            labelText: 'email',
            typeText: TextInputType.emailAddress,
            controller: emailController,
          ),
        ),
        Step(
          title: Text('Phrase'),
          content: ReuseableTextStep(
            titleText:
                'Please write this on a piece of paper and keep it in a secure place.',
            extraText: phrase,
          ),
        ),
        Step(
          title: Text('Finishing'),
          content: ReuseableTextStep(
              titleText: 'You are almost there',
              extraText: 'Click on continue to finish registration'),
        )
      ],
      currentStep: _index,
      onStepContinue: () {
        errorStepperText = '';
        checkStep(_index);
      },
      onStepCancel: () {
        setState(
          () {
            errorStepperText = '';
            if (_index > 0) {
              _index--;
            } else {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
        backgroundColor: Color(0xFF0f296a),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                child: registrationStepper(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
