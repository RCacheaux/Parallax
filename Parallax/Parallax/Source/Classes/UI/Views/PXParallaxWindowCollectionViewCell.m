#import "PXParallaxWindowCollectionViewCell.h"

#import "PXWindowView.h"
#import "PXCollectionViewLayoutAttributes.h"

@interface PXParallaxWindowCollectionViewCell ()
@property(nonatomic, strong, readwrite) PXWindowView *windowView;
@end

@implementation PXParallaxWindowCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _windowView = [self newWindowView];
    [self.contentView addSubview:_windowView];
  }
  return self;
}

- (PXWindowView *)newWindowView {
  PXWindowView *windowView = [[PXWindowView alloc] init];
  return windowView;
}

- (void)setWindowImageToImageNamed:(NSString *)imageNamed {
  [self.windowView setImageToImageNamed:imageNamed];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
  [super applyLayoutAttributes:layoutAttributes];
  PXCollectionViewLayoutAttributes *attributes =
      (PXCollectionViewLayoutAttributes *)layoutAttributes;
  self.windowView.imageViewScale = attributes.parallaxWindowImageScaleFactor;
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  self.windowView.frame = self.contentView.bounds;
}

@end
