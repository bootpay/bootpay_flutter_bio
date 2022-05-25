class NextJob {

  int type = -1;
  int nextType = -1;
  bool initToken = false;
  String token = "";
  String biometricDeviceUuid = "";
  String biometricSecretKey = "";
  int serverUnixtime = 0;

  NextJob();

  // NextJob.fromJson(Map<String, dynamic> json) {
  //   cardName = json["cardName"];
  //   cardNo = json["cardNo"];
  //   cardCode = json["cardCode"];
  // }


  Map<String, dynamic> toJson() => {
    "type": type,
    "nextType": nextType,
    "initToken": initToken,
    "token": token,
    "biometricDeviceUuid": biometricDeviceUuid,
    "biometricSecretKey": biometricSecretKey,
    "serverUnixtime": serverUnixtime,
  };
}