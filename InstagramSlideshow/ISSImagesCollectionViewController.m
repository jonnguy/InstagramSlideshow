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
#import "ISSExternalDisplayCollectionViewController.h"

#import "ISSDismissalAnimator.h"
#import "ISSPresentationAnimator.h"

@interface ISSImagesCollectionViewController () <UIWebViewDelegate, NSURLSessionDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UIPickerViewDelegate>

@property (nonatomic, strong) UIStoryboard *mainStoryboard;
@property (nonatomic, strong) NSMutableArray *imagesBeingUsed;
@property (nonatomic, strong) NSURLSession *session;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, assign) CGRect openingFrame;
@property (nonatomic, strong) UIScreen *externalScreen;
@property (nonatomic, strong) UIWindow *externalWindow;
@property (nonatomic, strong) NSArray *availableModes;

@property (nonatomic, strong) NSMutableArray *shownPhotoIDs;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL tappedOnce;

@property (nonatomic, strong) ISSExternalDisplayCollectionViewController *externalDisplayViewController;

@end

@implementation ISSImagesCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.shownPhotoIDs = [NSMutableArray arrayWithCapacity:20];
    
    NSString *possiblyOtherAPIString = [[NSUserDefaults standardUserDefaults] objectForKey:@"OtherAPIKey"];
    if (possiblyOtherAPIString) {
        [ISSDataShare shared].secondAuthToken = possiblyOtherAPIString;
        NSLog(@"Other API key that we're using: %@", [ISSDataShare shared].secondAuthToken);
    }

    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(200, 140)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.externalDisplayViewController = [[ISSExternalDisplayCollectionViewController alloc] initWithCollectionViewLayout:aFlowLayout];
    self.externalWindow = [[UIWindow alloc] init];
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Webview stuff.. instagram..
    NSString* authURL = [NSString stringWithFormat: @"%@?client_id=%@&redirect_uri=%@&response_type=code&scope=%@", INSTAGRAM_AUTHURL, INSTAGRAM_CLIENT_ID, INSTAGRAM_REDIRECT_URI, INSTAGRAM_SCOPE];
    
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: authURL]]];
    [self.webView setDelegate:self];
    
    self.tappedOnce = NO;
    
    // -viewDidLoad
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    swipeRecognizer.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnce:)];
    tapOnce.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:tapOnce];
}

- (void)tappedOnce:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Invalidated timer");
    [self.timer invalidate];
}

- (void)swiped:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        NSLog(@"Three finger swiped tapped");
        [self performSegueWithIdentifier:@"showTextField" sender:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.tappedOnce) {
        [self startTimer];
    }
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                  target:self
                                                selector:@selector(tapRandomCell)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Webview Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self checkRequestForCallbackURL: request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.webView.layer removeAllAnimations];
    self.webView.userInteractionEnabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView.layer removeAllAnimations];
    self.webView.userInteractionEnabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFinishLoad:webView];
}


- (BOOL)checkRequestForCallbackURL:(NSURLRequest *)request {
    NSString* urlString = [[request URL] absoluteString];
    if ([urlString hasPrefix: INSTAGRAM_REDIRECT_URI]) {
        // extract and handle access token
        NSRange range = [urlString rangeOfString: @"code="];
        [self makePostRequest:[urlString substringFromIndex: range.location+range.length]];
        return NO;
    }
    
    return YES;
}

- (void)makePostRequest:(NSString *)code {
    
    NSString *post = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",INSTAGRAM_CLIENT_ID,INSTAGRAM_CLIENTSERCRET,INSTAGRAM_REDIRECT_URI,code];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *requestData = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"]];
    [requestData setHTTPMethod:@"POST"];
    [requestData setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [requestData setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requestData setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:requestData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"Successfully logged in with token == %@", dict[@"access_token"]);
            NSLog(@"Dict: %@", dict);
            [[ISSDataShare shared] setAuthToken:dict[@"access_token"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView setHidden:YES]; 
                [self.webView removeFromSuperview];
            });
            
            // This should be the first fetch.
            [[ISSDataShare shared] fetchTagImagesWithAuth:TOKEN_COMBINED completionHandler:^(NSDictionary *dict, NSError *error) {
                if (error) {
                    NSLog(@"Error fetching images with tag: %@", error.localizedDescription);
                } else {
                    for (int i = 0; i < 20 && [[ISSDataShare shared].queuedPhotoIDs count] > 0; i++) {
                        [self.shownPhotoIDs addObject:[ISSDataShare popQueuedPhoto]];
                    }
                    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                }
            }];
            
            // NOTE: This might work.
            // If we have a second thing, we should also fetch
            if ([ISSDataShare shared].secondAuthToken) {
                NSLog(@"We have a second auth token");
                [[ISSDataShare shared] fetchTagImagesWithAuth:SECOND_TOKEN_COMBINED completionHandler:^(NSDictionary *dict, NSError *error) {
                    if (error) {
                        NSLog(@"Error with 2nd token: %@", error.localizedDescription);
                    } else {
                        while ([self.shownPhotoIDs count] < 20 && [[ISSDataShare shared].queuedPhotoIDs count]) {
                            [self.shownPhotoIDs addObject:[ISSDataShare popQueuedPhoto]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.shownPhotoIDs.count-1 inSection:0]]];
                            });
                        }
                    }
                }];
            }
        }
    }];
    
    [dataTask resume];
}

- (void)tapRandomCell {
    [self.timer invalidate];
    NSUInteger size = [self.shownPhotoIDs count];
    if (!size) {
        return;
    }
    int row = arc4random() % size;
    dispatch_async(dispatch_get_main_queue(), ^{
        // This is so gross, but it works.
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
    });
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger imagesFound = [self.shownPhotoIDs count];
    if (imagesFound > 0) {
        NSLog(@"Returned %ld items in section", (unsigned long)imagesFound);
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
    
    NSString *photoID = self.shownPhotoIDs[indexPath.row];
    NSString *imageURL = [ISSDataShare shared].filteredData[photoID][kISSImagesKey];
    
//    NSString *photoID = [ISSDataShare shared].fetchedData[kISSDataKey][indexPath.row][kISSIDKey];
//    NSString *imageURL = [ISSDataShare shared].filteredData[photoID][kISSImagesKey];
//    NSLog(@"Image URL: %@", imageURL);
    cell.imageUrl = imageURL;
    
    [recipeImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    recipeImageView.frame = cell.bounds;
    [cell addSubview:recipeImageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ISSImageCollectionViewCell *cell = (ISSImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    self.tappedOnce = YES; // BOOL to start auto-tapping after the first one
    
    if (!cell) {
        return;
    }
    UICollectionViewLayoutAttributes *attr = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect attributesFrame = attr.frame;
    CGRect frameToOpenFrom = [collectionView convertRect:attributesFrame toView:collectionView.superview];
    self.openingFrame = frameToOpenFrom;
    
    NSString *photoID = self.shownPhotoIDs[indexPath.row];
    NSLog(@"Tapped photo ID: %@", photoID);
    // Add to photos we tapped and remove from the collection view main dict.
    if (![[ISSDataShare shared].completedPhotoIDs containsObject:photoID]) {
        [ISSDataShare addToCompletedPhotoIDs:photoID];
    }
    [self updatePhotoAtIndex:indexPath.row];
    
//    NSString *photoID = [ISSDataShare shared].fetchedData[kISSDataKey][indexPath.row][kISSIDKey];
    // Set the new view controller.. Instantiate because we have a custom animation.
    ISSViewImageViewController *vc = (ISSViewImageViewController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:@"viewImageVC"];
    vc.imageID = photoID;
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)updatePhotoAtIndex:(NSInteger)index {
//    NSLog(@"Current (%ld): %@", [self.shownPhotoIDs count], self.shownPhotoIDs);
//    NSLog(@"Queued (%ld): %@", [[ISSDataShare shared].queuedPhotoIDs count], [ISSDataShare shared].queuedPhotoIDs);
//    NSLog(@"Completed (%ld): %@", [[ISSDataShare shared].completedPhotoIDs count], [ISSDataShare shared].completedPhotoIDs);
    // If we have queued photos, use that, else recycle from completed photos ID
    NSString *photoID;
    if ([[ISSDataShare shared].queuedPhotoIDs count]) {
        photoID = [ISSDataShare popQueuedPhoto];
        NSLog(@"Replaced from queued (%ld): %@", (unsigned long)[[ISSDataShare shared].queuedPhotoIDs count], photoID);
        self.shownPhotoIDs[index] = photoID;
    } else {
        // If there's no queued, just recycle from the used
        photoID = [ISSDataShare popCompletedPhoto];
        NSLog(@"Recycled from completed photos (%ld): %@", (unsigned long)[[ISSDataShare shared].completedPhotoIDs count], photoID);
        self.shownPhotoIDs[index] = photoID;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    });
}

#pragma mark Animation
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
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