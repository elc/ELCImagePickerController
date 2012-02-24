#import "AppDelegate.h"
#import "MainController.h"

@implementation AppDelegate
@synthesize window, viewController;

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];
    return YES;
}

- (void) dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}

@end
