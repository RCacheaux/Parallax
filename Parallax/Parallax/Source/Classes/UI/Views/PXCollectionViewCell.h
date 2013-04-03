#import <UIKit/UIKit.h>

@class PXCroppedImageContainerView;

@interface PXCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong, readonly) PXCroppedImageContainerView *windowView;

- (void)setWindowImageToImageNamed:(NSString *)imageNamed;

@end
