//
//  ISSImagesCollectionViewController.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSImagesCollectionViewController.h"
#import "ISSImageCollectionViewCell.h"
#import "ISSTransitioningDelegate.h"
#import "ISSViewImageViewController.h"

@interface ISSImagesCollectionViewController () <NSURLSessionDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSDictionary *dictOfDataFromTags;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) ISSTransitioningDelegate *transitionDelegate;

@end

@implementation ISSImagesCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[ISSImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.dictOfDataFromTags = [NSDictionary dictionary];
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    self.transitionDelegate = [[ISSTransitioningDelegate alloc] init];
    
    [self fetchImagesWithTag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchImagesWithTag {
    NSString *reqString = [NSString stringWithFormat:@"%@%@", INSTAGRAM_APITAG, TOKEN_COMBINED];
    NSLog(@"reqString: %@", reqString);
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqString]];
    NSURLSessionDataTask *data = [self.session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            self.dictOfDataFromTags = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            // Refresh the table once we get something
            [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }];
    
    [data resume];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger imagesFound = [self.dictOfDataFromTags[kISSDataKey] count];
    if (imagesFound > 0) {
        NSLog(@"Returned %ld items in section", imagesFound);
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
    
    NSString *imageURL = self.dictOfDataFromTags[kISSDataKey][indexPath.row][kISSImagesKey][kISSStandardResolutionKey][kISSURLKey];
    NSLog(@"Image URL: %@", imageURL);
    cell.imageUrl = imageURL;
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    recipeImageView.image = image;
    recipeImageView.frame = cell.bounds;
    [cell addSubview:recipeImageView];
    
//    NSString *imageURL = self.dictOfDataFromTags[kISSDataKey][indexPath.row][kISSImagesKey][kISSStandardResolutionKey][kISSURLKey];
//    NSLog(@"Image URL: %@", imageURL);
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
//    cell.instagramPicture.image = image;

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select at: %@", indexPath);
    
    ISSImageCollectionViewCell *cell = (ISSImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes *attr = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect attributesFrame = attr.frame;
    CGRect frameToOpenFrom = [collectionView convertRect:attributesFrame toView:collectionView.superview];
    
    self.transitionDelegate.openingFrame = frameToOpenFrom;
    
    ISSViewImageViewController *vc = [[ISSViewImageViewController alloc] init];
    vc.imageUrl = cell.imageUrl;
    vc.transitioningDelegate = self.transitioningDelegate;
    vc.modalPresentationCapturesStatusBarAppearance = UIModalPresentationPopover;
    [self presentViewController:vc animated:YES completion:nil];
    
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end