import 'package:flutter/material.dart';
import 'package:shop_app/screens/app_drawer.dart';
import 'package:shop_app/utility/constant.dart';

class CreateCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text("Add Category"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Constants.editProductRoute);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(10),
          child: Form(
            child: Column(
              children: [
                Text('Add main category'),
                TextFormField(
//                  initialValue: initialValues['price'],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Category'),
//                  focusNode: _priceFocusNode,
                  /*onFieldSubmitted: (_) {
    print("is called price onfield sumitted");

    FocusScope.of(context).requestFocus(_descFocusNode);*/
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                      child: Text("Add Category"),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      child: Text('Add SubCategories'),
                      onPressed: () {},
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
