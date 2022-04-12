
import 'wallet_batch_data.dart';

class WalletData {
  String wallet_id = "";
  int type = -1;
  int sandbox = -1;
  WalletBatchData batch_data = WalletBatchData();
  String card_code = "";
  int wallet_type = -1; // 1: new, 2: other


  WalletData();
  WalletData.fromJson(Map<String, dynamic> json) {
    wallet_id = json["wallet_id"];
    type = json["type"];
    sandbox = json["sandbox"];
    batch_data = WalletBatchData.fromJson(json["batch_data"]);
    card_code = json["card_code"];
  }

  Map<String, dynamic> toJson() => {
    "wallet_id": wallet_id,
    "type": type,
    "sandbox": sandbox,
    "batch_data": batch_data,
    "card_code": card_code,
  };
}