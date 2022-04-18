#import "OdaringWebViewPlugin.h"
#if __has_include(<odaring_web_view/odaring_web_view-Swift.h>)
#import <odaring_web_view/odaring_web_view-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "odaring_web_view-Swift.h"
#endif

@implementation OdaringWebViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOdaringWebViewPlugin registerWithRegistrar:registrar];
}
@end
