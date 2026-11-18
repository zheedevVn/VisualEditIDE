#import <UIKit/UIKit.h>

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[HelloTweak] Built by the Visual IDE Theos Build Server");
}

%end
