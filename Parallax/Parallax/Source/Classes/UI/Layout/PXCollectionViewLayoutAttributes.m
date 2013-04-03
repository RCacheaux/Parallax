#import "PXCollectionViewLayoutAttributes.h"

@implementation PXCollectionViewLayoutAttributes

- (id)init {
  self = [super init];
  if (self) {
    _parallaxImageScaleFactor = 1.0f;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  PXCollectionViewLayoutAttributes *layoutAttributes = [super copyWithZone:zone];
  layoutAttributes.parallaxImageScaleFactor = self.parallaxImageScaleFactor;
  return layoutAttributes;
}

@end
