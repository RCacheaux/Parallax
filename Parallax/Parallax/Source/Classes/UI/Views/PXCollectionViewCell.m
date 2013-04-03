#import "PXCollectionViewCell.h"

#import "PXCroppedImageContainerView.h"
#import "PXCollectionViewLayoutAttributes.h"

@interface PXCollectionViewCell ()
@property(nonatomic, strong, readwrite) PXCroppedImageContainerView *imageContainerView;
@end

@implementation PXCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _imageContainerView = [self newCroppedImageContainerView];
    [self.contentView addSubview:_imageContainerView];
  }
  return self;
}

- (PXCroppedImageContainerView *)newCroppedImageContainerView {
  PXCroppedImageContainerView *containerView = [[PXCroppedImageContainerView alloc] init];
  return containerView;
}

- (void)setWindowImageToImageNamed:(NSString *)imageNamed {
  [self.imageContainerView setImageToImageNamed:imageNamed];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
  [super applyLayoutAttributes:layoutAttributes];
  PXCollectionViewLayoutAttributes *attributes =
      (PXCollectionViewLayoutAttributes *)layoutAttributes;
  self.imageContainerView.imageViewScale = attributes.parallaxWindowImageScaleFactor;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.imageContainerView.imageView.image = nil;
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  self.imageContainerView.frame = self.contentView.bounds;
}

@end
