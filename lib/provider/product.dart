import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as Http;
import 'package:shop_app/utility/constant.dart';
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isfavourite;
  String gender;
  String productCategory;
  String size;
  String color;
  double quantity;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.imageUrl,
      @required this.price,
      this.isfavourite = false,
      this.gender,
      this.productCategory,
      this.size,
      this.color,
      this.quantity});

  Future<void> toggleFavorite(String token, String userId) async {
    bool oldStatus = isfavourite;
    isfavourite = !isfavourite;
    notifyListeners();
    var url =
        '${Constants.firebaseUrl}userFavorites/$userId/$id.json?auth=$token';
    try {
      final response = await Http.put(url, body: json.encode(isfavourite));
      print(json.decode(response.body));
      if (response.statusCode >= 400) {
        print('inside 400');
        _setOldvalue(oldStatus);
      }
    } catch (error) {
      print(error.toString());
      print('inside error');
      _setOldvalue(oldStatus);
    }
    notifyListeners();
  }

  static Map<String, dynamic> productToMap(Product product, _userId) {
    return {
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'gender': product.gender,
      'productCategory': product.productCategory,
      'size': product.size,
      'quantity': product.quantity,
      'creatorId': _userId,
      'color': product.color
    };
  }

  _setOldvalue(bool value) {
    isfavourite = value;
    notifyListeners();
    throw HttpException(message: 'Fail to add in favorite list');
  }
}
