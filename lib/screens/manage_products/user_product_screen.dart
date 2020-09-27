import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/utility/constant.dart';
import '../app_drawer.dart';
import '../../provider/products.dart';
import '../../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  Future<void> refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchProduct(filterbyUser: true)
        .catchError((error) {
/*      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error Occur'),
          content: Text(error.toString()),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            )
          ],
        ),
      );*/
    });
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Constants.editProductRoute);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: refreshProduct(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
              break;
            case ConnectionState.done:
              if (snapshot.error == null) {
                return RefreshIndicator(
                  onRefresh: () => refreshProduct(context),
                  child: Consumer<Products>(
                    builder: (context, value, child) => Padding(
                      padding: EdgeInsets.all(8),
                      child:
                          /*  value.items.length == 0
                          ? Center(child: Text('Product not available'))
                          : */
                          ListView.builder(
                        itemCount: value.items.length,
                        itemBuilder: (_, index) {
                          return Column(children: [
                            UserProductItem(
                                id: value.items[index].id,
                                imageUrl: value.items[index].imageUrl,
                                title: value.items[index].title),
                            Divider()
                          ]);
                        },
                      ),
                    ),
                  ),
                );
              } else {
                return Center(child: Text('Something went wrong'));
              }
              break;
            default:
              return Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
