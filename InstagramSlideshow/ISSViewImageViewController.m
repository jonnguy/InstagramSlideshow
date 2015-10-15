//
//  ISSViewImageViewController.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSViewImageViewController.h"

@interface ISSViewImageViewController ()

@property (nonatomic, strong) NSDictionary *userDictionary;

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end

@implementation ISSViewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userDictionary = [ISSDataShare shared].filteredData[self.imageID];
    
    [self.view setAlpha:1.0];
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // Now set the image
//    NSLog(@"Image URL: %@", self.imageUrl);

    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.userDictionary[kISSImagesKey]]]];

    UIImageView *backgroundImage = [[UIImageView alloc] init];
    backgroundImage.image = image;
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    backgroundImage.frame = self.view.bounds;
    [backgroundImage addSubview:blurEffectView];
    [self.view insertSubview:backgroundImage atIndex:0];
    
    // Profile picture image
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 1.5;
//    self.profilePictureImageView.layer.borderWidth = 0;
    self.profilePictureImageView.clipsToBounds = YES;
    NSString *imageURL = self.userDictionary[kISSProfilePictureKey];
    self.profilePictureImageView.backgroundColor = [UIColor whiteColor];
    [self.profilePictureImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    
    // Username
    self.usernameLabel.bounds = CGRectInset(self.usernameLabel.frame, 10.0f, 10.0f);
    self.usernameLabel.text = self.userDictionary[kISSUsernameKey];
    
    // Main image
    NSString *mainImageURL = self.userDictionary[kISSImagesKey];
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:mainImageURL]];
    
    // Likes label
    NSInteger likes = [self.userDictionary[kISSLikesKey] integerValue];
    if (likes == 1) {
        self.likesLabel.text = [NSString stringWithFormat:@"%ld like", likes];
    } else {
        self.likesLabel.text = [NSString stringWithFormat:@"%ld likes", likes];
    }
    
    // Comment label
    self.commentLabel.text = [NSString stringWithFormat:@"%@ %@", self.userDictionary[kISSUsernameKey], self.userDictionary[kISSCaptionKey]];

    // Gesture recognizer to dismiss the view
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:rec];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(viewTapped) withObject:nil afterDelay:3.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
