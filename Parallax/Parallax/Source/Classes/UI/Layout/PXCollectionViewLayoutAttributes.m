#import "PXCollectionViewLayoutAttributes.h"

@implementation PXCollectionViewLayoutAttributes

- (id)init {
  self = [super init];
  if (self) {
    _parallaxWindowImageScaleFactor = 1.0f;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  PXCollectionViewLayoutAttributes *layoutAttributes = [super copyWithZone:zone];
  layoutAttributes.parallaxWindowImageScaleFactor = self.parallaxWindowImageScaleFactor;
  return layoutAttributes;
}

@end
