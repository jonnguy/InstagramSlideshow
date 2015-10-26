//
//  ISSDataShare.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSDataShare.h"

@interface ISSDataShare ()

@property (nonatomic, strong) NSURLSession *session;
@end

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
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        self.nextURLs = [NSMutableArray arrayWithCapacity:2];
        self.filteredData = [NSMutableDictionary dictionary];
        self.queuedPhotoIDs = [NSMutableArray array];
        self.completedPhotoIDs = [NSMutableArray array];
        self.fetchingFirst = NO;
        self.fetchingSecond = NO;
        return self;
    }
    return nil;
}

+ (NSString *)popQueuedPhoto {
    if (![ISSDataShare shared].queuedPhotoIDs[0]) {
        return nil;
    }
    // Start fetching when we have 10 queued photos
    if ([[ISSDataShare shared].queuedPhotoIDs count] <= 10 &&
        ![ISSDataShare shared].isFetchingFirst &&
        ![ISSDataShare shared].isFetchingSecond) {
        
        [ISSDataShare shared].fetchingFirst = YES;
        [ISSDataShare shared].fetchingSecond = YES;
        
        NSLog(@"Count is less than or equal 10, fetching new.");
        // We should fetch both next URLs if we have it
        if ([[ISSDataShare shared].nextURLs count] >= 1 && [ISSDataShare shared].nextURLs[0]) {
            [[ISSDataShare shared] fetchImagesWithNextURLIndex:0];
        } else {
            [[ISSDataShare shared] fetchTagImagesWithAuth:TOKEN_COMBINED completionHandler:^(NSDictionary *dict, NSError *error) {
                [ISSDataShare shared].fetchingFirst = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kISSNotificationFetchedData object:self];
            }];
        }
        if ([[ISSDataShare shared].nextURLs count] >= 2 && [ISSDataShare shared].nextURLs[1]) {
            [[ISSDataShare shared] fetchImagesWithNextURLIndex:1];
        } else {
            [[ISSDataShare shared] fetchTagImagesWithAuth:SECOND_TOKEN_COMBINED completionHandler:^(NSDictionary *dict, NSError *error) {
                [ISSDataShare shared].fetchingSecond = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kISSNotificationFetchedData object:self];
            }];
        }
    }
    NSString *photoID = [ISSDataShare shared].queuedPhotoIDs[0];
    [[ISSDataShare shared].queuedPhotoIDs removeObjectAtIndex:0];
    return photoID;
}

// Get the first element, return it, but also move it to the end
+ (NSString *)popCompletedPhoto {
    if (![ISSDataShare shared].completedPhotoIDs[0]) {
        return nil;
    }
    NSString *photoID = [ISSDataShare shared].completedPhotoIDs[0];
    [[ISSDataShare shared].completedPhotoIDs removeObjectAtIndex:0];
    return photoID;
}

+ (void)addToCompletedPhotoIDs:(NSString *)photoID {
    [[ISSDataShare shared].completedPhotoIDs addObject:photoID];
}


#pragma mark My methods
- (void)fetchImagesWithNextURLIndex:(NSInteger)index {
    NSURL *url;
    if (self.nextURLs[index]) {
        url = [NSURL URLWithString:self.nextURLs[index]];
    }
    NSLog(@"Fetching with next URL: %@", url);
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *data = [self.session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSDictionary *fetched = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.fetchedData = [NSMutableDictionary dictionaryWithDictionary:fetched];
            
            NSLog(@"Fetched count: %ld", (unsigned long)[fetched[kISSDataKey] count]);
            [[NSNotificationCenter defaultCenter] postNotificationName:kISSNotificationFetchedData object:self];
            
            if (index == 0) {
                if (fetched[kISSPaginationKey][kISSNextURLKey] && ![fetched[kISSPaginationKey][kISSNextURLKey] isEqual:[NSNull null]]) {
                    self.nextURLs[0] = fetched[kISSPaginationKey][kISSNextURLKey];
                    self.fetchingFirst = NO;
                }
            } else {
                if (fetched[kISSPaginationKey][kISSNextURLKey] && ![fetched[kISSPaginationKey][kISSNextURLKey] isEqual:[NSNull null]]) {
                    self.nextURLs[1] = fetched[kISSPaginationKey][kISSNextURLKey];
                    self.fetchingSecond = NO;
                }
            }
            
            [self cacheImagesFromInstagram];
        }
    }];
    [data resume];
}

- (void)fetchTagImagesWithAuth:(NSString *)auth completionHandler:(void (^)(NSDictionary *dict, NSError *error))completionHandler {
    NSString *reqString = [NSString stringWithFormat:@"%@%@", INSTAGRAM_APITAG, auth];
    NSLog(@"reqString: %@", reqString);
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqString]];
    NSURLSessionDataTask *data = [self.session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // I think I want to run this on a background queue, sicne I don't want the data to be messed around with in case of race conditions.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                NSDictionary *fetched = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                self.fetchedData = [NSMutableDictionary dictionaryWithDictionary:fetched];
                
                NSLog(@"Fetched count: %ld", (unsigned long)[fetched[kISSDataKey] count]);
                
                [self cacheImagesFromInstagram];
            }
            
            if (completionHandler) {
                completionHandler(self.fetchedData, nil);
            }
        });
    }];
    
    [data resume];
}


- (void)cacheImagesFromInstagram {
    NSArray *photosArray = [ISSDataShare shared].fetchedData[kISSDataKey];
    
    [photosArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // Store photoID first since we want to check if it arleady exists in filteredData.
        NSString *photoID = photosArray[idx][kISSIDKey];
        if (self.filteredData[photoID] || [self.queuedPhotoIDs containsObject:photoID] || [self.completedPhotoIDs containsObject:photoID]) {
            return;
        }
        // Add photo to queued
        [self.queuedPhotoIDs addObject:photoID];
        NSLog(@"Added %@ to queue (%ld)", photoID, (unsigned long)[self.queuedPhotoIDs count]);
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        // (NSString *) Images is the URL of the image, not the actual image
        dict[kISSImagesKey] = photosArray[idx][kISSImagesKey][kISSStandardResolutionKey][kISSURLKey];
        
        // Null captions were crashing the app.
        if ([photosArray[idx][kISSCaptionKey] isEqual:[NSNull null]]) {
            dict[kISSCaptionKey] = @"";
        } else {
            // (NSString *) Caption of the picture in plain text
            dict[kISSCaptionKey] = photosArray[idx][kISSCaptionKey][kISSTextKey];
        }
        
        // (NSString *) Name of the poster
        dict[kISSFullNameKey] = photosArray[idx][kISSUserKey][kISSFullNameKey];
        
        // (NSString *) Username of the poster
        dict[kISSUsernameKey] = photosArray[idx][kISSUserKey][kISSUsernameKey];
        
        // (NSString *) Profile picture of poster
        dict[kISSProfilePictureKey] = photosArray[idx][kISSUserKey][kISSProfilePictureKey];
        
        // (NSNumber *) Number of likes.. get integerValue of it.
        dict[kISSLikesKey] = photosArray[idx][kISSLikesKey][kISSCountKey];
        
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:photosArray[idx][kISSUserKey][kISSProfilePictureKey]] options:0 progress:nil completed:nil];
        
        // Now we should set the ID key in the dictionary to our newly formed dictionary.. This should be safe, right?
        self.filteredData[photoID] = dict;
    }];
    
}

@end
