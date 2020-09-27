import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/cart.dart';
import '../provider/product.dart';
import '../utility/constant.dart';
import '../provider/auth.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final _token = Provider.of<Auth>(context, listen: false).token;
    final _userId = Provider.of<Auth>(context, listen: false).userId;

    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
          footer: GridTileBar(
              backgroundColor: Colors.black54,
              leading: Consumer<Product>(
                builder: (context, value, child) => IconButton(
                  onPressed: () async {
                    try {
                      await product.toggleFavorite(_token, _userId);
                      scaffold.hideCurrentSnackBar();
                      scaffold.showSnackBar(SnackBar(
                        content: Text(product.isfavourite
                            ? '${product.title} added as favorite.'
                            : '${product.title} removed as favorite.'),
                      ));
                    } catch (error) {
                      scaffold.hideCurrentSnackBar();
                      scaffold.showSnackBar(SnackBar(
                        content: Text(error.toString()),
                      ));
                    }
                  },
                  icon: Icon(
                    product.isfavourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              title: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
              trailing: IconButton(
                  icon: Icon(Icons.shopping_cart,
                      color: Theme.of(context).accentColor),
                  onPressed: () {
                    cart.addItem(product.id, product.price, product.title);
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Add item to cart"),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          }),
                    ));
                  })),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
                context, Constants.productDetailScreenRoute,
                arguments: product.id),
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
              ),
            ),
          )),
    );
  }
}
