
class WalletBatchData {
  String? card_no = "";
  String? card_company = "";
  String? card_company_code = "";
  String? card_hash = "";
  int? card_type;


  WalletBatchData();
  WalletBatchData.fromJson(Map<String, dynamic> json) {
    card_no = json["card_no"];
    card_company = json["card_company"];
    card_company_code = json["card_company_code"];
    card_hash = json["card_hash"];
    card_type = json["card_type"];
  }

  Map<String, dynamic> toJson() => {
    "card_no": card_no,
    "card_company": card_company,
    "card_company_code": card_company_code,
    "card_hash": card_hash,
    "card_type": card_type,
  };
}