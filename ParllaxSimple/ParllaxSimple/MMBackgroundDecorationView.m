#import "MMBackgroundDecorationView.h"

@interface MMBackgroundDecorationView ()
@property(nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation MMBackgroundDecorationView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor blackColor];
    [self installImageView];
  }
  return self;
}

- (void)installImageView {
  UIImage *image = [UIImage imageNamed:@"wood.jpg"];
  self.backgroundImageView = [[UIImageView alloc] initWithImage:image];
  self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
  [self addSubview:self.backgroundImageView];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.backgroundImageView.frame = self.bounds;
}

@end
