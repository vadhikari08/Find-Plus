import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/cart.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import '../utility/constant.dart';
import 'app_drawer.dart';
import '../provider/products.dart';

enum menu { fav, all }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isfavorite = false;
  bool _callAPI = true;
  bool _isloading = false, _isError = false;
  String errorMessage = 'Some Error';
  @override
  void initState() {
    // Future.delayed(Duration.zero, () {
    //   Provider.of<Products>(context, listen: false).fetchProduct();
    // });
    // Provider.of<Products>(context).fetchProduct();
    super.initState();
  }

  void callApi() async {}
  @override
  void didChangeDependencies() {
    if (_callAPI) {
      if (!mounted) return;
      setState(() {
        _isloading = true;
      });

      Provider.of<Products>(context, listen: false)
          .fetchProduct()
          .then((value) {
        if (!mounted) return;
        setState(() {
          _isloading = false;
          _isError = false;
        });
      }).catchError((onError) {
        errorMessage = onError.toString() ?? errorMessage;
        if (!mounted) return;
        setState(() {
          _isloading = false;
          _isError = true;
        });
      });
      _callAPI = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        actions: <Widget>[
          Consumer<Cart>(
            builder: (context, cartData, chd) =>
                Badge(child: chd, value: cartData.getItemCount.toString()),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Constants.cartScreenRoute);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ),
          PopupMenuButton(
            onSelected: (menu value) {
              if (menu.fav == value) {
                setState(() {
                  _isfavorite = true;
                });
              } else {
                setState(() {
                  _isfavorite = false;
                });
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('My Favorites'),
                value: menu.fav,
              ),
              PopupMenuItem(
                child: Text('All Products'),
                value: menu.all,
              )
            ],
            icon: Icon(Icons.more_vert),
          ),
        ],
        title: Text('SHOP FOR YOU'),
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isError
              ? Center(
                  child: Text(errorMessage),
                )
              : ProductGrid(_isfavorite),
    );
  }
}
