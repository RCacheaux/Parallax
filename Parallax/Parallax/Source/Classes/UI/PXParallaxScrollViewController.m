#import "PXParallaxScrollViewController.h"

#import "PXParallaxScrollView.h"

// TODO(rcacheaux):This static value is purely for reference.
static NSUInteger kNumberOfBanners = 4;

@interface PXParallaxScrollViewController ()
@property(nonatomic, strong, readonly) PXParallaxScrollView *scrollView;
@end

@implementation PXParallaxScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView {
  self.view = [[PXParallaxScrollView alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.scrollView.showsVerticalScrollIndicator = YES;
  self.scrollView.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewWillAppear:(BOOL)animated {
  CGSize viewSize = self.scrollView.frame.size;
  NSLog(@"Hi");
  CGFloat bannerAndWindowSize = kBannerHeight + kParallaxWindowHeight;
  self.scrollView.contentSize = CGSizeMake(viewSize.width,
                                           bannerAndWindowSize * kNumberOfBanners);
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark Properties

- (PXParallaxScrollView *)scrollView {
  // TODO(rcacheaux): Checked cast.
  return (PXParallaxScrollView *)self.view;
}

@end
