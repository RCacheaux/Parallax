#import "MMParallacticFlowLayout.h"

#import "MMBackgroundDecorationView.h"

static NSString * const kDecorationViewID = @"D";

@implementation MMParallacticFlowLayout

- (id)init {
  self = [super init];
  if (self) {
    [self registerClass:[MMBackgroundDecorationView class] forDecorationViewOfKind:kDecorationViewID];
  }
  return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *allLayoutAttributes =
      [[NSMutableArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect]];
  
  // Cells.
  NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
  
  for (NSInteger i = 0; i < numberOfItems; i++) {
    
    // Grab original and remove if included in all layout attributes.
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
    UICollectionViewLayoutAttributes *originalLayoutAtrributes =
        [self layoutAttributesIn:allLayoutAttributes atIndexPath:indexPath];
    [allLayoutAttributes removeObject:originalLayoutAtrributes];
    
    // Get a new layout attributes object.
    UICollectionViewLayoutAttributes *layoutAttributes =
        [self layoutAttributesForItemAtIndexPath:indexPath];
    
    // Add it to the return array if in rect or below content bounds.
    if (CGRectIntersectsRect(rect, layoutAttributes.frame)) {
      [allLayoutAttributes addObject:layoutAttributes];
    }
    else if (self.collectionView.contentSize.height < CGRectGetMinY(layoutAttributes.frame)) {
      [allLayoutAttributes addObject:layoutAttributes];
    }
  
  }

  // Decorarion View.
  NSIndexPath *indexPathZero = [NSIndexPath indexPathWithIndex:0];
  // Get layout attributes for background.
  UICollectionViewLayoutAttributes *backgroundViewLayoutAttributes =
      [self layoutAttributesForDecorationViewOfKind:kDecorationViewID atIndexPath:indexPathZero];
  // Test if in rect.
  if (CGRectIntersectsRect(rect, backgroundViewLayoutAttributes.frame)) {
    [allLayoutAttributes addObject:backgroundViewLayoutAttributes];
  }
  
  return [allLayoutAttributes copy];
}


- (UICollectionViewLayoutAttributes *)
    layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                atIndexPath:(NSIndexPath *)indexPath {
  // Create a new layout attributes instance.
  UICollectionViewLayoutAttributes *decorationViewLayoutAttributes =
      [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind
                                                                  withIndexPath:indexPath];
  
  // Calculate parallactic offset.
  CGFloat parallaxShift = 6.0;
  CGFloat offset = ([self scrollPercentageComplete] * (2 * parallaxShift)) - parallaxShift;
  
  // Anchor frame and apply offset to anchored frame
  decorationViewLayoutAttributes.frame = CGRectOffset(self.collectionView.bounds, 0, offset);
  
  // Resize Backgound so top/bottom edges don't show.
  decorationViewLayoutAttributes.frame = CGRectInset(decorationViewLayoutAttributes.frame,
                                                     0.0f,
                                                     -50.0f);
  // Put the background way way back.
  decorationViewLayoutAttributes.zIndex = -1000000;
  
  return decorationViewLayoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return YES;
}


- (CGFloat)scrollPercentageComplete {
  CGFloat percentageComplete =
      self.collectionView.contentOffset.y /
      (self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
  return percentageComplete;
}


- (void)parallaxedLayoutAttributesAtIndexPath:(NSIndexPath *)indexPath
                                    fromArray:(NSMutableArray *)allLayoutAttributes
                                       zIndex:(NSInteger)zIndex {
  UICollectionViewLayoutAttributes *cellAttributes =
      [self layoutAttributesIn:allLayoutAttributes atIndexPath:indexPath];
  if (!cellAttributes) {
    cellAttributes =
        [self layoutAttributesForItemAtIndexPath:indexPath];
    [allLayoutAttributes addObject:cellAttributes];
  }
  
  [self anchorItemWithLayoutAttributes:cellAttributes];
  [self parallaxItemWithLayoutAttributes:cellAttributes zIndex:zIndex];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *layoutAttributes =
      [super layoutAttributesForItemAtIndexPath:indexPath];
  
  // Determine z Index for cell.
  NSInteger zIndex = -1;
  NSInteger itemIndex = indexPath.item;
  if (itemIndex % 3 == 1) {
    zIndex = -16;
  } else if(itemIndex % 3 == 2) {
    zIndex = -32;
  }
  
  if (zIndex < 0) {
    // Anchor and parallax if negative z.
    [self anchorItemWithLayoutAttributes:layoutAttributes];
    [self parallaxItemWithLayoutAttributes:layoutAttributes zIndex:zIndex];
  }
  return layoutAttributes;
}

- (void)anchorItemWithLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
  layoutAttributes.frame = CGRectOffset(layoutAttributes.frame,
                                        0.0f, self.collectionView.contentOffset.y);
}

- (void)parallaxItemWithLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
                                  zIndex:(NSInteger)zIndex {
  if (zIndex == 0) {
    return;
  }
  
  // Calculate current parallax offset.
  CGFloat rateOfParallax = 700.0f;
  CGFloat percentageComplete = self.collectionView.contentOffset.y / rateOfParallax;
  NSInteger absoluteZIndex = abs(zIndex);
  CGFloat offset =
      percentageComplete * (self.collectionView.bounds.size.height / absoluteZIndex);
  
  // Apply parallactic shift.
  layoutAttributes.frame = CGRectOffset(layoutAttributes.frame, 0.0f, -offset);
  
  // Resize cell.
  layoutAttributes.frame = CGRectInset(layoutAttributes.frame,
                                       MIN(layoutAttributes.frame.size.width, absoluteZIndex),
                                       MIN(layoutAttributes.frame.size.height, absoluteZIndex));
  
  // Apply Z Index.
  layoutAttributes.zIndex = zIndex;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesIn:(NSArray *)layoutAttributesArray
                                             atIndexPath:(NSIndexPath *)indexPath {
  for (UICollectionViewLayoutAttributes *layoutAttributes in layoutAttributesArray) {
    if ([layoutAttributes.indexPath isEqual:indexPath]) {
      return layoutAttributes;
    }
  }
  return nil;
}

- (CGSize)collectionViewContentSize {
  CGSize originalSize = [super collectionViewContentSize];
  return originalSize;
}

@end
