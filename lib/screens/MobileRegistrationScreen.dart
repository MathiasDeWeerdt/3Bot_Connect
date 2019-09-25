import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/widgets/ReusableTextStep.dart';
import 'package:threebotlogin/widgets/ReuseableTextFieldStep.dart';

class MobileRegistrationScreen extends StatefulWidget {
  final String doubleName;

  MobileRegistrationScreen({this.doubleName});
  
  _MobileRegistrationScreenState createState() => _MobileRegistrationScreenState();
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
    logger.log('Attempting to set doubleName');
    if(widget.doubleName != null) {
      logger.log("widget.doubleName: " + widget.doubleName);
      setState(() {
        doubleNameController.text = widget.doubleName; 
      });
    }
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
          var doubleNameValidation =
              validateDoubleName(doubleNameController.text);
          if (doubleNameValidation == null) {
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
              errorStepperText = 'Doublename needs to be alphanumeric';
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
        if (phrase == null || phrase == '') {
          phrase = await generateSeedPhrase();
        }

        break;
      case 2:
        setState(() {
          _index++;
        });
        keys = await generateKeysFromSeedPhrase(phrase);
        break;
      case 3:
        print(_index);
        loadingDialog();
        var response = await finishRegistration(doubleNameController.text,
            emailController.text, 'random', keys['publicKey']);

        print(response.statusCode);
        if (response.statusCode == 200) {
          registrationToPin();
        } else {
          Navigator.popAndPushNamed(context, '/');
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
    return Theme(
      data: Theme.of(context),
      child: Stepper(
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: onStepCancel,
                    child: const Text('RETURN'),
                    color: Colors.grey[200],
                  ),
                  FlatButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      onStepContinue();
                    },
                    child: const Text('CONTINUE'),
                    color: Colors.grey[200],
                  ),
                ],
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
            isActive: _index == 0,
            state: _index >= 0 ? StepState.complete : StepState.disabled,
            title: Text('3Bot'),
            subtitle: Text('Name'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Hi! What is your 3bot name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.5),
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Doublename',
                          suffixText: '.3bot',
                          suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        controller: doubleNameController,
                      ),
                    ),
                    Divider(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Step(
            isActive: _index == 1,
            state: _index >= 1 ? StepState.complete : StepState.disabled,
            title: Text('Email'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextFieldStep(
                  titleText: 'What is your email',
                  labelText: 'email',
                  typeText: TextInputType.emailAddress,
                  controller: emailController,
                ),
              ),
            ),
          ),
          Step(
            isActive: _index == 2,
            state: _index >= 2 ? StepState.complete : StepState.disabled,
            title: Text('Phrase'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextStep(
                  titleText:
                      'Please write this on a piece of paper and keep it in a secure place.',
                  extraText: phrase,
                ),
              ),
            ),
          ),
          Step(
            isActive: _index == 3,
            state: _index >= 3 ? StepState.complete : StepState.disabled,
            title: Text('Finishing'),
            content: Card(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Click on continue to finish registration.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(doubleNameController.text),
                      trailing: Icon(Icons.edit),
                      onTap: () => setState(() {
                        _index = 0;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 15.0),
                    child: ListTile(
                        leading: Icon(Icons.email),
                        title: Text(emailController.text),
                        trailing: Icon(Icons.edit),
                        onTap: () => setState(() {
                              _index = 1;
                            })),
                  ),
                ],
              ),
            ),
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
      ),
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
