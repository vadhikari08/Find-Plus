import 'dart:math';

import 'package:flutter/material.dart';
import '../provider/orders.dart' as ProvideItem;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final ProvideItem.OrderItem order;
  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$ ${widget.order.amount}'),
            subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm a').format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.linear,
            padding: EdgeInsets.all(10),
            height: _isExpanded
                ? min(widget.order.products.length * 25 + 30.0, 200)
                : 0,
            width: double.infinity,
            child: ListView.builder(
              itemCount: widget.order.products.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.order.products[index].title,
                          // overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${widget.order.products[index].quantity}x\$${widget.order.products[index].price}',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
