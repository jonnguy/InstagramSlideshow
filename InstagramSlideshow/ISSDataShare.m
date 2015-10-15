//
//  ISSDataShare.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSDataShare.h"

@implementation ISSDataShare

+ (ISSDataShare *)shared {
    static ISSDataShare *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        self.fetchedData = [NSDictionary dictionary];
        self.filteredData = [NSMutableDictionary dictionary];
        self.cachedPhotos = [[NSCache alloc] init];
        return self;
    }
    return nil;
}

@end
