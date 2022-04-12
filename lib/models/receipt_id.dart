import 'wallet/bio_card.dart';

class ReceiptId {

  String? receiptId;

  ReceiptId();

  ReceiptId.fromJson(Map<String, dynamic> json) {
    receiptId = json["receipt_id"];
  }

  Map<String, dynamic> toJson() => {
    "receipt_id": receiptId
  };
}