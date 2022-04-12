import 'bio_card.dart';

class WalletBiometric {
  int? server_unixtime;
  bool? biometric_confirmed;

  WalletBiometric();
  WalletBiometric.fromJson(Map<String, dynamic> json) {
    server_unixtime = json["server_unixtime"];
    biometric_confirmed = json["biometric_confirmed"];
  }

  Map<String, dynamic> toJson() => {
    "server_unixtime": server_unixtime,
    "biometric_confirmed": biometric_confirmed,
  };
}