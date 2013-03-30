#import "PXParallaxScrollViewController.h"

@interface PXParallaxScrollViewController ()
@property(nonatomic, strong, readonly) UIScrollView *scrollView;
@end

@implementation PXParallaxScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView {
  self.view = [[UIScrollView alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.scrollView.showsVerticalScrollIndicator = YES;
  self.scrollView.backgroundColor = [UIColor orangeColor];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  CGSize viewSize = self.scrollView.frame.size;
  self.scrollView.contentSize = CGSizeMake(viewSize.width, viewSize.height * 2);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark Properties

- (UIScrollView *)scrollView {
  // TODO(rcacheaux): Checked cast.
  return (UIScrollView *)self.view;
}

@end
