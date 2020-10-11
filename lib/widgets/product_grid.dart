import 'package:flutter/material.dart';
import '../provider/products.dart';
import 'product_item.dart';
import 'package:provider/provider.dart';
import '../utility/constant.dart';

class ProductGrid extends StatelessWidget {
  final bool isFavourite;
  final String searchTitle;
  final Function startInstruction;
  final Function resetSearchTitle;
  final String selectedCategory;

  ProductGrid(this.isFavourite, this.searchTitle, this.startInstruction, this.resetSearchTitle,  this.selectedCategory);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    // final products =
    //       isFavourite ? productsData.favoriteItems : productsData.items;
    final products = (searchTitle != null && searchTitle.isNotEmpty)
        ? productsData.searchProduct(searchTitle)
        :(selectedCategory != null && selectedCategory.isNotEmpty) && selectedCategory!="all"?
        productsData.selectedCategory(selectedCategory)
        : productsData.items;


    if (searchTitle != null && searchTitle.isNotEmpty && products.length > 0) {
      Future.delayed(Duration(seconds: 1),
          () => openDetailScreen(context, products[0].id));
    }

    if(products.length==0){
      startInstruction(noProduct:true);
    }
    return products.length == 0
        ? {
            Center(
              child: Text('Products not available'),
            )
          }
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

  void openDetailScreen(context, id) {
    resetSearchTitle();
    Navigator.pushNamed(context, Constants.productDetailScreenRoute,
        arguments: id);
  }
}
