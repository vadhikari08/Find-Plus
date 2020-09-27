import 'package:flutter/material.dart';
import 'package:shop_app/utility/constant.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  //reference type
  final String _token;
  final String _userId;

  Products(this._token, this._userId, this._item) {
    print('token is $_token');
  }

  List<Product> _item = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._item];
  }

  List<Product> get favoriteItems {
    return _item.where((element) => element.isfavourite).toList();
  }

  Product productFindById({productId}) {
    return items.firstWhere(
      (element) => productId == element.id,
      orElse: () {
        return null;
      },
    );
  }

  Future<void> fetchProduct({bool filterbyUser = false}) async {
    final filter = '&orderBy="creatorId"&equalTo="$_userId"';
    var url;
    if (filterbyUser)
      url = '${Constants.firebaseUrl}products.json?auth=$_token$filter';
    else
      url = '${Constants.firebaseUrl}products.json?auth=$_token';

    print(url);
    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      print(responseData);
      if (responseData == null) {
        _item = [];
        return;
      }
      final favUrl =
          '${Constants.firebaseUrl}userFavorites/$_userId.json?auth=$_token';
      final favResponse = await http.get(favUrl);
      final favResponseData = json.decode(favResponse.body);
      print(favResponseData);
      List<Product> _loadedList = [];
      responseData.forEach((prodId, prodData) {
        _loadedList.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            color: prodData['color'],
            gender:prodData['gender'] ,
            productCategory:prodData['productCategory'] ,
            quantity: prodData['quantity'],
            size: prodData['size'],
            isfavourite: favResponseData == null
                ? false
                : favResponseData[prodId] ?? false,
            // ?? if is null set false
            price: prodData['price']));
      });
      _item = _loadedList;
      notifyListeners();
    } catch (error) {
      throw HttpException(message: 'Error occur at server side');
    }
  }

  Future<void> addProduct(Product newProduct) async {
    final url = '${Constants.firebaseUrl}products.json?auth=$_token';
    try {
      final response = await http.post(
        url,
        body: json.encode(Product.productToMap(newProduct, _userId)),
      );
      final product = Product(
          id: json.decode(response.body)['name'],
          title: newProduct.title,
          description: newProduct.description,
          imageUrl: newProduct.imageUrl,
          price: newProduct.price,
          gender: newProduct.gender,
          color: newProduct.color,
          quantity: newProduct.quantity,
          productCategory: newProduct.productCategory,
          size: newProduct.size);
      _item.add(product);
      notifyListeners();
    } catch (error) {
      print('encounter error $error');
      throw error;
    }
  }

  Future<void> updateProduct(Product newProduct) async {
    final url =
        '${Constants.firebaseUrl}products/${newProduct.id}.json?auth=$_token';
    int index = _item.indexWhere((element) => element.id == newProduct.id);
    if (index >= 0) {
      await http.patch(url,
          body: json.encode(Product.productToMap(newProduct, _userId)));
      _item[index] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = '${Constants.firebaseUrl}products/$id.json?auth=$_token';
    print('deleting');
    int index = items.indexWhere((element) => element.id == id);
    var existingProduct = _item[index];
    _item.removeAt(index);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _item.insert(index, existingProduct);
      notifyListeners();
      throw HttpException(message: 'Could not delete product');
    }
    existingProduct = null;
  }
}
