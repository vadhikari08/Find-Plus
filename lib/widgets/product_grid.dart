import 'package:flutter/material.dart';
import '../provider/products.dart';
import 'product_item.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {
  final bool isFavourite;
  ProductGrid(this.isFavourite);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        isFavourite ? productsData.favoriteItems : productsData.items;
    return products.length == 0
        ? Center(
            child: Text('Products not available'),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20),
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItem(),
            ),
          );
  }
}
