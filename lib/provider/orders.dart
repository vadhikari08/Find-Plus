import 'package:flutter/cupertino.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:http/http.dart' as Http;
import 'dart:convert';
import '../models/http_exception.dart';
import '../utility/constant.dart' ;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  final String _token;
  final String _userId;
  List<OrderItem> _orders = [];
  List<OrderItem> get items {
    return [..._orders];
  }

  Orders(this._orders, this._userId, this._token);

  Future<void> fetchOrders() async {
    final url =
        '${Constants.firebaseUrl}orders/$_userId.json?auth=$_token';
    List<OrderItem> orderList = [];
    try {
      final response = await Http.get(url);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      print('Response for orders:$responseData');
      if (responseData == null) {
        _orders = [];
        return;
      }
      print(responseData);
      responseData.forEach((key, value) {
        orderList.add(OrderItem(
            id: key,
            amount: value['amount'],
            products: (value['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title']))
                .toList(),
            dateTime: DateTime.parse(value['dateTime'])));
      });
      _orders = orderList.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw HttpException(message: 'Fail to fetch data from server');
    }
  }

  Future<void> addOrders(List<CartItem> cartProduct, double total) async {
    var url =
        '${Constants.firebaseUrl}orders/$_userId.json?auth=$_token';
    try {
      final response = await Http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProduct
                .map((product) => {
                      'id': product.id,
                      'title': product.title,
                      'price': product.price,
                      'quantity': product.quantity
                    })
                .toList(),
            'dateTime': DateTime.now().toIso8601String()
          }));
      _orders.insert(
          0,
          OrderItem(
              amount: total,
              dateTime: DateTime.now(),
              id: json.decode(response.body)['name'],
              products: cartProduct));
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw HttpException(message: 'Error Occur while placing order');
    }
  }
}
