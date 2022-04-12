import 'package:bootpay_bio/models/wallet/wallet_biometric.dart';
import 'package:bootpay_bio/models/wallet/wallet_data.dart';

class ResWalletList {

  WalletBiometric? biometric;
  List<WalletData> wallets = [];

  ResWalletList();

  ResWalletList.fromJson(Map<String, dynamic> json) {
    if(json["biometric"] != null) biometric = WalletBiometric.fromJson(json["biometric"]);
    if(json["wallets"] != null) wallets = json["wallets"].map((e) => WalletData.fromJson(e)).toList().cast<WalletData>();
  }
}