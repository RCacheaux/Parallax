#import "PXBannerView.h"

@interface PXBannerView ()
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *label;
@end

@implementation PXBannerView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    _imageView = [self newImageView];
    [self addSubview:_imageView];
    _label = [self newLabel];
    //[self addSubview:_label];
  }
  return self;
}

- (UIImageView *)newImageView {
  UIImageView *imageView = [[UIImageView alloc] init];
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  imageView.backgroundColor = [UIColor clearColor];
  return imageView;
}

- (UILabel *)newLabel {
  UILabel *label = [[UILabel alloc] init];
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont boldSystemFontOfSize:50.0f];
  label.textAlignment = NSTextAlignmentLeft;
  label.text = @"The Rainforest";
  label.backgroundColor = [UIColor clearColor];
  return label;
}

- (void)setImageToImageNamed:(NSString *)imageNamed {
  UIImage *image = [UIImage imageNamed:imageNamed];
  self.imageView.image = image;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.imageView.frame =
      CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
  self.label.frame = self.bounds;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.imageView.image = nil;
}


@end
