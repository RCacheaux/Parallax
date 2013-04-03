#import "PXCollectionViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "PXCollectionViewLayout.h"
#import "PXCollectionViewCell.h"
#import "PXCroppedImageContainerView.h"
#import "PXBannerView.h"

static NSString * const kPXParallaxCellReuseID = @"PXCellID";
static NSString * const kPXBannerReuseID = @"PXBannerID";

@interface PXCollectionViewController ()<UICollectionViewDataSource,
                                         PXCollectionViewDelegate>
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation PXCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)loadView {
  self.view = [[UIView alloc] init];
  self.view.backgroundColor = [UIColor redColor];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self loadCollectionView];
  [self loadCollectionViewPinchGestureRecognizer];
}

- (void)loadCollectionView {
  PXCollectionViewLayout *layout = [[PXCollectionViewLayout alloc] init];
  layout.parallaxVisibleHeight = 500.0f;
  layout.parallaxOffset = 50.0f;
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                           collectionViewLayout:layout];
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  CATransform3D perspective = CATransform3DIdentity;
  perspective.m34 = -1.0f/800.0f;
  self.collectionView.layer.sublayerTransform = perspective;
  
  [self.collectionView registerClass:[PXCollectionViewCell class]
          forCellWithReuseIdentifier:kPXParallaxCellReuseID];
  [self.collectionView registerClass:[PXBannerView class]
          forSupplementaryViewOfKind:kPXBannerSupplementaryViewKind
                 withReuseIdentifier:kPXBannerReuseID];
  
  [self.view addSubview:self.collectionView];
}

- (void)loadCollectionViewPinchGestureRecognizer {
  UIPinchGestureRecognizer *pinchGestureRecognizer =
      [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleCollectionViewPinch:)];
  [self.collectionView addGestureRecognizer:pinchGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  self.collectionView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark Interaction

- (void)handleCollectionViewPinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
  PXCollectionViewLayout *layout =
      (PXCollectionViewLayout *)self.collectionView.collectionViewLayout;
  if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    CGPoint initialPinchPoint =
        [pinchGestureRecognizer locationInView:self.collectionView];
    NSIndexPath* pinchedCellPath =
        [self.collectionView indexPathForItemAtPoint:initialPinchPoint];
    layout.pinchedCellPath = pinchedCellPath;
  } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    NSLog(@"Pinch Scale: %f", pinchGestureRecognizer.scale);
    layout.pinchedCellScale = pinchGestureRecognizer.scale;
    layout.pinchedCellCenter =
        [pinchGestureRecognizer locationInView:self.collectionView];
  } else {
    // TODO(rcacheaux): Determine if should expand or contract.
    // TODO(rcacheaux): Re-center collection view and lock the scroll.
    
    pinchGestureRecognizer.enabled = NO;
    PXCollectionViewCell *cell = (PXCollectionViewCell *)
        [self.collectionView cellForItemAtIndexPath:layout.pinchedCellPath];
    
    [cell.imageContainerView animateToImageViewScale:0.0f
                                withDuration:2.0f
                                  completion:^(BOOL finished){
                                    layout.expandedCellPath = layout.pinchedCellPath;
                                    layout.pinchedCellScale = 1.0;
                                    layout.pinchedCellPath = nil;
                                    pinchGestureRecognizer.enabled = YES;
                                  }];
  }
}

#pragma mark UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  PXCollectionViewCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:kPXParallaxCellReuseID
                                                forIndexPath:indexPath];
  cell.backgroundColor = [UIColor lightGrayColor];
  cell.imageContainerView.referenceFrame = CGRectMake(0.0f,
                                            0.0f,
                                            self.collectionView.frame.size.width,
                                            self.collectionView.frame.size.height);
  [cell setImageToImageNamed:
      [NSString stringWithFormat:@"%i.jpg", indexPath.section]];
  return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 4;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
  PXBannerView *banner =
      [collectionView
       dequeueReusableSupplementaryViewOfKind:kPXBannerSupplementaryViewKind
                          withReuseIdentifier:kPXBannerReuseID
                                 forIndexPath:indexPath];
  [banner setImageToImageNamed:[NSString stringWithFormat:@"B%i.jpg", indexPath.section]];
  banner.backgroundColor = [UIColor whiteColor];
//  banner.layer.borderColor = [UIColor blackColor].CGColor;
//  banner.layer.borderWidth = 2.0f;
  return banner;
}

#pragma mark PXCollectionView Delegate

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
    heightForBannerInSection:(NSInteger)section {
  if (section == 0) {
    return 900.0f;
  }
  return 400.0f;
}

@end
