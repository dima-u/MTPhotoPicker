//
//  PhotoCell.h
//  MTPhotoPickerExample
//
//  Created by dmitriy Uyanov on 09.10.15.
//  Copyright (c) 2015 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UIImageView * photo;
@property(nonatomic,strong) IBOutlet UILabel * title;
@end
