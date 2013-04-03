#import "PXCollectionViewLayout.h"

#import "PXCollectionViewLayoutAttributes.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

static CGFloat kPXCellExpansionBannerOffset = 80.0f;

@interface PXCollectionViewLayout ()
@property(nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, strong) NSMutableArray *parallaxCellsLayoutAttributes;
@property(nonatomic, strong) NSMutableArray *bannersLayoutAttributes;
@property(nonatomic, strong) NSMutableArray *parallaxingCellIndicies;
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
  [self updateParallaxingCellIndicies];
  for (int i = 0; i < numberOfSections; i++) {
    [self prepareLayoutForParallaxCellInSection:i];
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
  
  if (self.expandedCellPath) {
    if (section == self.expandedCellPath.section) {
      bannerAttributes.frame = CGRectOffset(bannerAttributes.frame,
                                            0.0f,
                                            -kPXCellExpansionBannerOffset);
    } else if (section == (self.expandedCellPath.section + 1)) {
      bannerAttributes.frame = CGRectOffset(bannerAttributes.frame,
                                            0.0f,
                                            kPXCellExpansionBannerOffset);
    }
  } else {
    [self applyPinchToBannerLayoutAttributes:bannerAttributes];
  }
  
  self.bannersLayoutAttributes[section] = bannerAttributes;
  self.contentHeight += (bannerHeight + self.parallaxVisibleHeight);
}

-(void)applyPinchToBannerLayoutAttributes:
    (PXCollectionViewLayoutAttributes*)layoutAttributes {
    if (layoutAttributes.indexPath.section == self.pinchedCellPath.section) {
      CGRect bannerFrame = layoutAttributes.frame;
          layoutAttributes.frame =
              CGRectOffset(bannerFrame,
                           0.0f,
                           (-kPXCellExpansionBannerOffset * (1 - self.pinchedCellScale)));
    } else if (layoutAttributes.indexPath.section == (self.pinchedCellPath.section + 1)) {
      CGRect bannerFrame = layoutAttributes.frame;
      layoutAttributes.frame =
          CGRectOffset(bannerFrame,
                       0.0f,
                       (kPXCellExpansionBannerOffset * (1 - self.pinchedCellScale)));
    }
}

- (void)prepareLayoutForParallaxCellInSection:(NSUInteger)section {
  PXCollectionViewLayoutAttributes *parallaxCellAttributes =
      [PXCollectionViewLayoutAttributes
       layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:0
                                                                inSection:section]];
  if ([self isParallaxingSection:section]) {
    [self configureLayoutAttributesForParallaxingCellInSection:section
                                              layoutAttributes:parallaxCellAttributes];
    if (self.expandedCellPath) {
      if ([self.expandedCellPath isEqual:parallaxCellAttributes.indexPath]) {
        parallaxCellAttributes.parallaxImageScaleFactor = 0.0f;
      }
    }
  } else {
    parallaxCellAttributes.frame = CGRectZero;
  }  
  
  [self applyPinchToLayoutAttributes:parallaxCellAttributes];
  self.parallaxCellsLayoutAttributes[section] = parallaxCellAttributes;
}

// Parallaxing Magic is here.
- (void)configureLayoutAttributesForParallaxingCellInSection:(NSUInteger)section
                  layoutAttributes:(PXCollectionViewLayoutAttributes *)layoutAttributes {
  PXCollectionViewLayoutAttributes *thisCellsBannerLayoutAttributes =
        self.bannersLayoutAttributes[section];
  
  // Anchor.
  CGFloat bottomOfBounds = CGRectGetMaxY(self.collectionView.bounds);
  CGRect newImageFrame = CGRectMake(0.0f,
                                    (bottomOfBounds - self.collectionView.bounds.size.height),
                                    self.collectionView.bounds.size.width,
                                    self.collectionView.bounds.size.height);
  // Crop.
  // If there's a next banner.
  if (section < [self.bannersLayoutAttributes count] - 1) {
    PXCollectionViewLayoutAttributes *nextCellsBannerLayoutAttributes =
        self.bannersLayoutAttributes[section + 1];
    CGRect nextBannerFrame = nextCellsBannerLayoutAttributes.frame;
    // Crop if necessary.
    if (CGRectGetMaxY(newImageFrame) > CGRectGetMaxY(nextBannerFrame)) {
      CGFloat amountToCrop =
          CGRectGetMaxY(newImageFrame) - CGRectGetMaxY(nextBannerFrame);
      newImageFrame.size.height -= amountToCrop;
    }
  }
  
  // Parallax.
  CGRect currentBannerFrame = thisCellsBannerLayoutAttributes.frame;
  CGFloat nextPossibleBannerYOrigin =
      CGRectGetMaxY(currentBannerFrame) + self.parallaxVisibleHeight;
  CGFloat parallaxWholeHeight =
      (nextPossibleBannerYOrigin + self.collectionView.bounds.size.height);
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
  if ([self.parallaxingCellIndicies containsObject:@(section)]) {
    return YES;
  }
  return NO;
}

-(void)applyPinchToLayoutAttributes:(PXCollectionViewLayoutAttributes*)layoutAttributes {
  if ([layoutAttributes.indexPath isEqual:self.pinchedCellPath]) {
    layoutAttributes.parallaxImageScaleFactor = self.pinchedCellScale;
  }
}

// Assuming collection view will always start from the very top.
// TODO(rcacheaux): Optimize following method.
- (void)updateParallaxingCellIndicies {
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
  self.parallaxingCellIndicies = parallaxingIndicies;
}

- (CGSize)collectionViewContentSize {
  return CGSizeMake(self.collectionView.frame.size.width, self.contentHeight);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *layoutAttributesInRect = [NSMutableArray array];
  // Parallax Cells.
  for (PXCollectionViewLayoutAttributes *layoutAttributes in
       self.parallaxCellsLayoutAttributes) {
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
      self.parallaxCellsLayoutAttributes[indexPath.section];
  return layoutAttributes;
}

- (PXCollectionViewLayoutAttributes *)
    layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                   atIndexPath:(NSIndexPath *)indexPath {
  PXCollectionViewLayoutAttributes *layoutAttributes =
      self.bannersLayoutAttributes[indexPath.section];
  return layoutAttributes;
}

- (void)invalidateLayout {
  [super invalidateLayout];
  [self clearOutLayoutCalculations];
}

- (void)clearOutLayoutCalculations {
  self.bannersLayoutAttributes = [NSMutableArray array];
  self.parallaxCellsLayoutAttributes = [NSMutableArray array];
  self.parallaxingCellIndicies = [NSMutableArray array];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return YES;
}

#pragma mark Properties

- (void)setParallaxVisibleHeight:(CGFloat)parallaxVisibleHeight {
  _parallaxVisibleHeight = parallaxVisibleHeight;
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
