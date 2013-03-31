#import <UIKit/UIKit.h>

static NSString * const kPXBannerSupplementaryViewKind = @"PXBanner";

@protocol PXCollectionViewDelegate <UICollectionViewDelegate>
@optional

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
        heightForBannerInSection:(NSInteger)section;

@end

@interface PXCollectionViewLayout : UICollectionViewLayout

@property(nonatomic, assign) CGFloat parallaxWindowHeight;

@end
