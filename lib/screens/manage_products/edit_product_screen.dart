import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/utility/categories.dart';
import 'package:shop_app/utility/constant.dart';
import '../../provider/product.dart';
import '../../provider/products.dart';

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _colorFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlfocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: "",
    description: "",
    imageUrl: "",
    price: 0,
    size: 'Small',
    productCategory: '',
    quantity: 0,
    color: '',
    gender: '',
  );
  var isInit = true;
  var isLoading = false;
  var initialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
    'color': '',
    'quantity': '',
  };
  var _screenWidth;
  var _screenHeight;
  Size _mediaQuery;
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.blue));
  final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.red));
  var _selectedGender = 'Male';
  var _selectedProductCategory = 'Mobile';
  var _selectedSize = 'Large';

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlfocusNode.removeListener(_updateImageUrl);
    _imageUrlfocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      String id = ModalRoute.of(context).settings.arguments as String;

      if (id != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .productFindById(productId: id);
        print(_editedProduct.id);
        if (_editedProduct == null) return;
        initialValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': _editedProduct.imageUrl,
          'color': _editedProduct.color,
          'quantity': _editedProduct.quantity.toString()
        };
        _selectedProductCategory = _editedProduct.productCategory;
        _selectedGender = _editedProduct.gender;
        _selectedSize = _editedProduct.size;
        _imageUrlController.text = _editedProduct.imageUrl;
      }
      isInit = false;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    print("is called imagee onfield sumitted");

    if (!_imageUrlfocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _imageUrlfocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _saveForm() async {
    final _isvalid = _form.currentState.validate();
    if (!_isvalid) {
      return;
    }
    _form.currentState.save();

    setState(() {
      isLoading = true;
    });
    if (_editedProduct.id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        print('Error occur here ' + error.toString());
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Error Occur"),
            content: Text('Something want wrong'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          ),
        );
      }
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _mediaQuery = MediaQuery.of(context).size;
    _screenWidth = _mediaQuery.height;
    _screenHeight = _mediaQuery.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Products"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _imageContainer(),
                        SizedBox(
                          height: 10,
                        ),
                        _imageField(),
                        SizedBox(
                          height: 10,
                        ),
                        _titleTextField(context),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Choose Product Category"),
                        SizedBox(
                          height: 10,
                        ),
                        _categoryDropDown(),
                        SizedBox(
                          height: 10,
                        ),
                        _priceTextInput(context),
                        SizedBox(
                          height: 10,
                        ),
                        _descriptionTextInput(),
                        SizedBox(
                          height: 10,
                        ),
                        _quantityTextInput(),
                        SizedBox(
                          height: 10,
                        ),
                        _colorTextInput(),
                        SizedBox(
                          height: 10,
                        ),
                        _selectedProductCategory ==
                                AllCategory.prod_category_clothing_id
                            ? _genderDropDown()
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        ),
                        _selectedProductCategory ==
                                AllCategory.prod_category_clothing_id
                            ? _sizeDropDown()
                            : SizedBox(),
                      ],
                    )),
              ),
            ),
    );
  }

  TextFormField _quantityTextInput() {
    return TextFormField(
      initialValue: initialValues['quantity'],
      maxLines: 1,
      focusNode: _quantityFocusNode,
      keyboardType: TextInputType.number,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_colorFocusNode);
      },
      decoration: InputDecoration(
          labelText: 'Quantity',
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          focusedBorder: border,
          errorBorder: errorBorder,
          enabledBorder: border),
      onSaved: (value) {
        _editedProduct = Product(
            description: _editedProduct.description,
            id: _editedProduct.id,
            imageUrl: _editedProduct.imageUrl,
            price: _editedProduct.price,
            isfavourite: _editedProduct.isfavourite,
            title: _editedProduct.title,
            quantity: double.parse(value),
            gender: _selectedGender,
            productCategory: _selectedProductCategory,
            color: _editedProduct.color,
            size: _selectedSize);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the quantity';
        }
        return null;
      },
    );
  }

  TextFormField _colorTextInput() {
    return TextFormField(
      initialValue: initialValues['color'],
      maxLines: 1,
      focusNode: _colorFocusNode,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: 'Color',
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          focusedBorder: border,
          errorBorder: errorBorder,
          enabledBorder: border),
      onSaved: (value) {
        _editedProduct = Product(
            description: _editedProduct.description,
            id: _editedProduct.id,
            imageUrl: _editedProduct.imageUrl,
            price: _editedProduct.price,
            isfavourite: _editedProduct.isfavourite,
            title: _editedProduct.title,
            quantity: _editedProduct.quantity,
            gender: _selectedGender,
            productCategory: _selectedProductCategory,
            color: value,
            size: _selectedSize);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the quantity';
        }
        return null;
      },
    );
  }

  TextFormField _descriptionTextInput() {
    return TextFormField(
      initialValue: initialValues['description'],
      maxLines: 10,
      focusNode: _descFocusNode,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
          labelText: 'Description',
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          focusedBorder: border,
          errorBorder: errorBorder,
          enabledBorder: border),
      onSaved: (value) {
        _editedProduct = Product(
            description: value,
            id: _editedProduct.id,
            imageUrl: _editedProduct.imageUrl,
            price: _editedProduct.price,
            isfavourite: _editedProduct.isfavourite,
            title: _editedProduct.title,
            quantity: _editedProduct.quantity,
            gender: _selectedGender,
            productCategory: _selectedProductCategory,
            color: _editedProduct.color,
            size: _selectedSize);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the description';
        }
        if (value.length < 10) {
          return 'Description could be alteast 10 character long';
        }
        return null;
      },
    );
  }

  TextFormField _priceTextInput(BuildContext context) {
    return TextFormField(
      initialValue: initialValues['price'],
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: 'Price',
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          focusedBorder: border,
          errorBorder: errorBorder,
          enabledBorder: border),
      focusNode: _priceFocusNode,
      onFieldSubmitted: (_) {
        print("is called price onfield sumitted");

        FocusScope.of(context).requestFocus(_descFocusNode);
      },
      onSaved: (value) {
        _editedProduct = Product(
            description: _editedProduct.description,
            id: _editedProduct.id,
            imageUrl: _editedProduct.imageUrl,
            price: double.parse(value),
            isfavourite: _editedProduct.isfavourite,
            title: _editedProduct.title,
            quantity: _editedProduct.quantity,
            gender: _selectedGender,
            productCategory: _selectedProductCategory,
            color: _editedProduct.color,
            size: _selectedSize);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a price';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        if (double.parse(value) <= 0) {
          return 'Please enter price greater than 0';
        }
        return null;
      },
    );
  }

  DropdownButtonHideUnderline _categoryDropDown() {
    return DropdownButtonHideUnderline(
        child: Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1.0, style: BorderStyle.solid, color: Colors.blue),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      /*  margin: EdgeInsets.only(left: 10.0, right: 10.0),*/
      child: DropdownButton(
          value: _selectedProductCategory,
          items: AllCategory.productCategories
              .map((e) => DropdownMenuItem(
                  value: e.categoryLabel, child: Text(e.categoryLabel)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedProductCategory = value.toString();
            });
          }),
    ));
  }

  DropdownButtonHideUnderline _genderDropDown() {
    return DropdownButtonHideUnderline(
        child: Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1.0, style: BorderStyle.solid, color: Colors.blue),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      /*  margin: EdgeInsets.only(left: 10.0, right: 10.0),*/
      child: DropdownButton(
          value: _selectedGender,
          items: AllCategory.genderCategories
              .map((e) => DropdownMenuItem(
                  value: e.genderLabel, child: Text(e.genderLabel)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value.toString();
            });
          }),
    ));
  }

  DropdownButtonHideUnderline _sizeDropDown() {
    return DropdownButtonHideUnderline(
        child: Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1.0, style: BorderStyle.solid, color: Colors.blue),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      /*  margin: EdgeInsets.only(left: 10.0, right: 10.0),*/
      child: DropdownButton(
          value: _selectedSize,
          items: AllCategory.sizeCategories
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedSize = value;
            });
          }),
    ));
  }

  TextFormField _titleTextField(BuildContext context) {
    return TextFormField(
      initialValue: initialValues['title'],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          labelText: 'Title',
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          focusedBorder: border,
          errorBorder: errorBorder,
          enabledBorder: border),
      onSaved: (value) {
        _editedProduct = Product(
            description: _editedProduct.description,
            id: _editedProduct.id,
            imageUrl: _editedProduct.imageUrl,
            price: _editedProduct.price,
            isfavourite: _editedProduct.isfavourite,
            title: value,
            quantity: _editedProduct.quantity,
            gender: _selectedGender,
            productCategory: _selectedProductCategory,
            color: _editedProduct.color,
            size: _selectedSize);
      },
      focusNode: _titleFocusNode,
      onFieldSubmitted: (value) {
        print("is called title onfield sumitted");
        FocusScope.of(context).requestFocus(_priceFocusNode);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter title';
        }
        return null;
      },
    );
  }

  TextFormField _imageField() {
    return TextFormField(
      controller: _imageUrlController,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      focusNode: _imageUrlfocusNode,
      scrollPadding: EdgeInsets.all(10),
      decoration: InputDecoration(
        labelText: 'ImageUrl',
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        focusedBorder: border,
        enabledBorder: border,
        errorBorder: errorBorder,
      ),
      onSaved: (value) {
        _editedProduct = Product(
            description: _editedProduct.description,
            id: _editedProduct.id,
            imageUrl: value,
            price: _editedProduct.price,
            isfavourite: _editedProduct.isfavourite,
            title: _editedProduct.title,
            quantity: _editedProduct.quantity,
            gender: _selectedGender,
            productCategory: _selectedProductCategory,
            color: _editedProduct.color,
            size: _selectedSize);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the image url';
        }
        if (!value.startsWith('http') && !value.startsWith('https')) {
          return 'Please enter a valid url';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        // _saveForm();
        FocusScope.of(context).requestFocus(_titleFocusNode);
      },
    );
  }

  Container _imageContainer() {
    return Container(
        width: _screenWidth * 0.8,
        height: _screenHeight * 0.6,
        margin: EdgeInsets.only(top: 10, right: 8),
        child: _imageUrlController.text.isEmpty
            ? Center(child: Text("Enter Image Url"))
            : Image.network(_imageUrlController.text),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.orange),
        ));
  }
}
