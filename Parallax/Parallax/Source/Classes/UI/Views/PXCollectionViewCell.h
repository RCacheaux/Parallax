#import <UIKit/UIKit.h>

@class PXCroppedImageContainerView;

@interface PXCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong, readonly) PXCroppedImageContainerView *imageContainerView;

- (void)setImageToImageNamed:(NSString *)imageNamed;

@end
