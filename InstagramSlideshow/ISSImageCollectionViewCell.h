//
//  ISSImageCollectionViewCell.h
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISSImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *imageUrl;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
