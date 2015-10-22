//
//  ISSViewImageViewController.h
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPZoomTransitionAnimator.h"

@interface ISSViewImageViewController : UIViewController <RMPZoomTransitionAnimating>

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (nonatomic, strong) NSString *imageID;

@end
