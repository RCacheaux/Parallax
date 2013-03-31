#import "PXAppDelegate.h"

#import "PXScrollViewController.h"
#import "PXCollectionViewController.h"

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
  /*
  PXScrollViewController *parallaxViewController =
      [[PXScrollViewController alloc] init];
  self.window.rootViewController = parallaxViewController;
   */
  
  
  PXCollectionViewController *parallaxViewController =
      [[PXCollectionViewController alloc] init];
  self.window.rootViewController = parallaxViewController;
}

@end
