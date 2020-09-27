import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart';

class CardItem extends StatelessWidget {
  final String title;
  final double price;
  final int quantity;
  final String productId;
  final String id;
  CardItem(
      {@required this.title,
      @required this.productId,
      @required this.price,
      @required this.quantity,
      @required this.id});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (_) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Are you sure"),
            content: Text("Do you want to remove the item from cart"),
            actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          ),
        );
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        color: Theme.of(context).errorColor,
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: ListTile(
            title: Text(title),
            subtitle:
                Text('Total Price \$ ${(price * quantity).toStringAsFixed(2)}'),
            leading: CircleAvatar(
              maxRadius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: FittedBox(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$price',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
            trailing: Text('${quantity}x'),
          ),
        ),
      ),
    );
  }
}
