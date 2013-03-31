#import <UIKit/UIKit.h>

@class PXWindowView;

@interface PXParallaxWindowCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong, readonly) PXWindowView *windowView;

- (void)setWindowImageToImageNamed:(NSString *)imageNamed;

@end
