#import "PXScrollView.h"

#import "PXWindowView.h"

@interface PXScrollView ()
@property(nonatomic, assign) BOOL bannersLaidOut;
@property(nonatomic, strong) NSArray *bannerViews;
@property(nonatomic, assign) BOOL imageViewsLaidOut;
@property(nonatomic, strong) NSArray *windowViews;
@property(nonatomic, strong) NSMutableArray *parallaxOrigins;

@property(nonatomic, assign) CGFloat parallaxOffset;
@end

@implementation PXScrollView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _parallaxOffset = 50.0f;
    _parallaxOrigins = [NSMutableArray array];
    
    _bannersLaidOut = NO;
    _imageViewsLaidOut = NO;
    [self loadImages];
    [self loadBanners];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
    if (!self.bannersLaidOut) {
      [self layoutBannerViews];
    }
    if (!self.imageViewsLaidOut) {
      [self layoutImageViews];
    }
  }
  
  if (self.bannersLaidOut && self.imageViewsLaidOut) {
    CGFloat bottomOfBounds = CGRectGetMaxY(self.bounds);
    NSArray *parallaxingIndicies = [self currentlyParallaxingIndicies];
    
    for (PXWindowView *imageViewContainer in self.windowViews) {
      imageViewContainer.frame = CGRectZero;
    }
    
    for (NSNumber *parallaxingIndex in parallaxingIndicies) {
      NSUInteger index = [parallaxingIndex integerValue];
      
      PXWindowView *imageView = self.windowViews[index];
      CGRect newImageFrame = CGRectMake(0.0f,
                                        (bottomOfBounds - self.bounds.size.height),
                                        self.bounds.size.width,
                                        self.bounds.size.height);
      
      
      // Now size it.
      CGSize bannerSize = [self bannerViewSize];
      CGRect nextBannerFrame =
          [self frameForBannerViewAtIndex:(index + 1) size:bannerSize];
      
      // Crop if necessary.
      if (CGRectGetMaxY(newImageFrame) > CGRectGetMaxY(nextBannerFrame)) {
        CGFloat amountToCrop = CGRectGetMaxY(newImageFrame) - CGRectGetMaxY(nextBannerFrame);
        newImageFrame.size.height -= amountToCrop;
      }
      
      CGRect currentBannerFrame =
          [self frameForBannerViewAtIndex:index size:bannerSize];
      
      
      
      
      
      CGFloat parallaxWholeHeight =
          (CGRectGetMinY(nextBannerFrame) + self.bounds.size.height) - CGRectGetMaxY(currentBannerFrame);
      CGFloat percentParallax =
          (bottomOfBounds - CGRectGetMaxY(currentBannerFrame)) / parallaxWholeHeight;
      CGFloat parallaxRange = self.parallaxOffset * 2;
      CGFloat parallaxCurrentOffset = self.parallaxOffset - (parallaxRange * percentParallax);
      // Apply parallax.
      newImageFrame.origin.y += parallaxCurrentOffset;
      
      imageView.frame = newImageFrame;
    }
  }
}

- (NSArray *)currentlyParallaxingIndicies{
  NSMutableArray *parallaxingIndicies = [NSMutableArray array];
  
  CGFloat boundsTop =  CGRectGetMinY(self.bounds);
  CGFloat boundsBottom = CGRectGetMaxY(self.bounds);
  // Look for Parallaxing.
  for (UIView *bannerView in self.bannerViews) {
    CGFloat bottomOfBanner = CGRectGetMaxY(bannerView.frame);
    if (bottomOfBanner <= boundsBottom) {
      [parallaxingIndicies addObject:@([self.bannerViews indexOfObject:bannerView])];
    }
  }
  for (UIView *bannerView in self.bannerViews) {
    CGFloat topOfBanner = CGRectGetMinY(bannerView.frame);
    if (topOfBanner <= boundsTop) {
      [parallaxingIndicies removeObject:@([self.bannerViews indexOfObject:bannerView] - 1)];
    }
  }
  
  return [parallaxingIndicies copy];
}

#pragma mark Banners

- (void)loadBanners {
  UIView *bannerView1 = [[UIView alloc] init];
  bannerView1.backgroundColor = [UIColor whiteColor];
  [self addSubview:bannerView1];
  
  UIView *bannerView2 = [[UIView alloc] init];
  bannerView2.backgroundColor = [UIColor whiteColor];
  [self addSubview:bannerView2];
  
  UIView *bannerView3 = [[UIView alloc] init];
  bannerView3.backgroundColor = [UIColor whiteColor];
  [self addSubview:bannerView3];
  
  UIView *bannerView4 = [[UIView alloc] init];
  bannerView4.backgroundColor = [UIColor whiteColor];
  [self addSubview:bannerView4];
  
  self.bannerViews = @[bannerView1, bannerView2, bannerView3, bannerView4];
}

- (void)layoutBannerViews {
  CGSize bannerSize = [self bannerViewSize];
  for (int i = 0; i < [self.bannerViews count]; i++) {
    UIView *bannerView = self.bannerViews[i];
    bannerView.frame = [self frameForBannerViewAtIndex:i size:bannerSize];
  }
  self.bannersLaidOut = YES;
}

- (CGSize)bannerViewSize {
  return CGSizeMake(self.bounds.size.width, kBannerHeight);
}

- (CGRect)frameForBannerViewAtIndex:(NSUInteger)index size:(CGSize)size {
  CGRect frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
  CGFloat yOffset = (kBannerHeight + kParallaxWindowHeight) * index;
  return CGRectOffset(frame, 0.0f, yOffset);
}

#pragma mark Images

- (void)loadImages {
  PXWindowView *imageView4Container = [[PXWindowView alloc] initWithImageNamed:@"4.JPG"];
  [self addSubview:imageView4Container];
  
  PXWindowView *imageView3Container = [[PXWindowView alloc] initWithImageNamed:@"3.JPG"];
  [self addSubview:imageView3Container];
  
  PXWindowView *imageView2Container = [[PXWindowView alloc] initWithImageNamed:@"2.JPG"];
  [self addSubview:imageView2Container];
  
  PXWindowView *imageView1Container = [[PXWindowView alloc] initWithImageNamed:@"1.JPG"];
  [self addSubview:imageView1Container];
  
  self.windowViews = @[imageView1Container,
                      imageView2Container,
                      imageView3Container,
                      imageView4Container];
}

- (void)layoutImageViews {
  CGSize imageViewSize = self.bounds.size;
  for (int i = 0; i < [self.windowViews count]; i++) {
    PXWindowView *imageViewContainer = self.windowViews[i];
    imageViewContainer.frame = [self frameForImageViewAtIndex:i size:imageViewSize];
    UIImageView *imageView = imageViewContainer.imageView;
    imageView.frame = imageViewContainer.bounds;
    
    self.parallaxOrigins[i] = @(imageViewContainer.frame.origin.y);
  }
  self.imageViewsLaidOut = YES;
}

- (CGRect)frameForImageViewAtIndex:(NSUInteger)index size:(CGSize)size {
  CGRect frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
  CGFloat yOffset = ((kBannerHeight + kParallaxWindowHeight) * index) + kBannerHeight;
  return CGRectOffset(frame, 0.0f, yOffset);
}

@end
