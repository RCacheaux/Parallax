#import "PXWindowView.h"

@interface PXWindowView ()
//@property(nonatomic, assign, readwrite) CGRect windowBounds;
@property(nonatomic, strong, readwrite) UIImageView *imageView;
@end

@implementation PXWindowView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.clipsToBounds = YES;
    _imageViewScale = 6.0f;
    _imageView = [self newImageView];
    [self addSubview:_imageView];
  }
  return self;
}

- (UIImageView *)newImageView {
  UIImageView *imageView = [[UIImageView alloc] init];
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  return imageView;
}

// TODO(rcacheaux): Clean up, legacy init method.
- (id)initWithImageNamed:(NSString *)imageNamed {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    self.clipsToBounds = YES;
    _imageView = [self newImageViewWithImageNamed:imageNamed];
    [self addSubview:_imageView];
  }
  return self;
}

// TODO(rcacheaux): Clean up, legacy load method.
- (UIImageView *)newImageViewWithImageNamed:(NSString *)imageNamed {
  UIImage *image = [UIImage imageNamed:imageNamed];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  return imageView;
}

- (void)setImageToImageNamed:(NSString *)imageNamed {
  UIImage *image = [UIImage imageNamed:imageNamed];
  self.imageView.image = image;
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  if (CGRectEqualToRect(self.windowBounds, CGRectZero)) {
    return;
  }
  
  // TODO(rcacheaux): Should this be done only once??
  // TODO(rcacheaux): Think about caching these calcs.
  // Size.
  CGSize imageViewSize = [self multiplySizeOfRect:self.windowBounds
                                         byFactor:(self.imageViewScale * 2.0f)];
  self.imageView.frame = CGRectMake(0.0f, 0.0f,
                                    imageViewSize.width, imageViewSize.height);
  // Position.
  CGPoint imageViewCenter = [self centerPointOfRect:self.windowBounds];
  self.imageView.center = imageViewCenter;
}

- (CGPoint)centerPointOfRect:(CGRect)rect {
  CGFloat centerX = CGRectGetMidX(rect);
  CGFloat centerY = CGRectGetMidY(rect);
  return CGPointMake(centerX, centerY);
}

- (CGSize)multiplySizeOfRect:(CGRect)rect byFactor:(CGFloat)factor {
  CGFloat width = self.windowBounds.size.width * factor;
  CGFloat height = self.windowBounds.size.height * factor;
  return CGSizeMake(width, height);
}

#pragma mark Properties

- (void)setImageViewScale:(CGFloat)imageViewScale {
  _imageViewScale = imageViewScale;
  [self setNeedsLayout];
}

@end
