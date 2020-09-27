import 'package:shop_app/models/gender_category.dart';
import 'package:shop_app/models/product_category.dart';

class AllCategory {
  static const productCategories = [
    ProductCategory("_mobile", "Mobile"),
    ProductCategory("_clothing", "Clothing"),
    ProductCategory("electronics_electrics", "Electrics and electronics"),
    ProductCategory("home_decor", "Home Decor"),
    ProductCategory("sport_item", "Sports Item"),
  ];

  static const genderCategories = [
    GenderCategory("_male", "Male"),
    GenderCategory("_female", "Female"),
  ];

  static const sizeCategories = [
    'Extra Small',
    'Small',
    'Medium',
    'Large',
    'Extra Large',
    'XXL',
    'XXXL'
  ];

  static const prod_category_mobile_id = 'Mobile';
  static const prod_category_clothing_id = 'Clothing';
  static const prod_category_e_and_e_id = 'Electrics and electronics';
  static const prod_category_home_decor_id = 'Home Decor';
  static const prod_category_sport_item_id = 'Sports Item';
}
