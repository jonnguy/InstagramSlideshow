//
//  ISSDataShare.h
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISSDataShare : NSObject

+ (id)shared;

@property (nonatomic, strong) NSString *authToken;

@end
