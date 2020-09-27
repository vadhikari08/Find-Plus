import 'dart:async';
import 'dart:io' show Platform;

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/utility/constant.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChooseUserScreen extends StatefulWidget {
  @override
  _ChooseUserScreenState createState() => _ChooseUserScreenState();
}

enum TtsState { playing, stopped, paused, continued }

class _ChooseUserScreenState extends State<ChooseUserScreen> {
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  stt.SpeechToText speech;

  String _newVoiceText = Constants.choose_user_message;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool _startSpeak = false;

  bool _repeat = false;

  @override
  initState() {
    super.initState();
    initTts();
    speech = stt.SpeechToText();
    _startInstruction();
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

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  Future _startSpeaking() async {
    print('hello ----------------------------------->');

    bool available = await speech.initialize(
        onStatus: statusListener, onError: errorListener);
    if (available) {
      await speech.listen(onResult: resultListener);
    } else {
      speech.stop();
      print('---------------> not speeching');
      print("The user has denied the use of speech recognition.");
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

  void resultListener(SpeechRecognitionResult result) async{
    print(result.recognizedWords.toString());
    if (result.confidence > 0 && result.finalResult == true) {
      if (result.recognizedWords != null && result.recognizedWords.isEmpty) {
        _newVoiceText = Constants.unable_to_choose_yes_and_no;
        //_startInstruction();
        return;
      }
      final preferences = await SharedPreferences.getInstance();

      if (result.recognizedWords
          .toUpperCase()
          .contains(Constants.no.toUpperCase())) {
        preferences.setBool('vision', true);
        Navigator.of(context).pushReplacementNamed(Constants.authRoute);
      } else if (result.recognizedWords
          .toUpperCase()
          .contains(Constants.yes.toUpperCase())) {
        preferences.setBool('vision', false);
        Navigator.of(context).pushReplacementNamed(Constants.authRoute);      } else {
        _newVoiceText = Constants.unable_to_choose_yes_and_no;
        // _startInstruction();
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (dynamic type in languages) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: SafeArea(
          child: Container(
              child: _startSpeak
                  ? Center(
                      child: _recordingIcon(),
                    )
                  : Center(child: _recordingDisableIcon())),
        )));
  }

  TextStyle messageTextStyle = TextStyle(fontSize: 20, color: Colors.grey);

  Widget _userTypeNotBlind() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          Constants.user_with_no_visual_impairment,
          textAlign: TextAlign.center,
          style: messageTextStyle,
        )
      ],
    );
  }

  Widget _recordingIcon() {
    return AvatarGlow(
      duration: Duration(milliseconds: 2000),
      endRadius: MediaQuery.of(context).size.width / 2,
      repeatPauseDuration: Duration(milliseconds: 100),
      showTwoGlows: false,
      repeat: false,
      curve: Curves.ease,
      glowColor: Colors.red,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.grey[400], spreadRadius: 5)
          ],
        ),
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
          padding: EdgeInsets.all(0),
          color: Colors.red,
          onPressed: /*ttsState == TtsState.stopped ? _startSpeaking : */ null,
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.width / 2,
            child: Icon(
              Icons.mic,
              size: MediaQuery.of(context).size.width / 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _recordingDisableIcon() {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
      padding: EdgeInsets.all(0),
      color: Colors.red,
      onPressed: ttsState == TtsState.stopped
          ? () {
              _startSpeaking();
            }
          : null,
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.width / 2,
        child: Icon(
          Icons.mic,
          size: MediaQuery.of(context).size.width / 2,
          color: Colors.white,
        ),
      ),
    );
  }
}
