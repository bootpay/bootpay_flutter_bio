package kr.co.bootpay.bootpay_bio_example;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterFragmentActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;
import io.flutter.plugins.localauth.LocalAuthPlugin;

public class MainActivity extends FlutterFragmentActivity {

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine)
    {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
}
//import android.os.Bundle;
//import io.flutter.embedding.android.FlutterActivity;
//import io.flutter.embedding.engine.FlutterEngine;
////import io.flutter.app.FlutterFragmentActivity;
//import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;
//import io.flutter.plugins.localauth.LocalAuthPlugin;
//
//public class MainActivity extends FlutterFragmentActivity {
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        FlutterAndroidLifecyclePlugin.registerWith(
//                registrarFor(
//                        "io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
//        LocalAuthPlugin.registerWith(registrarFor("io.flutter.plugins.localauth.LocalAuthPlugin"));
//    }
//}

//import io.flutter.embedding.android.FlutterActivity;
//
//public class MainActivity extends FlutterActivity {
//}
