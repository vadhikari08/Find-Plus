import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/provider/cart.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import '../utility/constant.dart';
import 'app_drawer.dart';
import '../provider/products.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum menu { fav, all }
enum TtsState { playing, stopped, paused, continued }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isfavorite = false;
  bool _callAPI = true;
  bool _isloading = false, _isError = false;
  String errorMessage = 'Some Error';
  bool hasVision;
  String _searchTitle = "";
  String _newVoiceText = 'What are you looking for?';
  TtsState ttsState = TtsState.stopped;
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  stt.SpeechToText speech;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool _startSpeak = false;

  @override
  void initState() {
    super.initState();
    initTts();
    speech = stt.SpeechToText();
    initValue();
    _startInstruction();
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

  void callApi() async {}

  @override
  void didChangeDependencies() {
    if (_callAPI) {
      if (!mounted) return;
      setState(() {
        _isloading = true;
      });

      Provider.of<Products>(context, listen: false)
          .fetchProduct()
          .then((value) {
        if (!mounted) return;
        setState(() {
          _isloading = false;
          _isError = false;
        });
      }).catchError((onError) {
        errorMessage = onError.toString() ?? errorMessage;
        if (!mounted) return;
        setState(() {
          _isloading = false;
          _isError = true;
        });
      });
      _callAPI = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        actions: <Widget>[
          Consumer<Cart>(
            builder: (context, cartData, chd) =>
                Badge(child: chd, value: cartData.getItemCount.toString()),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Constants.cartScreenRoute);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ),
          PopupMenuButton(
            onSelected: (menu value) {
              if (menu.fav == value) {
                setState(() {
                  _isfavorite = true;
                });
              } else {
                setState(() {
                  _isfavorite = false;
                });
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('My Favorites'),
                value: menu.fav,
              ),
              PopupMenuItem(
                child: Text('All Products'),
                value: menu.all,
              )
            ],
            icon: Icon(Icons.more_vert),
          ),
        ],
        title: Text('SHOP FOR YOU'),
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isError
              ? Center(
                  child: Text(errorMessage),
                )
              : ProductGrid(_isfavorite, _searchTitle),
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
        _startInstruction();
        return;
      }
      String text = result.recognizedWords
          .toLowerCase()
          .replaceAll(new RegExp(r"\s+"), "");
      _searchTitle = text;
      setState(() {});
      result.recognizedWords.toUpperCase().contains(Constants.no.toUpperCase());
    }
  }
}
