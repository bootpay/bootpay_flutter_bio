class BioDeviceUse {

  int? useBiometric;
  int? useDeviceBiometric;
  int? serverUnixtime;

  BioDeviceUse();

  BioDeviceUse.fromJson(Map<String, dynamic> json) {
    useBiometric = json["use_biometric"];
    useDeviceBiometric = json["use_device_biometric"];
    serverUnixtime = json["server_unixtime"];
  }

  Map<String, dynamic> toJson() => {
    "use_biometric": useBiometric,
    "use_device_biometric": useDeviceBiometric,
    "server_unixtime": serverUnixtime
  };
}