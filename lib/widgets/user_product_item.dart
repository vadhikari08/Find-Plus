import 'package:flutter/material.dart';
import '../utility/constant.dart';
import '../provider/products.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String id;
  UserProductItem(
      {@required this.id, @required this.title, @required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => Navigator.of(context)
                  .pushNamed(Constants.editProductRoute, arguments: id),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id);
                  scaffold.hideCurrentSnackBar();
                  scaffold
                      .showSnackBar(SnackBar(content: Text('Product Deleted')));
                } catch (error) {
                  print(error);
                  scaffold.hideCurrentSnackBar();
                  scaffold
                      .showSnackBar(SnackBar(content: Text('Fail to delete')));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
