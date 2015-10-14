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

@property (nonatomic, assign) CGRect openingFrame;

@end

@implementation ISSExternalDisplayCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[ISSImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSLog(@"Returned %ld items in section", (unsigned long)imagesFound);
        return imagesFound;
    }
    NSLog(@"Returned 0 items in section");
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(90.f, 90.f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10.0, 5.0, 0.0, 5.0);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ISSImageCollectionViewCell *cell = (ISSImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    NSLog(@"Cell: %@", cell);
    
    UIImageView *recipeImageView = [[UIImageView alloc] init];
    
    NSString *imageURL = [ISSDataShare shared].fetchedData[kISSDataKey][indexPath.row][kISSImagesKey][kISSStandardResolutionKey][kISSURLKey];
    NSLog(@"Image URL: %@", imageURL);
    cell.imageUrl = imageURL;
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    recipeImageView.image = image;
    recipeImageView.frame = cell.bounds;
    [cell addSubview:recipeImageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select at: %@", indexPath);
    
    ISSImageCollectionViewCell *cell = (ISSImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes *attr = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect attributesFrame = attr.frame;
    CGRect frameToOpenFrom = [collectionView convertRect:attributesFrame toView:collectionView.superview];
    
    self.openingFrame = frameToOpenFrom;
    
    ISSViewImageViewController *vc = [[ISSViewImageViewController alloc] init];
    vc.imageUrl = cell.imageUrl;
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
