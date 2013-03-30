#import "PXAppDelegate.h"

#import "PXParallaxScrollViewController.h"

@implementation PXAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self loadWindow];
  return YES;
}

- (void)loadWindow {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  [self loadRootViewController];
  [self.window makeKeyAndVisible];
}

- (void)loadRootViewController {
  PXParallaxScrollViewController *parallaxViewController =
      [[PXParallaxScrollViewController alloc] init];
  self.window.rootViewController = parallaxViewController;
}

@end
