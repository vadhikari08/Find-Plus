import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/screens/orders_sreen.dart';

import '../helpers/custom_route.dart';
import '../provider/auth.dart';
import '../utility/constant.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isAdmin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initValue();
  }

  void initValue() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      isAdmin = false;
      return;
    }
    final userData =
        json.decode(preferences.getString('userData')) as Map<String, dynamic>;
    isAdmin = userData['email'] == 'vikram@test.com';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text("Hello Friends"),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () => Navigator.pushReplacementNamed(
                context, Constants.homeSCreenRoute),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Order'),
            onTap: () {
              // Navigator.pushReplacementNamed(
              //     context, Constants.orderScreenRoute);
              Navigator.pushReplacement(
                  context, CustomRoute(builder: (context) => OrderScreen()));
            },
          ),
          isAdmin ? Divider() : SizedBox(),
          isAdmin
              ? ListTile(
                  leading: const Icon(Icons.shopping_basket),
                  title: const Text('Manage Products'),
                  onTap: () => Navigator.pushReplacementNamed(
                      context, Constants.userProductScreenRoute),
                )
              : SizedBox(),
/*          Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Add Category'),
            onTap: () => Navigator.pushReplacementNamed(
                context, Constants.addCategoryRoute),
          ),*/
          Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
