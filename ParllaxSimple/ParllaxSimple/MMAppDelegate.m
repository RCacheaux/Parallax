#import "MMAppDelegate.h"

#import "MMParallacticViewController.h"
#import "MMParallacticFlowLayout.h"

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];

  MMParallacticFlowLayout *flow = [MMParallacticFlowLayout new];
  flow.itemSize = CGSizeMake(100.0f, 100.0f);
  flow.minimumInteritemSpacing = 40.0f;
  flow.minimumLineSpacing = 40.0f;
  
  self.window.rootViewController =
      [[MMParallacticViewController alloc] initWithCollectionViewLayout:flow];
  

  [self.window makeKeyAndVisible];
  return YES;
}

@end
