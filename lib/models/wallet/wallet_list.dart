
import 'wallet.dart';

class WalletList {

  List<Wallet>? card;
  WalletList();

  WalletList.fromJson(Map<String, dynamic> json) {
    if(json["card"] != null) card = json["card"].map((e) => Wallet.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
    "card": card?.map((e) => e.toJson()).toList() ?? [],
  };
}