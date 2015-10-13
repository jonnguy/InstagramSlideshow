//
//  ISSImageCollectionViewCell.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSImageCollectionViewCell.h"

@implementation ISSImageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
        self = [super initWithFrame:frame];
        if (self) {
                
                imageView = [[UIImageView alloc] init];
                [self.contentView addSubview:imageView];
                
            }
        return self;
}

@end
