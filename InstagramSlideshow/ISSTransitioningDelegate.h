//
//  ISSTransitioningDelegate.h
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISSTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) CGRect openingFrame;

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed;

@end
