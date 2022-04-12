import 'wallet/bio_card.dart';

class ReceiptData {

  String? applicationId;
  String? orderId;
  double? price;
  String? name;

  ReceiptData();

  ReceiptData.fromJson(Map<String, dynamic> json) {
    applicationId = json["application_id"];
    orderId = json["order_id"];
    price = json["price"];
    name = json["name"];
  }

  Map<String, dynamic> toJson() => {
    "application_id": applicationId,
    "order_id": orderId,
    "price": price,
    "name": name,
  };
}