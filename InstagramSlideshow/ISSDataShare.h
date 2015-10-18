//
//  ISSDataShare.h
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISSDataShare : NSObject

+ (ISSDataShare *)shared;

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *secondAuthToken;
@property (nonatomic, strong) NSMutableDictionary *fetchedData;
@property (nonatomic, strong) NSMutableArray *fetchedOnlyData;
@property (nonatomic, strong) NSMutableDictionary *filteredData; // This is a custom dictionary from the fetched data so I don't have to mess with the huge JSON they send us.
@property (nonatomic, strong) NSMutableArray *queuedPhotoIDs; // These are photo IDs that aren't being used
@property (nonatomic, strong) NSMutableArray *completedPhotoIDs; // These are photos that we should recycle

@property (nonatomic, strong) NSMutableArray *nextURLs;

+ (NSString *)popQueuedPhoto;
+ (NSString *)popCompletedPhoto;
+ (void)addToCompletedPhotoIDs:(NSString *)photoID;

- (void)fetchTagImagesWithAuth:(NSString *)auth completionHandler:(void (^)(NSDictionary *dict, NSError *error))completionHandler;

@end
