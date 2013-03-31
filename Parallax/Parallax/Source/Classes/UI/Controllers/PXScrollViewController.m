#import "PXScrollViewController.h"

#import "PXScrollView.h"

// TODO(rcacheaux):This static value is purely for reference.
static NSUInteger kNumberOfBanners = 4;

@interface PXScrollViewController ()
@property(nonatomic, strong, readonly) PXScrollView *scrollView;
@end

@implementation PXScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView {
  self.view = [[PXScrollView alloc] init];
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

- (PXScrollView *)scrollView {
  // TODO(rcacheaux): Checked cast.
  return (PXScrollView *)self.view;
}

@end
