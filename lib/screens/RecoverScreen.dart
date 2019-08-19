import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'RegistrationWithoutScanScreen.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;
  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final seedPhrasecontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  bool emailVerified = false;

  String doubleName = '';
  String emailFromForm = '';
  String seedPhrase = '';

  String error = '';

  String privateKey;

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

// TODO: @MathiasDeWeerdt Double check this
  checkEmail(doubleName, emailFromForm) async {
    var emailVerificationResponse = await checkVerificationStatus(doubleName);
    logger.log(emailVerificationResponse);
    if (emailVerificationResponse.statusCode != 200) {
      throw new Exception('Email does not exist');
    } else {
      var response = jsonDecode(emailVerificationResponse.body);
      String emailFormHashed = generateMd5(emailFromForm);
      String emailHashKyc = response['email'];

      if (emailFormHashed != emailHashKyc) {
        throw new Exception('Email does not correspond with doublename');
      }

      if (response['verified'] == 1) {
        setState(() {
          emailVerified = true;
        });
      }
    }
  }

  checkSeedPhrase(doubleName, seedPhrase) async {
    checkSeedLength(seedPhrase);
    var keys = await getFromSeedPhrase(seedPhrase);

    setState(() {
      privateKey = keys['privateKey'];
    });

    var userKInfoResult = await getUserInfo(doubleName);

    if (userKInfoResult.statusCode != 200) {
      throw new Exception('User not found');
    }

    var body = json.decode(userKInfoResult.body);

    if (body['publicKey'] != keys['publicKey']) {
      throw new Exception('Keys do not correspond to given user');
    }
  }

  continueRecoverAccount() async {
    updateDeviceId(await messaging.getToken(), doubleName, privateKey)
        .then((onValue) {
      logger.log(onValue);
    }).catchError((e) {
      logger.log(e);
    });

    var registrationData = {
      "privateKey": privateKey,
      "doubleName": doubleName,
      "emailVerified": emailVerified,
      "email": emailFromForm,
      "phrase": seedPhrase,
    };

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegistrationWithoutScanScreen(
                registrationData,
                resetPin: true)));
  }

  checkSeedLength(seedPhrase) {
    int seedLength = seedPhrase.split(" ").length;
    if (seedLength <= 23) {
      throw new Exception('Seed phrase is too short');
    } else if (seedLength > 24) {
      throw new Exception('Seed phrase is too long');
    }
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    doubleNameController.dispose();
    emailController.dispose();
    seedPhrasecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recover Account'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Container(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: recoverForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget recoverForm() {
    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Please insert your info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Doublename',
                    suffixText: '.3bot',
                    suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  controller: doubleNameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter your Doublename';
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Email'),
                validator: validateEmail,
                controller: emailController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Phrase'),
                controller: seedPhrasecontroller,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter your Seedphrase';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            RaisedButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                'Recover Account',
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                showDialog(
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
                setState(() {
                  error = '';
                });
                FocusScope.of(context).requestFocus(new FocusNode());
                setState(() {
                  _autoValidate = true;
                  doubleName = doubleNameController.text + '.3bot';
                  emailFromForm = emailController.text;
                  seedPhrase = seedPhrasecontroller.text;
                });
                try {
                  await checkSeedPhrase(doubleName, seedPhrase);
                  await checkEmail(doubleName, (emailFromForm.toLowerCase()));
                  Navigator.pop(context);
                  await continueRecoverAccount();
                } catch (e) {
                  Navigator.pop(context);
                  logger.log(e);
                  setState(() {
                    error = e.message;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
