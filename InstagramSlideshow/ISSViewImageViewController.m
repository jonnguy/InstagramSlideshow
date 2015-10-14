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
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:blurEffectView];
    
    // Now set the image
    NSLog(@"Image URL: %@", self.imageUrl);
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
    
    UIImageView *recipeImageView = [[UIImageView alloc] init];
    recipeImageView.image = image;
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
    
    [self performSelector:@selector(viewTapped) withObject:nil afterDelay:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
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