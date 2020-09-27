import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/utility/categories.dart';
import '../provider/products.dart';
import 'package:shop_app/provider/product.dart';

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen();

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<Products>(context, listen: false)
        .productFindById(productId: productId);
    return Scaffold(
      /*  appBar: AppBar(
        title: Text("${product.title}"),
      ), */
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            floating: true,
            // title: Text("${product.title}"),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              title: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text("${product.title}",
                    /* style: TextStyle(
                        backgroundColor: Colors.black54, color: Colors.white), */
                    overflow: TextOverflow.ellipsis),
              ),
              background: Hero(
                tag: productId,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: 10),
            _productCategory(product),
            _productPrice(product),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Description',
                softWrap: true,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            _productColor(product),
            product.productCategory == AllCategory.prod_category_clothing_id
                ? Column(
                    children: [_productGender(product), _productSize(product)])
                : SizedBox(),
            _productDescription(product),
            SizedBox(height: 300),
          ]))
        ],
      ),
    );
  }

  Padding _productSize(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Size :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.size}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productGender(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Gender :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.gender}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productCategory(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Product Category :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.productCategory}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productColor(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Color :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '${product.color}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _productDescription(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${product.description}',
        softWrap: true,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
      ),
    );
  }

  Padding _productPrice(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Price :',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(
            '\$${product.price}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
