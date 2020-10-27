import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/utility/constant.dart';

import '../provider/auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final bool _vision = ModalRoute.of(context).settings.arguments ?? true;

    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.6),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.5],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      /* transform: Matrix4.rotationZ(-20 * pi / 180)
                        ..translate(-10.0),*/
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'FIND PLUS',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.subtitle1.color,
                          fontSize: 30,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TtsState { playing, stopped, paused, continued }

class AuthCard extends StatefulWidget {
  const AuthCard({Key key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'firstName': '',
    'lastName': '',
    'number': '',
  };
  AnimationController _controller;
  Animation<Size> _heightAnimation;
  Animation<double> _opacityAnimation;
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  stt.SpeechToText speech;
  String email;
  String password;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool hasVision = false;
  static const String _tellPassword = "Tell your password?";
  static const String _tellConfirmPassword = "Tell your password again?";
  static const String _tellEmail = "Tell your username";
  String _newVoiceText = 'Are you a new user?';
  static const String _areYouANewUser = 'Are you a new user?';
  static const String _tellFirstName = ' Tell your first name?.';
  static const String _tellLastName = 'Tell your last name?';
  static const String _tellNumber = 'Tell your Number?';
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool _startSpeak = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _heightAnimation = Tween(
            begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _heightAnimation.addListener(() {
      setState(() {});
    });
    getUserType();
    initTts();
    speech = stt.SpeechToText();
    initValue();
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        _getEngines();
      }
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
      _startSpeaking();
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (kIsWeb || Platform.isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  void initValue() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('vision')) {
      hasVision = true;
      return;
    }
    print('value of vision is ${preferences.getBool("vision")}');
    hasVision = preferences.getBool('vision');
    if (!hasVision) _startInstruction();
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
    for (dynamic type in languages) {
      print('types are $type');
    }
  }

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _startInstruction() async {
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    bool englishLang = await flutterTts.isLanguageAvailable("en-AU");
    if (englishLang) {
      await flutterTts.setLanguage("en-AU");
    } else {
      await flutterTts.setLanguage("en-US");
    }

    if (_newVoiceText != null) {
      print(
          "dfasdfaslkdfjaslk dfashkldjf ahlsdkf h--------------------->hello");

      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) {
          setState(() => ttsState = TtsState.playing);
        }
      }
    }
  }

  Future _startSpeaking() async {
    print('hello ----------------------------------->');

    bool available = await speech.initialize(
        onStatus: statusListener, onError: errorListener);
    if (available) {
      await speech.listen(onResult: resultListener);
    } else {
      speech.stop();
    }
// some time later...
  }

  void statusListener(String status) {
    print('status--------------------->$status');
  }

  void errorListener(SpeechRecognitionError error) {
    print('error--------------------->$error');
    speech.stop();
  }

  void resultListener(SpeechRecognitionResult result) async {
    print(result.recognizedWords.toString());
    if (result.confidence > 0 && result.finalResult == true) {
      if (result.recognizedWords != null && result.recognizedWords.isEmpty) {
        _newVoiceText = Constants.unable_to_choose_yes_and_no;
        //_startInstruction();
        return;
      }
      String text = result.recognizedWords
          .toLowerCase()
          .replaceAll(new RegExp(r"\s+"), "");
      switch (_newVoiceText) {
        case _areYouANewUser:
          if (text.toLowerCase() == "yes") {
            _switchAuthMode();
            _newVoiceText = _tellEmail;
            _startInstruction();
          } else if (text.toLowerCase() == 'no') {
            _newVoiceText = _tellEmail;
            _startInstruction();
          }
          break;
        case _tellEmail:
          if (_authMode == AuthMode.Login) {
            _emailController.text = text;
            setState(() {});
            _newVoiceText = _tellPassword;
            _startInstruction();
          } else {
            _emailController.text = text;
            setState(() {});
            _newVoiceText = _tellFirstName;
            _startInstruction();
          }
          break;
        case _tellPassword:
          _passwordController.text = text;
          setState(() {});
          _newVoiceText = _tellPassword;
          if (_authMode == AuthMode.Login) {
            _submit();
          } else {
            _newVoiceText = _tellConfirmPassword;
            _startInstruction();
          }
          break;
        case _tellConfirmPassword:
          _confirmPasswordController.text = text;
          setState(() {});
          _submit();
          break;

        case _tellFirstName:
          _firstNameController.text = text;
          setState(() {});
          _newVoiceText = _tellLastName;
          _startInstruction();
          break;
        case _tellLastName:
          _lastNameController.text = text;
          setState(() {});
          _newVoiceText = _tellNumber;
          _startInstruction();
          break;
        case _tellNumber:
          _phoneController.text = text;
          setState(() {});
          _newVoiceText = _tellPassword;
          _startInstruction();
          break;
      }
/*      if (_newVoiceText == _tellEmail) {
        _emailController.text = text;
        setState(() {});
        _newVoiceText = _tellPassword;
        _startInstruction();
      } else if (_newVoiceText == _tellPassword) {
        _passwordController.text = text;
        setState(() {});
        _newVoiceText = _tellPassword;
        if (_authMode == AuthMode.Login) {
          _submit();
        } else {
          _newVoiceText = _tellConfirmPassword;
          _startInstruction();
        }
      } else if (_newVoiceText == _areYouANewUser) {
        if (text.toLowerCase() == "yes") {
          _switchAuthMode();
          _newVoiceText = _tellEmail;
          _startInstruction();
        } else if (text.toLowerCase() == 'no') {
          _newVoiceText = _tellEmail;
          _startInstruction();
        }
      }*/

      result.recognizedWords.toUpperCase().contains(Constants.no.toUpperCase());
    }
  }

  void getUserType() async {}

  var _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .signIn(_authData['email']+'test.com', _authData['password']);
        /* if(Provider.of<Auth>(context).isAuth){
          Navigator.of(context).pushReplacementNamed(Constants.homeSCreenRoute);
        }*/
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signUp(
            _authData['email']+'test.com',
            _authData['password'],
            _authData['firstName'],
            _authData['lastName'],
            _authData['number']);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication Fail';
      final message = error.toString();
      print(message);
      if (message.contains('EMAIL_EXISTS')) {
        errorMessage = 'The Email address is already in use';
      } else if (message.contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email';
      } else if (message.contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (message.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'This user is not found';
      } else if (message.contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'Could not authenticate you.Please try again later';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error Occur'),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop())
            ],
          );
        });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        curve: Curves.linear,
        duration: Duration(milliseconds: 400),
        height: _authMode == AuthMode.Signup ? 320 : 260,
        // height: _heightAnimation.value.height,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Username'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                _authMode == AuthMode.Signup
                    ? TextFormField(
                        decoration: InputDecoration(labelText: 'First Name'),
                        controller: _firstNameController,
                        onSaved: (value) {
                          _authData['firstName'] = value;
                        },
                      )
                    : SizedBox(),
                _authMode == AuthMode.Signup
                    ? TextFormField(
                        decoration: InputDecoration(labelText: 'Last Name'),
                        controller: _lastNameController,
                        onSaved: (value) {
                          _authData['lastName'] = value;
                        },
                      )
                    : SizedBox(),
                _authMode == AuthMode.Signup
                    ? TextFormField(
                        decoration: InputDecoration(labelText: 'Phone Number'),
                        controller: _phoneController,
                        onSaved: (value) {
                          _authData['number'] = value;
                        },
                      )
                    : SizedBox(),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                // if (_authMode == AuthMode.Signup)
                AnimatedContainer(
                  height: _authMode == AuthMode.Signup ? 60 : 0,
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0),
                  duration: Duration(milliseconds: 300),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      controller: _confirmPasswordController,
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
