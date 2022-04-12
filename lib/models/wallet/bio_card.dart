class BioCard {

  String? cardName;
  String? cardNo;
  String? cardCode;

  BioCard();

  BioCard.fromJson(Map<String, dynamic> json) {
    cardName = json["cardName"];
    cardNo = json["cardNo"];
    cardCode = json["cardCode"];
  }


  Map<String, dynamic> toJson() => {
    "card_name": cardName,
    "card_no": cardNo,
    "card_code": cardCode
  };
}