#import "PXCroppedImageContainerView.h"

@interface PXCroppedImageContainerView ()
//@property(nonatomic, assign, readwrite) CGRect windowBounds;
@property(nonatomic, strong, readwrite) UIImageView *imageView;
@property(nonatomic, assign) BOOL animating;
@end

@implementation PXCroppedImageContainerView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.clipsToBounds = YES;
    _imageViewScale = 6.0f;
    _imageView = [self newImageView];
    [self addSubview:_imageView];
    _animating = NO;
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

#pragma mark Animation

- (void)animateToImageViewScale:(CGFloat)imageViewScale
                   withDuration:(NSTimeInterval)duration
                     completion:(void (^)(BOOL finished))completion {
  self.animating = YES;
  PXCroppedImageContainerView __weak *weakSelf = self;
  [UIView animateWithDuration:duration
                   animations:^{
                     CGSize imageViewSize =
                        [self sizeForImageViewForScale:imageViewScale];
                     weakSelf.imageView.frame = CGRectMake(0.0f,
                                                           0.0f,
                                                           imageViewSize.width,
                                                           imageViewSize.height);
                     weakSelf.imageView.center = [self centerPointForImageView];
                   
                   }
                   completion:^(BOOL finished){
                     weakSelf.animating = NO;
                     completion(finished);
                   }];
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  if (CGRectEqualToRect(self.referenceFrame, CGRectZero)) {
    return;
  }
  if (self.animating) {
    return;
  }
  
  // TODO(rcacheaux): Should this be done only once??
  // TODO(rcacheaux): Think about caching these calcs.
  // Size.
  CGSize imageViewSize = [self sizeForImageViewForScale:self.imageViewScale];
  
  self.imageView.frame = CGRectMake(0.0f, 0.0f,
                                    imageViewSize.width, imageViewSize.height);
  // Position.
  CGPoint imageViewCenter = [self centerPointForImageView];
  self.imageView.center = imageViewCenter;
}

- (CGSize)sizeForImageViewForScale:(CGFloat)scale {
  CGSize imageViewSize = [self multiplySizeOfRect:self.referenceFrame
                                         byFactor:(scale * 3.0f)];
  if (imageViewSize.width < self.referenceFrame.size.width) {
    imageViewSize = self.referenceFrame.size;
  }
  return imageViewSize;
}

- (CGPoint)centerPointForImageView {
  return [self centerPointOfRect:self.referenceFrame];
}

- (CGPoint)centerPointOfRect:(CGRect)rect {
  CGFloat centerX = CGRectGetMidX(rect);
  CGFloat centerY = CGRectGetMidY(rect);
  return CGPointMake(centerX, centerY);
}

- (CGSize)multiplySizeOfRect:(CGRect)rect byFactor:(CGFloat)factor {
  CGFloat width = self.referenceFrame.size.width * factor;
  CGFloat height = self.referenceFrame.size.height * factor;
  return CGSizeMake(width, height);
}

#pragma mark Properties

- (void)setImageViewScale:(CGFloat)imageViewScale {
  _imageViewScale = imageViewScale;
  [self setNeedsLayout];
}

@end
