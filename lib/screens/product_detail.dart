import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/utility/categories.dart';
import 'package:shop_app/utility/constant.dart';
import '../provider/products.dart';
import 'package:shop_app/provider/product.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum TtsState { playing, stopped, paused, continued }

class ProductDetailScreen extends StatefulWidget {
  ProductDetailScreen();

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _newVoiceText = '';
  String productionDetails = 'Product Details :';
  String productionAdded =
      'Product is added to cart. Seller will call you shortly.';
  String addProductSpeech = "You do want to add this product in cart?";
  TtsState ttsState = TtsState.stopped;
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  stt.SpeechToText speech;
  bool _startedInstruction = false;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool _startSpeak = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTts();
  }

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<Products>(context, listen: false)
        .productFindById(productId: productId);
    productionDetails = productionDetails +
        " product name is ${product.title}. Color of product is ${product.color}. Product price is ${product.price} dollars. Do you want to hear details again?";
    if (!_startedInstruction) {
      _startedInstruction = true;
      _newVoiceText = productionDetails;
      Future.delayed(Duration(milliseconds: 400), () => _startInstruction());
    }
    productionDetails = productionDetails + "";
    return Scaffold(
      /*  appBar: AppBar(
        title: Text("${product.title}"),
      ), */
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            floating: true,
            // title: Text("${product.title}"),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              title: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text("${product.title}",
                    /* style: TextStyle(
                        backgroundColor: Colors.black54, color: Colors.white), */
                    overflow: TextOverflow.ellipsis),
              ),
              background: Hero(
                tag: productId,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: 10),
            _productCategory(product),
            _productPrice(product),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Description',
                softWrap: true,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            _productColor(product),
            product.productCategory == AllCategory.prod_category_clothing_id
                ? Column(
                    children: [_productGender(product), _productSize(product)])
                : SizedBox(),
            _productDescription(product),
            SizedBox(height: 300),
          ]))
        ],
      ),
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

  Padding _productSize(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Size :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.size}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productGender(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Gender :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.gender}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productCategory(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Product Category :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.productCategory}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productColor(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Color :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.color}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productDescription(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${product.description}',
        softWrap: true,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
      ),
    );
  }

  Padding _productPrice(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Price :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '\$${product.price}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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
        _newVoiceText = Constants.unable_to_choose_yes_and_no;
        _startInstruction();
        return;
      }
      if (result.recognizedWords
          .toUpperCase()
          .contains(Constants.no.toUpperCase())) {
        if (_newVoiceText != addProductSpeech) {
          _newVoiceText = addProductSpeech;
          _startInstruction();
        } else {
          Navigator.of(context).pop();
        }
      } else if (result.recognizedWords
          .toUpperCase()
          .contains(Constants.yes.toUpperCase())) {
        if (_newVoiceText != addProductSpeech)
          _startInstruction();
        else {
          _newVoiceText = productionAdded;
          _startInstruction();
        }
      } else {
        _newVoiceText = Constants.unable_to_choose_yes_and_no;
        _startInstruction();
      }

      result.recognizedWords.toUpperCase().contains(Constants.no.toUpperCase());
    }
  }
}
