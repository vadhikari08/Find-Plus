import 'dart:io';

import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/User.dart';
import 'package:shop_app/provider/auth.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:shop_app/provider/orders.dart';
import 'package:shop_app/provider/product.dart';
import 'package:shop_app/provider/products.dart';
import 'package:shop_app/utility/constant.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum TtsState { playing, stopped, paused, continued }

class PlaceOrderDetails extends StatefulWidget {
  @override
  _PlaceOrderDetailsState createState() => _PlaceOrderDetailsState();
}

class _PlaceOrderDetailsState extends State<PlaceOrderDetails> {
  final _nameFirstController = TextEditingController();
  final _nameLastController = TextEditingController();
  final _cvvNumberController = TextEditingController();
  final _cardNumberController = TextEditingController();

  final _numberController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _addressController = TextEditingController();
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 1.0;
  stt.SpeechToText speech;

  static const _tellTheDetails = "Tell the Following Details";
  static const String _tellFirstName = ' Tell your first name?';
  static const String _tellLastName = 'Tell your last name?';
  static const String _tellNumber = 'Tell your Number?';
  static const String _tellAddress = 'Tell your Address?';
  static const String _tellPinCode = "Tell your Pin Code";
  static const String _tellCardNumber = 'Tell your Card Number?';
  static const String _tellCVVNumber = 'Tell your CVV Number>';
  static const String _tellOrderPlaced =
      'Your Order is placed. Seller will call you shortly';
    Cart cart=null;
  String _newVoiceText = _tellTheDetails;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;
  bool hasVision = false;

  bool _startSpeak = false;

  User user = null;

  @override
  Widget build(BuildContext context) {
     cart= ModalRoute.of(context).settings.arguments as Cart;
    return Scaffold(
      appBar: AppBar(title: Text("Place Order")),
      body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  _enterFirstName(),
                  SizedBox(height: 10),
                  _enterLastName(),
                  SizedBox(height: 10),
                  _enterNumber(),
                  SizedBox(height: 10),
                  _zipCode(),
                  SizedBox(height: 10),
                  _address(),
                  SizedBox(height: 10),
                  _CardNumber(),
                  SizedBox(height: 10),
                  _CardCVVNumber(),
                  SizedBox(height: 50),
                  _placeOrderButton(),
                  SizedBox(height: 20)
                ],
              ))),
    );
  }

  @override
  @override
  void initState() {
    super.initState();
    initTts();
    speech = stt.SpeechToText();
    placeOrder();
  }

  void placeOrder() async {
    // user = await Provider.of<Products>(context).fetchUserDetail();
    // if (user != null) {
    //   if (user.firstName != null && user.firstName.isNotEmpty)
    //     _nameFirstController.text = user.firstName;

    //   if (user.lastName != null && user.lastName.isNotEmpty)
    //     _nameLastController.text = user.lastName;

    //   if (user.number != null && user.number.isNotEmpty)
    //     _numberController.text = user.number;

    //     setState(() {});
    // }
    
    initValue();
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
      if (_newVoiceText == _tellTheDetails) {
        if (user != null) {
          if (user.firstName.isEmpty) {
            _newVoiceText = _tellFirstName;
          } else if (user.lastName.isEmpty) {
            _newVoiceText = _tellLastName;
          } else if (user.number.isEmpty) {
            _newVoiceText = _tellNumber;
          } else {
            _newVoiceText = _tellPinCode;
          }
          _startInstruction();
        } else {
          _newVoiceText = _tellFirstName;
          _startInstruction();
        }
      } else if (_newVoiceText == _tellOrderPlaced) {
        Navigator.of(context).pushReplacementNamed(Constants.homeSCreenRoute);
      } else {
        _startSpeaking();
      }
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

  void placeOrderAPI() async {
    try {
      await Provider.of<Orders>(context, listen: false).addOrders(
          cart.items.values.toList(), cart.totalAmount);
          SystemNavigator.pop();
    } catch (error) {
    }
  }

  Widget _enterFirstName() {
    return TextFormField(
      controller: _nameFirstController,
      decoration: InputDecoration(labelText: 'First Name'),
      keyboardType: TextInputType.name,
    );
  }

  Widget _enterLastName() {
    return TextFormField(
      controller: _nameLastController,
      decoration: InputDecoration(labelText: 'Last Name'),
      keyboardType: TextInputType.name,
    );
  }

  Widget _placeOrderButton() {
    return RaisedButton(
      child: Text('Place Order'),
      onPressed: _placeOrder,
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: Colors.white,
    );
  }

  void _placeOrder() async{
    try {
      await Provider.of<Orders>(context, listen: false).addOrders(
          cart.items.values.toList(), cart.totalAmount);
         Navigator.of(context).pushReplacementNamed(Constants.orderScreenRoute);
    } catch (error) {
    }
  }

  Widget _enterNumber() {
    return TextFormField(
      controller: _numberController,
      decoration: InputDecoration(labelText: 'Phone Number'),
      keyboardType: TextInputType.number,
    );
  }

  Widget _zipCode() {
    return TextFormField(
        controller: _zipCodeController,
        decoration: InputDecoration(labelText: 'Zip Code'),
        keyboardType: TextInputType.number);
  }

  Widget _CardNumber() {
    return TextFormField(
        controller: _cardNumberController,
        decoration: InputDecoration(labelText: 'Card Number'),
        keyboardType: TextInputType.number);
  }

  Widget _CardCVVNumber() {
    return TextFormField(
        controller: _cvvNumberController,
        decoration: InputDecoration(labelText: 'CVV Number'),
        keyboardType: TextInputType.number);
  }

  Widget _address() {
    return TextFormField(
        controller: _addressController,
        decoration: InputDecoration(labelText: 'Address'),
        keyboardType: TextInputType.streetAddress);
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
    print('start Instruction is called');
    bool hasVision;
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('vision')) {
      hasVision = true;
      return;
    }
    print('value of vision is ${preferences.getBool("vision")}');
    hasVision = preferences.getBool('vision');
    if (hasVision) return;
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
    Future.delayed(Duration(seconds: 1), () => _startInstruction());
  }

  void resultListener(SpeechRecognitionResult result) async {
    print(result.recognizedWords.toString());
    if (result.confidence > 0 && result.finalResult == true) {
      if (result.recognizedWords != null && result.recognizedWords.isEmpty) {
        _newVoiceText = Constants.unable_to_choose_yes_and_no;
        //_startInstruction();
        return;
      }
      String text = result.recognizedWords;
      switch (_newVoiceText) {
        case _tellFirstName:
          _nameFirstController.text = text;
          _newVoiceText = _tellLastName;
          setState(() {});
          _startInstruction();
          break;
        case _tellLastName:
          _nameLastController.text = text;
          _newVoiceText = _tellNumber;
          setState(() {});
          _startInstruction();
          break;
        case _tellNumber:
          _numberController.text = text;
          _newVoiceText = _tellPinCode;
          setState(() {});
          _startInstruction();
          break;
        case _tellPinCode:
          _zipCodeController.text = text;
          _newVoiceText = _tellAddress;
          setState(() {});
          _startInstruction();
          break;
        case _tellAddress:
          _addressController.text = text;
          _newVoiceText = _tellCardNumber;
          setState(() {});
          _startInstruction();
          break;
        case _tellCardNumber:
          _cardNumberController.text = text;
          _newVoiceText = _tellCVVNumber;
          setState(() {});
          _startInstruction();
          break;
        case _tellCVVNumber:
          _cvvNumberController.text = text;
          _newVoiceText = _tellOrderPlaced;
          setState(() {});
          _startInstruction();
      }

      result.recognizedWords.toUpperCase().contains(Constants.no.toUpperCase());
    }
  }

  void submitCartProduct() async {}
}
