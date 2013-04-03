#import "PXCollectionViewCell.h"

#import "PXCroppedImageContainerView.h"
#import "PXCollectionViewLayoutAttributes.h"

@interface PXCollectionViewCell ()
@property(nonatomic, strong, readwrite) PXCroppedImageContainerView *windowView;
@end

@implementation PXCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _windowView = [self newWindowView];
    [self.contentView addSubview:_windowView];
  }
  return self;
}

- (PXCroppedImageContainerView *)newWindowView {
  PXCroppedImageContainerView *windowView = [[PXCroppedImageContainerView alloc] init];
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

- (void)prepareForReuse {
  [super prepareForReuse];
  self.windowView.imageView.image = nil;
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  self.windowView.frame = self.contentView.bounds;
}

@end
