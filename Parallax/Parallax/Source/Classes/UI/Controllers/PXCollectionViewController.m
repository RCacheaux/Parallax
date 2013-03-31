#import "PXCollectionViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "PXCollectionViewLayout.h"
#import "PXParallaxWindowCollectionViewCell.h"
#import "PXWindowView.h"

static NSString * const kPXParallaxWindowCellReuseID = @"PXWindowID";
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
}

- (void)loadCollectionView {
  PXCollectionViewLayout *layout = [[PXCollectionViewLayout alloc] init];
  layout.parallaxWindowHeight = 300.0f;
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                           collectionViewLayout:layout];
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  [self.collectionView registerClass:[PXParallaxWindowCollectionViewCell class]
          forCellWithReuseIdentifier:kPXParallaxWindowCellReuseID];
  [self.collectionView registerClass:[UICollectionViewCell class]
          forSupplementaryViewOfKind:kPXBannerSupplementaryViewKind
                 withReuseIdentifier:kPXBannerReuseID];
  
  [self.view addSubview:self.collectionView];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  self.collectionView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  PXParallaxWindowCollectionViewCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:kPXParallaxWindowCellReuseID
                                                forIndexPath:indexPath];
  cell.backgroundColor = [UIColor lightGrayColor];
  cell.windowView.windowBounds = CGRectMake(0.0f,
                                            0.0f,
                                            self.collectionView.frame.size.width,
                                            self.collectionView.frame.size.height);
  [cell setWindowImageToImageNamed:
      [NSString stringWithFormat:@"%i.JPG", indexPath.section + 1]];
  return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 4;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *banner =
      [collectionView
       dequeueReusableSupplementaryViewOfKind:kPXBannerSupplementaryViewKind
                          withReuseIdentifier:kPXBannerReuseID
                                 forIndexPath:indexPath];
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
