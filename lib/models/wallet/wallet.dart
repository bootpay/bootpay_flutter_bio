import 'bio_card.dart';

class Wallet {

  String? walletId;
  int? type;
  BioCard? d;
  int? walletType;

  Wallet();

  Wallet.fromJson(Map<String, dynamic> json) {
    walletId = json["wallet_id"];
    type = json["type"];
    d = BioCard.fromJson(json["d"]);
    walletType = json["wallet_type"];
  }

  Map<String, dynamic> toJson() => {
    "wallet_id": walletId,
    "type": type,
    "d": d?.toJson() ?? {},
    "wallet_type": walletType
  };
}