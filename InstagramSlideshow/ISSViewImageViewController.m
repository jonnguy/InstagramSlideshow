//
//  ISSViewImageViewController.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSViewImageViewController.h"

@interface ISSViewImageViewController ()

@end

@implementation ISSViewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Blurr the background first:
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Now set the image
    NSLog(@"Image URL: %@", self.imageUrl);
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
    
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    backgroundImage.image = image;
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    backgroundImage.frame = self.view.bounds;
    [backgroundImage addSubview:blurEffectView];
    [self.view addSubview:backgroundImage];
    
    UIImageView *recipeImageView = [[UIImageView alloc] init];
    [recipeImageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrl]];
    recipeImageView.contentMode = UIViewContentModeScaleAspectFit;
    recipeImageView.frame = self.view.bounds;
    recipeImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:recipeImageView];
    
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
