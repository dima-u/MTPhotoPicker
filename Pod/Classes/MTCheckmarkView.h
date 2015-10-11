//
//  MTCheckmarkView.h
//  MTPhotoPicker
//
//  Created by dmitriy Uyanov on 09.10.15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTCheckmarkView : UIView

@property (nonatomic, assign)  CGFloat borderWidth;
@property (nonatomic, assign)  CGFloat checkmarkLineWidth;
@property (nonatomic, strong)  UIColor *borderColor;
@property (nonatomic, strong)  UIColor *bodyColor;
@property (nonatomic, strong)  UIColor *checkmarkColor;

@property (nonatomic) BOOL selected;
@end
