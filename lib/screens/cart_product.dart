import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart';
import '../widgets/card_item.dart';
import '../provider/orders.dart';

class CartProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Items'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (context) => [PopupMenuItem(child: Text("hello"))],
          )
        ],
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
              setState(() {
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
              }
            },
    );
  }
}