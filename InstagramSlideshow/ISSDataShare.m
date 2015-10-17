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
        return self;
    }
    return nil;
}

#pragma mark My methods

- (void)fetchTagImagesWithAuth:(NSString *)auth completionHandler:(void (^)(NSDictionary *dict, NSError *error))completionHandler {
    NSString *reqString = [NSString stringWithFormat:@"%@%@", INSTAGRAM_APITAG, auth];
    NSLog(@"reqString: %@", reqString);
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqString]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *data = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            self.fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            [self cacheImagesFromInstagram];
        }
        
        if (completionHandler) {
            completionHandler(self.fetchedData, nil);
        }
    }];
    
    [data resume];
}


- (void)cacheImagesFromInstagram {
    NSArray *photosArray = [ISSDataShare shared].fetchedData[kISSDataKey];
    
    [photosArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        // (NSString *) Images is the URL of the image, not the actual image
        dict[kISSImagesKey] = photosArray[idx][kISSImagesKey][kISSStandardResolutionKey][kISSURLKey];
        
        // (NSString *) Caption of the picture in plain text
        dict[kISSCaptionKey] = photosArray[idx][kISSCaptionKey][kISSTextKey];
        
        // (NSString *) Name of the poster
        dict[kISSFullNameKey] = photosArray[idx][kISSCaptionKey][kISSFromKey][kISSFullNameKey];
        
        // (NSString *) Username of the poster
        dict[kISSUsernameKey] = photosArray[idx][kISSCaptionKey][kISSFromKey][kISSUsernameKey];
        
        // (NSString *) Profile picture of poster
        dict[kISSProfilePictureKey] = photosArray[idx][kISSCaptionKey][kISSFromKey][kISSProfilePictureKey];
        
        // (NSNumber *) Number of likes.. get integerValue of it.
        dict[kISSLikesKey] = photosArray[idx][kISSLikesKey][kISSCountKey];
        
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:photosArray[idx][kISSCaptionKey][kISSFromKey][kISSProfilePictureKey]] options:0 progress:nil completed:nil];
        
        // Now we should set the ID key in the dictionary to our newly formed dictionary.. This should be safe, right?
        NSString *photoID = photosArray[idx][kISSIDKey];
        self.filteredData[photoID] = dict;
    }];
}

@end
