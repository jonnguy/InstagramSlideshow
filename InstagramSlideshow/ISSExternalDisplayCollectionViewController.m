//
//  ISSExternalDisplayCollectionViewController.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSExternalDisplayCollectionViewController.h"
#import "ISSImageCollectionViewCell.h"
#import "ISSTransitioningDelegate.h"
#import "ISSViewImageViewController.h"
#import "ISSExternalDisplayCollectionViewController.h"

#import "ISSDismissalAnimator.h"
#import "ISSPresentationAnimator.h"

@interface ISSExternalDisplayCollectionViewController () <UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIStoryboard *mainStoryboard;
@property (nonatomic, assign) CGRect openingFrame;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ISSExternalDisplayCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(tapRandomCell)
                                                userInfo:nil
                                                 repeats:YES];
    
    // Register cell classes
    [self.collectionView registerClass:[ISSImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)tapRandomCell {
    NSUInteger size = [[ISSDataShare shared].fetchedData[kISSDataKey] count];
    if (!size) {
        return;
    }
    int row = arc4random() % size;
    NSLog(@"Selecting indexpath: %@", [NSIndexPath indexPathForRow:row inSection:0]);
    dispatch_async(dispatch_get_main_queue(), ^{
        //        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        // This is so gross, but it works.
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger imagesFound = [[ISSDataShare shared].fetchedData[kISSDataKey] count];
    if (imagesFound > 0) {
        NSLog(@"Returned %ld items in section", imagesFound);
        return imagesFound;
    }
    NSLog(@"Returned 0 items in section");
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat oneThird = self.view.frame.size.width / 6;
    return CGSizeMake(oneThird, oneThird);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20.0, 10.0, 0.0, 10.0);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ISSImageCollectionViewCell *cell = (ISSImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImageView *recipeImageView = [[UIImageView alloc] init];
    
    NSString *photoID = [ISSDataShare shared].fetchedData[kISSDataKey][indexPath.row][kISSIDKey];
    NSString *imageURL = [ISSDataShare shared].filteredData[photoID][kISSImagesKey];
    //    NSLog(@"Image URL: %@", imageURL);
    cell.imageUrl = imageURL;
    
    [recipeImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    recipeImageView.frame = cell.bounds;
    [cell addSubview:recipeImageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ISSImageCollectionViewCell *cell = (ISSImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell) {
        return;
    }
    UICollectionViewLayoutAttributes *attr = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect attributesFrame = attr.frame;
    CGRect frameToOpenFrom = [collectionView convertRect:attributesFrame toView:collectionView.superview];
    
    self.openingFrame = frameToOpenFrom;
    
    ISSViewImageViewController *vc = (ISSViewImageViewController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:@"viewImageVC"];
    NSString *photoID = [ISSDataShare shared].fetchedData[kISSDataKey][indexPath.row][kISSIDKey];
    vc.imageID = photoID;
    vc.transitioningDelegate = self;
    vc.modalPresentationCapturesStatusBarAppearance = UIModalPresentationPopover;
    [self presentViewController:vc animated:YES completion:nil];
    
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    ISSPresentationAnimator *animator = [[ISSPresentationAnimator alloc] init];
    animator.openingFrame = self.openingFrame;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ISSDismissalAnimator *animator = [[ISSDismissalAnimator alloc] init];
    animator.openingFrame = self.openingFrame;
    return animator;
}

@end
