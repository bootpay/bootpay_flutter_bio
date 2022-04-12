import 'package:intl/intl.dart';

class BioPrice {

  String? name;
  double? price = 0.0;
  double? priceStroke = 0.0;

  // BioPrice();
  BioPrice({this.name, this.price, this.priceStroke});


  get priceComma => NumberFormat('###,###,###,###').format(price) + '원';

  BioPrice.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    price = json["price"];
    priceStroke = json["price_stroke"];
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "price_stroke": priceStroke
  };
}