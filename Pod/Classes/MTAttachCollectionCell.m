//
//  MTAttachCollectionCell.m
//  MTPhotoPicker
//
//  Created by dmitriy Uyanov on 09.10.15.
//  Copyright (c) 2015. All rights reserved.
//

#import "MTAttachCollectionCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "MTCheckmarkView.h"

#define kCheckMarkWidth  24.f
#define kCheckMarkSpacing 4.f

@interface MTAttachCollectionCell()

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;

@property (nonatomic, strong) MTCheckmarkView *selectView;

@property (nonatomic, weak) IBOutlet UIButton *selectButton;



@end

@implementation MTAttachCollectionCell



- (void)awakeFromNib
{
    
    [super awakeFromNib];
    
}

-(void)setupWithAsset:(ALAsset *)representation selected:(BOOL) selected{
    
    
    
    if(!self.selectView){
        self.selectView = [[MTCheckmarkView alloc] initWithFrame: CGRectMake(self.frame.size.width - kCheckMarkWidth -kCheckMarkSpacing, self.frame.size.height - kCheckMarkWidth -kCheckMarkSpacing, kCheckMarkWidth, kCheckMarkWidth)];
        self.selectView.userInteractionEnabled = NO;
        
        [self addSubview:self.selectView];
        
        if(self.themeColor)
            self.selectView.bodyColor = self.themeColor;
        
    }
    
    UIImage * thumbnail = [UIImage imageWithCGImage:[representation aspectRatioThumbnail]];
    self.previewImageView.image = thumbnail;
    
    if(selected) [self p_select];
    else [self p_deselect];
    
    [self redrawCheckMark];
}




- (IBAction)selectButtonPressed:(UIButton *)button
{
    [self p_select];
    [self.delegate select:self];
}

- (IBAction)deselectButtonPressed:(UIButton *)button
{
    [self p_deselect];
    [self.delegate deselect:self];
}

#pragma mark - private methos

- (void)p_select
{
    self.selectView.selected = YES;
    [self p_selectButtonChangeSelector:@selector(deselectButtonPressed:)];
    [self.selectView setNeedsDisplay];
}


- (void)p_deselect
{
    self.selectView.selected = NO;
    [self p_selectButtonChangeSelector:@selector(selectButtonPressed:)];
    
    [self.selectView setNeedsDisplay];
}

- (void)p_selectButtonChangeSelector:(SEL)selector
{
    [self.selectButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.selectButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}


- (void) redrawCheckMark{
    
    CGFloat width = self.frame.size.width;
    
    BOOL changed = NO;
    CGFloat curentCheckMarkoffset = self.selectView.frame.origin.x;
    
    CGRect fr = self.selectView.frame;
    
    
    CGFloat cellStartVisibleOffset = self.frame.origin.x - [self.delegate collectionVieoffset];
    
    if(cellStartVisibleOffset + width < [self.delegate collectionViewSize]){
        
        fr.origin.x = width - kCheckMarkSpacing - kCheckMarkWidth;
        if(fr.origin.x!=curentCheckMarkoffset) changed = YES;
        
    }else{
        
            CGFloat restWidth = [self.delegate collectionViewSize] - cellStartVisibleOffset;
        
        if(restWidth > kCheckMarkSpacing*2 + kCheckMarkWidth){
            fr.origin.x = restWidth - kCheckMarkSpacing - kCheckMarkWidth;
            if(fr.origin.x!=curentCheckMarkoffset) changed = YES;
            
        }else{
            fr.origin.x  = kCheckMarkSpacing;
            if(fr.origin.x!=curentCheckMarkoffset) changed = YES;
        }
        
    }

    
    if(changed){
    
        self.selectView.frame = fr;
    
    }
    
}

@end
