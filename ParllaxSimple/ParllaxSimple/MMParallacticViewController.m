#import "MMParallacticViewController.h"

#import "MMParallacticCell.h"

static NSString * const kCellReuseID = @"CELL";

@implementation MMParallacticViewController

-(void)viewDidLoad {
  [self.collectionView registerClass:[MMParallacticCell class]
          forCellWithReuseIdentifier:kCellReuseID];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 200.0f;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
  cell.backgroundColor = [UIColor redColor];
  cell.layer.borderWidth = 1.0f;
  cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
  return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsMake(40.0f, 40.0f, 40.0f, 40.0f);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}


@end
