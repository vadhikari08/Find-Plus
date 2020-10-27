import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/utility/constant.dart';
import '../provider/cart.dart';
import '../widgets/card_item.dart';
import '../provider/orders.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum TtsState { playing, stopped, paused, continued }

class CartProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Items'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Spacer(),
                  Chip(
                      backgroundColor: Theme.of(context).accentColor,
                      label: Text(
                        cart.totalAmount.toStringAsFixed(2),
                        style: TextStyle(color: Colors.white),
                      )),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) => CardItem(
              productId: cart.items.keys.toList()[index],
              id: cart.items.values.toList()[index].id,
              price: cart.items.values.toList()[index].price,
              quantity: cart.items.values.toList()[index].quantity,
              title: cart.items.values.toList()[index].title,
            ),
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isloading = false;
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  stt.SpeechToText speech;
  var hasVision = true;
  static const String _place_order_now = 'Do you want to place order now?';
  static const String _search_another_product =
      'Do you want to search another product?';
  String _newVoiceText = _place_order_now;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return FlatButton(
      child: _isloading
          ? CircularProgressIndicator()
          : Text(
              'Order Now',
              style: TextStyle(
                  color: (widget.cart.items.length == 0 || _isloading)
                      ? Colors.grey
                      : Theme.of(context).accentColor),
            ),
      onPressed: (widget.cart.items.length == 0 || _isloading)
          ? null
          : () async {
              Navigator.of(context)
                  .pushReplacementNamed(Constants.placeOrderDetailsRoute,arguments: widget.cart);
/*              setState(() {
                _isloading = true;
              });
              try {
                await Provider.of<Orders>(context, listen: false).addOrders(
                    widget.cart.items.values.toList(), widget.cart.totalAmount);
                scaffold.hideCurrentSnackBar();
                scaffold.showSnackBar(
                    SnackBar(content: Text('Items added to Payment screen')));
                widget.cart.clearCart();
              } catch (error) {
                scaffold.hideCurrentSnackBar();
                scaffold
                    .showSnackBar(SnackBar(content: Text(error.toString())));
              } finally {
                setState(() {
                  _isloading = false;
                });
              }*/
            },
    );
  }

  Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTts();
    speech = stt.SpeechToText();
    initValue();
    // timer = Timer(Duration(seconds: 2), openHomeAgain);
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

  @override
  void dispose() {
    // TODO: implement dispose
    // timer.cancel();
    super.dispose();
  }

  void openHomeAgain() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('vision')) {
      return;
    }
    if (!preferences.getBool("vision")) {
      Navigator.of(context).pushNamed(Constants.homeSCreenRoute);
    }
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
        case _place_order_now:
          if (text.toLowerCase() == "yes") {
            placeOrderNow();
          } else if (text.toLowerCase() == "no") {
            _newVoiceText = _search_another_product;
            _startInstruction();
          }
          break;
        case _search_another_product:
          if (text.toLowerCase() == "yes") {
            openHomeAgain();
          } else if (text.toLowerCase() == "no") {
            //_newVoiceText = _search_another_product;
            SystemNavigator.pop();
            //_startInstruction();
          }
          break;
      }

      result.recognizedWords.toUpperCase().contains(Constants.no.toUpperCase());
    }
  }

  void errorListener(SpeechRecognitionError error) {
    print('error--------------------->$error');
    speech.stop();
    Future.delayed(Duration(seconds: 1), () => _startInstruction());
  }
  
  void placeOrderNow(){
      Navigator.of(context)
                  .pushReplacementNamed(Constants.placeOrderDetailsRoute,arguments: widget.cart);
  }
}
