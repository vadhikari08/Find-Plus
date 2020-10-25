import 'dart:io';

import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/provider/auth.dart';
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
  final _nameController = TextEditingController();
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

  String _newVoiceText = Constants.choose_user_message;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool _startSpeak = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Place Order")),
      body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  _enterName(),
                  SizedBox(height: 10),
                  _enterNumber(),
                  SizedBox(height: 10),
                  _zipCode(),
                  SizedBox(height: 10),
                  _address(),
                  SizedBox(height: 50),
                  _placeOrderButton(),
                  SizedBox(height: 20)
                ],
              ))),
    );
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

  Widget _enterName() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(labelText: 'Name'),
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

  void _placeOrder() {}

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
  //    await speech.listen(onResult: resultListener);
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

  void submitCartProduct() async {}
}
