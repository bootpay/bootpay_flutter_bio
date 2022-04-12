class BioDevice {

  String? biometricSecretKey;
  String? biometricDeviceId;
  String? serverUnixtime;

  BioDevice();

  BioDevice.fromJson(Map<String, dynamic> json) {
    biometricSecretKey = json["biometric_secretKey"];
    biometricDeviceId = json["biometric_device_id"];
    serverUnixtime = json["server_unixtime"];
  }

  Map<String, dynamic> toJson() => {
    "biometric_secretKey": biometricSecretKey,
    "biometric_device_id": biometricDeviceId,
    "server_unixtime": serverUnixtime
  };
}