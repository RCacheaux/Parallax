#import <UIKit/UIKit.h>

@interface PXCroppedImageContainerView : UIView

@property(nonatomic, assign) CGRect referenceFrame;
@property(nonatomic, strong, readonly) UIImageView *imageView;
@property(nonatomic, assign) CGFloat imageViewScale;

- (id)initWithImageNamed:(NSString *)imageNamed;
- (void)setImageToImageNamed:(NSString *)imageNamed;
- (void)animateToImageViewScale:(CGFloat)imageViewScale
                   withDuration:(NSTimeInterval)duration
                     completion:(void (^)(BOOL finished))completion;
@end
