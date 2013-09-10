#import "MMParallacticCell.h"

@interface MMParallacticCell ()
@property(nonatomic, strong) UIView *dimmingView;
@end

@implementation MMParallacticCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _dimmingView = [UIView new];
    _dimmingView.backgroundColor = [UIColor blackColor];
    _dimmingView.alpha = 0.0f;
    [self.contentView addSubview:_dimmingView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.dimmingView.frame = self.contentView.bounds;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
  [super applyLayoutAttributes:layoutAttributes];
  if (layoutAttributes.zIndex < -1) {
    self.dimmingView.alpha = MIN(abs(layoutAttributes.zIndex)/60.0f, 1.0f);
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.dimmingView.alpha = 0.0f;
}

@end
