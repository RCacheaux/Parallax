#import <UIKit/UIKit.h>

@class PXCroppedImageContainerView;

@interface PXCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong, readonly) PXCroppedImageContainerView *imageContainerView;

- (void)setWindowImageToImageNamed:(NSString *)imageNamed;

@end
