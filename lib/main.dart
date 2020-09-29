import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/choose_user_screen.dart';
import 'package:shop_app/screens/manage_products/create_category.dart';
import 'package:shop_app/screens/product_detail.dart';
import 'package:shop_app/screens/splash_screen.dart';

import './screens/orders_sreen.dart';
import 'helpers/custom_route.dart';
import 'provider/auth.dart';
import 'provider/cart.dart';
import 'provider/orders.dart';
import 'provider/products.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_product.dart';
import 'screens/manage_products/edit_product_screen.dart';
import 'screens/manage_products/user_product_screen.dart';
import 'screens/product_overview.dart';
import 'utility/constant.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (context, value, previous) => Products(value.token,
              value.userId, previous.items == null ? [] : previous.items),
          create: (context) => Products('', '', []),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders([], '', ''),
          update: (context, value, previous) => Orders(
              previous.items == null ? [] : previous.items,
              value.userId,
              value.token),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Find Plus',
            theme: ThemeData(
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustompageTransitionBuilder(),
                TargetPlatform.iOS: CustompageTransitionBuilder()
              }),
              fontFamily: 'Lato',
              primarySwatch: Colors.orange,
              accentColor: Colors.pink,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home:  /*ChooseUserScreen() ,*/ auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return SplashScreen();
                      else
                        return AuthScreen();
                    },
                    future: auth.autoLogin(),
                  ),
            routes: {
              Constants.homeSCreenRoute: (ctx) => ProductOverviewScreen(),
              Constants.productDetailScreenRoute: (ctx) =>
                  ProductDetailScreen(),
              Constants.cartScreenRoute: (ctx) => CartProductScreen(),
              Constants.orderScreenRoute: (ctx) => OrderScreen(),
              Constants.userProductScreenRoute: (ctx) => UserProductScreen(),
              Constants.editProductRoute: (ctx) => EditProductScreen(),
              Constants.authRoute: (ctx) => AuthScreen(),
              Constants.chooseUserRoute: (ctx) => ChooseUserScreen(),
              Constants.addCategoryRoute: (ctx) => CreateCategory()
            },
          );
        },
      ),
    );
  }
}
