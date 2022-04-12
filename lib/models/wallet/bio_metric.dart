class BioMetric {

  String? biometricSecretKey;
  String? biometricDeviceUuid;
  int? serverUnixtime;

  BioMetric();

  BioMetric.fromJson(Map<String, dynamic> json) {
    biometricSecretKey = json["biometric_secret_key"];
    biometricDeviceUuid = json["biometric_device_uuid"];
    serverUnixtime = json["server_unixtime"];
  }


  Map<String, dynamic> toJson() => {
    "biometric_secret_key": biometricSecretKey,
    "biometric_device_uuid": biometricDeviceUuid,
    "server_unixtime": serverUnixtime
  };
}