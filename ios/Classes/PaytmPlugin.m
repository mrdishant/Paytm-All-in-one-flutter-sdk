#import "PaytmPlugin.h"
#if __has_include(<paytm/paytm-Swift.h>)
#import <paytm/paytm-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "paytm-Swift.h"
#endif

@implementation PaytmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaytmPlugin registerWithRegistrar:registrar];
}
@end
