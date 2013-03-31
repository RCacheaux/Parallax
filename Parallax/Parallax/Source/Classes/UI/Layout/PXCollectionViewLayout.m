#import "PXCollectionViewLayout.h"

@interface PXCollectionViewLayout ()
@property(nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, strong) NSMutableArray *parallaxWindowsLayoutAttributes;
@property(nonatomic, strong) NSMutableArray *bannersLayoutAttributes;
@property(nonatomic, strong) NSMutableArray *parallaxingWindowIndicies;
@end

@implementation PXCollectionViewLayout

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
  self.contentHeight = 0.0f;
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
  UICollectionViewLayoutAttributes *bannerAttributes =
      [UICollectionViewLayoutAttributes
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
  id<PXCollectionViewDelegate> delegate =
      (id<PXCollectionViewDelegate>)self.collectionView.delegate;
  CGFloat bannerHeight = [delegate collectionView:self.collectionView
                                             layout:self
                                  heightForBannerInSection:section];
  self.contentHeight += bannerHeight;
  CGFloat contentWidth = self.collectionView.frame.size.width;
  CGFloat parallaxWindowHeight = self.parallaxWindowHeight;
  
  // Window Parallax Layout Attributes.
  UICollectionViewLayoutAttributes *parallaxWindowAttributes =
  [UICollectionViewLayoutAttributes
   layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:0
                                                            inSection:section]];
  CGFloat centerX = contentWidth / 2.0f;
  CGFloat centerY = self.contentHeight + (self.parallaxWindowHeight / 2.0f);
  parallaxWindowAttributes.center = CGPointMake(centerX, centerY);
  parallaxWindowAttributes.size = self.collectionView.bounds.size;
  parallaxWindowAttributes.zIndex = -1 * section;
  
  self.parallaxWindowsLayoutAttributes[section] = parallaxWindowAttributes;
  
  self.contentHeight += parallaxWindowHeight;
}

// Assuming collection view will always start from the very top.
// TODO(rcacheaux): Optimize following method.
- (void)updateParallazingWindowIndicies {
  CGFloat bottomOfBounds = CGRectGetMaxY(self.collectionView.bounds);
  CGFloat topOfBounds = CGRectGetMinY(self.collectionView.bounds);
  
  NSMutableArray *parallaxingIndicies = [NSMutableArray array];
  // Look for Parallaxing.
  for (int i = 0; i < [self.bannersLayoutAttributes count]; i++) {
    UICollectionViewLayoutAttributes *bannerLayoutAttributes =
        self.bannersLayoutAttributes[i];
    CGFloat bottomOfBanner = CGRectGetMaxY(bannerLayoutAttributes.frame);
    if (bottomOfBanner <= bottomOfBounds) {
      [parallaxingIndicies addObject:@(i)];
    }
  }
  for (int i = 0; i < [self.bannersLayoutAttributes count]; i++) {
    UICollectionViewLayoutAttributes *bannerLayoutAttributes =
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
  for (UICollectionViewLayoutAttributes *layoutAttributes in
       self.parallaxWindowsLayoutAttributes) {
    if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
      [layoutAttributesInRect addObject:layoutAttributes];
    }
  }
  // Banners.
  for (UICollectionViewLayoutAttributes *layoutAttributes in
       self.bannersLayoutAttributes) {
    if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
      [layoutAttributesInRect addObject:layoutAttributes];
    }
  }
  return [layoutAttributesInRect copy];
}

- (UICollectionViewLayoutAttributes *)
    layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSAssert(indexPath.item == 0,
           @"This layout does not support sections with more than one cell.");
  
  UICollectionViewLayoutAttributes *layoutAttributes =
      self.parallaxWindowsLayoutAttributes[indexPath.section];
  return layoutAttributes;
}

/*
- (UICollectionViewLayoutAttributes *)
    layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                atIndexPath:(NSIndexPath *)indexPath {
  return nil;
}
*/

- (UICollectionViewLayoutAttributes *)
    layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                   atIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *layoutAttributes =
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

@end
