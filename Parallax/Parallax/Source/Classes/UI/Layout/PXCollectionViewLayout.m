#import "PXCollectionViewLayout.h"

#import "PXCollectionViewLayoutAttributes.h"

@interface PXCollectionViewLayout ()
@property(nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, strong) NSMutableArray *parallaxWindowsLayoutAttributes;
@property(nonatomic, strong) NSMutableArray *bannersLayoutAttributes;
@property(nonatomic, strong) NSMutableArray *parallaxingWindowIndicies;
@end

@implementation PXCollectionViewLayout

+ (Class)layoutAttributesClass {
  return [PXCollectionViewLayoutAttributes class];
}

- (id)init {
  self = [super init];
  if (self) {
    _pinchedCellScale = 1.0f;
  }
  return self;
}

- (void)prepareLayout {
  [super prepareLayout];
  // TODO(rcacheaux): Check that there is only ONE cell defined in each section.
  // TODO(rcacheaux): Check if attributes have already been calculated.
  [self clearOutLayoutCalculations];
  self.contentHeight = 0.0f;
  NSUInteger numberOfSections =
      [self.collectionView.dataSource
       numberOfSectionsInCollectionView:self.collectionView];
  for (int i = 0; i < numberOfSections; i++) {
    [self prepareLayoutForBannerViewInSection:i];
  }
  [self updateParallazingWindowIndicies];
//  self.contentHeight = 0.0f;
  for (int i = 0; i < numberOfSections; i++) {
    [self prepareLayoutForParallaxWindowInSection:i];
  }
}

- (void)prepareLayoutForBannerViewInSection:(NSUInteger)section {
  // TODO(rcacheaux): Checked cast.
  id<PXCollectionViewDelegate> delegate =
      (id<PXCollectionViewDelegate>)self.collectionView.delegate;
  CGFloat contentWidth = self.collectionView.frame.size.width;
  
  CGFloat bannerHeight = [delegate collectionView:self.collectionView
                                             layout:self
                                  heightForBannerInSection:section];
  // Banner Layout attributes.
  PXCollectionViewLayoutAttributes *bannerAttributes =
      [PXCollectionViewLayoutAttributes
       layoutAttributesForSupplementaryViewOfKind:kPXBannerSupplementaryViewKind
                                    withIndexPath:[NSIndexPath
                                 indexPathForItem:0 inSection:section]];
  bannerAttributes.frame = CGRectMake(0.0f, self.contentHeight,
                                      contentWidth, bannerHeight);
  bannerAttributes.zIndex = 1;
  self.bannersLayoutAttributes[section] = bannerAttributes;
  self.contentHeight += (bannerHeight + self.parallaxWindowHeight);
}

- (void)prepareLayoutForParallaxWindowInSection:(NSUInteger)section {
  PXCollectionViewLayoutAttributes *parallaxWindowAttributes =
      [PXCollectionViewLayoutAttributes
       layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:0
                                                                inSection:section]];
  if ([self isParallaxingSection:section]) {
    [self configureLayoutAttributesForParallaxingWindowInSection:section
                                              layoutAttributes:parallaxWindowAttributes];
  } else {
    parallaxWindowAttributes.frame = CGRectZero;
  }
  
  [self applyPinchToLayoutAttributes:parallaxWindowAttributes];
  self.parallaxWindowsLayoutAttributes[section] = parallaxWindowAttributes;
}

-(void)applyPinchToLayoutAttributes:(PXCollectionViewLayoutAttributes*)layoutAttributes {
  if ([layoutAttributes.indexPath isEqual:self.pinchedCellPath]) {
//    layoutAttributes.transform3D = CATransform3DMakeScale(self.pinchedCellScale, self.pinchedCellScale, 1.0);
//    layoutAttributes.center = self.pinchedCellCenter;
//    layoutAttributes.zIndex = 1;
    layoutAttributes.parallaxWindowImageScaleFactor = self.pinchedCellScale;
  }
}

// Parallaxing Magic is here.
- (void)configureLayoutAttributesForParallaxingWindowInSection:(NSUInteger)section
                  layoutAttributes:(PXCollectionViewLayoutAttributes *)layoutAttributes {
  PXCollectionViewLayoutAttributes *thisWindowsBannerLayoutAttributes =
        self.bannersLayoutAttributes[section];
    
    CGFloat bottomOfBounds = CGRectGetMaxY(self.collectionView.bounds);
    CGRect newImageFrame = CGRectMake(0.0f,
                                      (bottomOfBounds - self.collectionView.bounds.size.height),
                                      self.collectionView.bounds.size.width,
                                      self.collectionView.bounds.size.height);
    // If there's a next banner.
    if (section < [self.bannersLayoutAttributes count] - 1) {
      PXCollectionViewLayoutAttributes *nextWindowsBannerLayoutAttributes =
          self.bannersLayoutAttributes[section + 1];
      CGRect nextBannerFrame = nextWindowsBannerLayoutAttributes.frame;
      // Crop if necessary.
      if (CGRectGetMaxY(newImageFrame) > CGRectGetMaxY(nextBannerFrame)) {
        CGFloat amountToCrop =
            CGRectGetMaxY(newImageFrame) - CGRectGetMaxY(nextBannerFrame);
        newImageFrame.size.height -= amountToCrop;
      }
    }
    
    CGRect currentBannerFrame = thisWindowsBannerLayoutAttributes.frame;
    CGFloat nextPossibleBannerXOrigin =
        CGRectGetMaxY(currentBannerFrame) + self.parallaxWindowHeight;
    CGFloat parallaxWholeHeight =
        (nextPossibleBannerXOrigin + self.collectionView.bounds.size.height);
    parallaxWholeHeight -= CGRectGetMaxY(currentBannerFrame);
    CGFloat percentParallax =
        (bottomOfBounds - CGRectGetMaxY(currentBannerFrame)) / parallaxWholeHeight;
    CGFloat parallaxRange = self.parallaxOffset * 2;
    CGFloat parallaxCurrentOffset =
        self.parallaxOffset - (parallaxRange * percentParallax);
    // Apply parallax.
    newImageFrame.origin.y += parallaxCurrentOffset;
    
    layoutAttributes.frame = newImageFrame;
    layoutAttributes.zIndex = -1 * section;
}

- (BOOL)isParallaxingSection:(NSUInteger)section {
  if ([self.parallaxingWindowIndicies containsObject:@(section)]) {
    return YES;
  }
  return NO;
}

// Assuming collection view will always start from the very top.
// TODO(rcacheaux): Optimize following method.
- (void)updateParallazingWindowIndicies {
  CGFloat bottomOfBounds = CGRectGetMaxY(self.collectionView.bounds);
  CGFloat topOfBounds = CGRectGetMinY(self.collectionView.bounds);
  
  NSMutableArray *parallaxingIndicies = [NSMutableArray array];
  // Look for Parallaxing.
  for (int i = 0; i < [self.bannersLayoutAttributes count]; i++) {
    PXCollectionViewLayoutAttributes *bannerLayoutAttributes =
        self.bannersLayoutAttributes[i];
    CGFloat bottomOfBanner = CGRectGetMaxY(bannerLayoutAttributes.frame);
    if (bottomOfBanner <= bottomOfBounds) {
      [parallaxingIndicies addObject:@(i)];
    }
  }
  for (int i = 0; i < [self.bannersLayoutAttributes count]; i++) {
    PXCollectionViewLayoutAttributes *bannerLayoutAttributes =
        self.bannersLayoutAttributes[i];
    CGFloat topOfBanner = CGRectGetMinY(bannerLayoutAttributes.frame);
    if (topOfBanner <= topOfBounds) {
      [parallaxingIndicies removeObject:@(i - 1)];
    }
  }
  self.parallaxingWindowIndicies = parallaxingIndicies;
}

- (CGSize)collectionViewContentSize {
  return CGSizeMake(self.collectionView.frame.size.width, self.contentHeight);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *layoutAttributesInRect = [NSMutableArray array];
  // Parallax Windows.
  for (PXCollectionViewLayoutAttributes *layoutAttributes in
       self.parallaxWindowsLayoutAttributes) {
    if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
      [layoutAttributesInRect addObject:layoutAttributes];
    }
  }
  // Banners.
  for (PXCollectionViewLayoutAttributes *layoutAttributes in
       self.bannersLayoutAttributes) {
    if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
      [layoutAttributesInRect addObject:layoutAttributes];
    }
  }
  return [layoutAttributesInRect copy];
}

- (PXCollectionViewLayoutAttributes *)
    layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSAssert(indexPath.item == 0,
           @"This layout does not support sections with more than one cell.");
  
  PXCollectionViewLayoutAttributes *layoutAttributes =
      self.parallaxWindowsLayoutAttributes[indexPath.section];
  return layoutAttributes;
}

/*
- (PXCollectionViewLayoutAttributes *)
    layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                atIndexPath:(NSIndexPath *)indexPath {
  return nil;
}
*/

- (PXCollectionViewLayoutAttributes *)
    layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                   atIndexPath:(NSIndexPath *)indexPath {
  PXCollectionViewLayoutAttributes *layoutAttributes =
      self.bannersLayoutAttributes[indexPath.section];
  return layoutAttributes;
}

- (void)invalidateLayout {
  [super invalidateLayout];
  // Trash calculations.
  [self clearOutLayoutCalculations];
}

- (void)clearOutLayoutCalculations {
  self.bannersLayoutAttributes = [NSMutableArray array];
  self.parallaxWindowsLayoutAttributes = [NSMutableArray array];
  self.parallaxingWindowIndicies = [NSMutableArray array];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return YES;
}

#pragma mark Properties

- (void)setParallaxWindowHeight:(CGFloat)parallaxWindowHeight {
  _parallaxWindowHeight = parallaxWindowHeight;
  [self invalidateLayout];
}

- (void)setParallaxOffset:(CGFloat)parallaxOffset {
  _parallaxOffset = parallaxOffset;
  [self invalidateLayout];
}

-(void)setPinchedCellScale:(CGFloat)scale {
  _pinchedCellScale = scale;
  [self invalidateLayout];
}

- (void)setPinchedCellCenter:(CGPoint)center {
  _pinchedCellCenter = center;
  [self invalidateLayout];
}

@end
