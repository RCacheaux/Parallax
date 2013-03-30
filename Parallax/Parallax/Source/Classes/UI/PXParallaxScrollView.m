#import "PXParallaxScrollView.h"

@interface PXParallaxScrollView ()
@property(nonatomic, assign) BOOL bannersLaidOut;
@property(nonatomic, strong) NSArray *bannerViews;
@end

@implementation PXParallaxScrollView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _bannersLaidOut = NO;
    [self loadBanners];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!self.bannersLaidOut && !CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
    [self layoutBannerViews];
  }
}

- (void)layoutBannerViews {
  CGSize bannerSize = CGSizeMake(self.bounds.size.width, kBannerHeight);
  for (int i = 0; i < [self.bannerViews count]; i++) {
    UIView *bannerView = self.bannerViews[i];
    bannerView.frame = [self frameForBannerViewAtIndex:i size:bannerSize];
  }
  self.bannersLaidOut = YES;
}

- (CGRect)frameForBannerViewAtIndex:(NSUInteger)index size:(CGSize)size {
  CGRect frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
  CGFloat yOffset = (kBannerHeight + kParallaxWindowHeight) * index;
  return CGRectOffset(frame, 0.0f, yOffset);;
}

- (void)loadBanners {
  UIView *bannerView1 = [[UIView alloc] init];
  bannerView1.backgroundColor = [UIColor redColor];
  [self addSubview:bannerView1];
  
  UIView *bannerView2 = [[UIView alloc] init];
  bannerView2.backgroundColor = [UIColor orangeColor];
  [self addSubview:bannerView2];
  
  UIView *bannerView3 = [[UIView alloc] init];
  bannerView3.backgroundColor = [UIColor blueColor];
  [self addSubview:bannerView3];
  
  UIView *bannerView4 = [[UIView alloc] init];
  bannerView4.backgroundColor = [UIColor greenColor];
  [self addSubview:bannerView4];
  
  self.bannerViews = @[bannerView1, bannerView2, bannerView3, bannerView4];
}

@end
