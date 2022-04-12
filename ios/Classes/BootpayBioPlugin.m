#import "BootpayBioPlugin.h"
#if __has_include(<bootpay_bio/bootpay_bio-Swift.h>)
#import <bootpay_bio/bootpay_bio-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bootpay_bio-Swift.h"
#endif

@implementation BootpayBioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBootpayBioPlugin registerWithRegistrar:registrar];
}
@end
