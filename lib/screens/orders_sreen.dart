import 'package:flutter/material.dart';
import '../provider/orders.dart';
import 'package:provider/provider.dart';
import '../widgets/order_item.dart' as RowItem;
import 'app_drawer.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: const Text("Your Order"),
        ),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).fetchOrders(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                print('done');
                if (snapshot.error == null) {
                  return Consumer<Orders>(builder: (context, value, child) {
                    if (value.items.length == 0)
                      return Center(
                          child: Text(
                        "No Orders",
                        style: Theme.of(context).textTheme.headline6,
                      ));
                    else
                      return ListView.builder(
                        itemCount: value.items.length,
                        itemBuilder: (context, index) =>
                            RowItem.OrderItem(value.items[index]),
                      );
                  });
                } else {
                  return Center(
                      child: Text(
                    'Error Occur!',
                    style: Theme.of(context).textTheme.headline6,
                  ));
                }
                break;
              case ConnectionState.active:
                print('active');
                return (Text('active'));

              case ConnectionState.waiting:
                print('wating');
                return Center(
                  child: CircularProgressIndicator(),
                );

              case ConnectionState.none:
                print('none');
                return (Text('none'));

              default:
                return Text('default');
            }
          },
        ));
  }
}
