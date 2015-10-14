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

//@property (nonatomic, strong) NSDictionary *dictOfDataFromTags;
@property (nonatomic, strong) NSURLSession *session;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, assign) CGRect openingFrame;
@property (nonatomic, strong) UIScreen *externalScreen;
@property (nonatomic, strong) UIWindow *externalWindow;
@property (nonatomic, strong) NSArray *availableModes;

@property (nonatomic, strong) UIPickerView *modePicker;

@property (nonatomic, strong) ISSExternalDisplayCollectionViewController *externalDisplayViewController;

@end

@implementation ISSImagesCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(200, 140)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.externalDisplayViewController = [[ISSExternalDisplayCollectionViewController alloc] initWithCollectionViewLayout:aFlowLayout];
    self.externalWindow = [[UIWindow alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenDidConnect:)
                                                 name:UIScreenDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenDidDisconnect:)
                                                 name:UIScreenDidDisconnectNotification
                                               object:nil];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    
    // Webview stuff.. instagram..
    NSString* authURL = [NSString stringWithFormat: @"%@?client_id=%@&redirect_uri=%@&response_type=code&scope=%@&DEBUG=True", INSTAGRAM_AUTHURL, INSTAGRAM_CLIENT_ID, INSTAGRAM_REDIRECT_URI, INSTAGRAM_SCOPE];
    
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: authURL]]];
    [self.webView setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark delegate

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

#pragma My methods

- (void)fetchImagesWithTag {
    NSString *reqString = [NSString stringWithFormat:@"%@%@", INSTAGRAM_APITAG, TOKEN_COMBINED];
    NSLog(@"reqString: %@", reqString);
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqString]];
    NSURLSessionDataTask *data = [self.session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            [ISSDataShare shared].fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            // Refresh the table once we get something
            [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }];
    
    [data resume];
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
            
            [self fetchImagesWithTag];
            [self.webView removeFromSuperview];
        }
    }];
    
    [dataTask resume];
}

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

#pragma mark Notifications for Screen changes

- (void)screenDidConnect:(NSNotification *)not {
    NSLog(@"Screen connected");
    
    NSArray *screens = [UIScreen screens];
    NSLog(@"Screens: %@", screens);
    
    self.externalScreen = screens[1];
    self.availableModes = [self.externalScreen availableModes];
    
    [self.externalWindow setScreen:self.externalScreen];
    [self.externalWindow addSubview:self.externalDisplayViewController.view];
    
}

- (void)screenDidDisconnect:(NSNotification *)not {
    NSLog(@"Screen disconnected");
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