#import "PXParallaxWindowCollectionViewCell.h"

#import "PXWindowView.h"

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

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  self.windowView.frame = self.contentView.bounds;
}

@end
