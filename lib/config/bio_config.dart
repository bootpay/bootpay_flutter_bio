
import 'package:flutter/foundation.dart';

void BootpayPrint(Object? object) {
  if(kReleaseMode) return;
  print(object);
}
