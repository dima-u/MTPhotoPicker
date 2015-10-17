//
//  MTAttachCollectionCell.h
//  MTPhotoPicker
//
//  Created by dmitriy Uyanov on 09.10.15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAsset;

@protocol MTAttachCollectionCellDelegate;

@interface MTAttachCollectionCell : UICollectionViewCell

- (void)setupWithAsset:(ALAsset *)representation selected:(BOOL) selected;

@property (nonatomic, weak) id<MTAttachCollectionCellDelegate> delegate;

- (void) redrawCheckMark;

@property (nonatomic, strong) UIColor * themeColor;
@end

@protocol MTAttachCollectionCellDelegate <NSObject>

- (void)select:(MTAttachCollectionCell *)cell;

- (void)deselect:(MTAttachCollectionCell *)cell;

- (CGFloat)collectionVieoffset;

- (CGFloat)collectionViewSize;

@end