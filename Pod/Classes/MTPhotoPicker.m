//
//  MTPhotoPicker.m
//  MTPhotoPicker
//
//  Created by dmitriy Uyanov on 19.08.15.
//  Copyright (c) 2015 company. All rights reserved.
//

#import "MTPhotoPicker.h"

#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define IS_IPHONE_4 ( [ [ UIScreen mainScreen ] bounds ].size.height == 480 )

#import "MTAttachCollectionCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MTPhotoPicker()<MTAttachCollectionCellDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate>



-(void) _clipToView:(UIView *)targetView;

- (void) showAnimated;

- (void) loadAttaches;

-(void) _addAsset:(ALAsset *) asset;

@property (nonatomic, weak) IBOutlet UIView * backgroundView;
@property (nonatomic, weak) IBOutlet UIView * attachView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewBottomOffsetConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *attachViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UIButton *firstButton;
@property (nonatomic, weak) IBOutlet UIButton *secondButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionAttaches;

@property (nonatomic, strong) NSArray *attaches;
@property (nonatomic, strong) NSMutableArray *selectedAttaches;

@end
@implementation MTPhotoPicker{
    
    
    /*!
     *@brief  all loaded from photo library assets
     */
    NSMutableArray * assets;
    
    /*!
     *@brief assets that are selected
     */
    NSMutableSet * markedAssets;
    
    
    __weak id <MTPhotoPickerDelegate> _delegate;
    
    
}



+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

-(void) _addAsset:(ALAsset *) asset{
    [assets addObject:asset];
}

- (void) setDelegate:(id <MTPhotoPickerDelegate>) delegate{
    _delegate = delegate;
}

- (void)awakeFromNib
{
    self.selectedAttaches = [NSMutableArray new];
    
    assets = [NSMutableArray new];
    
    markedAssets = [NSMutableSet new];
    
    [self.collectionAttaches registerNib:[UINib nibWithNibName:@"MTAttachCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MTAttachCollectionCell"];
    
    [self p_setupUI];
    
    self.collectionAttaches.dataSource = self;
    
    self.collectionAttaches.delegate = self;

    self.backgroundView.layer.opacity = 0.f;

    self.viewBottomOffsetConstraint.constant= -(self.attachView.frame.size.height);

    self.hidden = YES;
    
    if(IS_IPHONE_4 || IS_IPHONE_5){
        self.attachViewHeightConstraint.constant = 280.f;
    }
    
    
    self.frame = CGRectZero;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
}


#pragma mark - public methods
- (void)loadAttaches
{
    assets = [NSMutableArray new];
    
    markedAssets = [NSMutableSet new];
    
    __weak id me = self;
    __weak id table = self.collectionAttaches;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       
                       __block int count = 0;
                       
                       ALAssetsLibrary *library = [MTPhotoPicker defaultAssetsLibrary];
                       
                       // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
                       [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                           
                           if(!me){
                               *stop = YES;
                               return;
                           }
                           // Within the group enumeration block, filter to enumerate just photos.
                           [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                           
                           // Chooses the photo at the last index
                           [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                               
                               
                               if(!me){
                                   *stop = YES;
                                   *innerStop = YES;
                                   return;
                               }
                               
                               // The end of the enumeration is signaled by asset == nil.
                               if (alAsset) {
                                   if(me)
                                       [me _addAsset:alAsset];
                                   else
                                       return;

                                   
                                   
                                   if(count==(kPhotoPickerAssetsCount-1)){
                                       *stop = YES;
                                       *innerStop = YES;
                                   }
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if(table)
                                           [table reloadData];
                                   });
                                   
                                   count++;
                               }
                           }];
                           
    
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if(table)
                                   [table reloadData];
                           });
                           
                       } failureBlock: ^(NSError *error) {
                           
                           NSLog(@"No groups");
                           
                       }];
                       
                       
                   });

    
    
    
}

- (NSArray *const)selectAttaches
{
    NSMutableArray * _assets = [NSMutableArray new];
    
    //to save order
    for(ALAsset * asset in assets){
        if([markedAssets containsObject:asset]){
            [_assets addObject:asset];
        }
    }
    

    return _assets;
}


#pragma mark - private methods
- (void)p_setupUI
{
    [self.firstButton setTitle:kPPickerAddPhotoText forState:UIControlStateNormal];
    [self.secondButton setTitle:kPPickerAddVideoText forState:UIControlStateNormal];
    [self.cancelButton setTitle:kPPickerCancelText forState:UIControlStateNormal];
    
    
    
    static UIImage * normalImage;
    static UIImage * selectedImage;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        CGContextFillRect(context, rect);
        
        selectedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillRect(context, rect);
        
        normalImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        
        
    });
    

    
    [self.firstButton setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [self.secondButton setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [self.cancelButton setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [self.firstButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.secondButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:normalImage forState:UIControlStateNormal];
}



#pragma mark - Actions
-(IBAction)onFirstButtonTouch:(id)sender{
    
    
    if([markedAssets count] > 0){
        
        if(_delegate){
            
            if([_delegate respondsToSelector:@selector(photoPickerShouldDismissWithAssets:)]){
                if([_delegate photoPickerShouldDismissWithAssets:[self selectAttaches]]){
                    
                    if([_delegate respondsToSelector:@selector(photoPickerAssetsSelected:)])
                        [_delegate photoPickerAssetsSelected:[self selectAttaches]];
                    [self onCancelButtonTouch:nil];
                }
            }else{
                if([_delegate respondsToSelector:@selector(photoPickerAssetsSelected:)])
                    [_delegate photoPickerAssetsSelected:[self selectAttaches]];
                [self onCancelButtonTouch:nil];
            }
            
        }
    }else{
        
        if(_delegate){
            [_delegate photoPickerAddPhoto];
            [self onCancelButtonTouch:nil];
        }
        
    }
    
}

-(IBAction)onSecondButtonTouch:(id)sender{
    

    if([markedAssets count] > 0) return;
    
    
    if(_delegate){
        [_delegate photoPickerAddVideo];
        [self onCancelButtonTouch:nil];
    }
    
}

- (void) hideAnimated{
    [self onCancelButtonTouch:nil];
}


-(IBAction)onCancelButtonTouch:(id)sender{
    
    if(self.hidden) return;
    
    [self.attachView layoutIfNeeded];
    
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.backgroundView.layer.opacity = 0.f;
        
        self.viewBottomOffsetConstraint.constant= -(self.attachView.frame.size.height);
        
        [self.attachView layoutIfNeeded];
        
    } completion:^(BOOL finished){
        if(finished){
            self.hidden = YES;
        }
        
        if([_delegate respondsToSelector:@selector(photoPickerDidDismiss)]){
            [_delegate photoPickerDidDismiss];
        }
    }];
    
}

- (void) showInView:(UIView *)view{
    
    [self loadAttaches];
    
    [view addSubview:self];
    
    [self _clipToView:view];
    
    [self showAnimated];
}

- (void) showAnimated{
    
    [self.firstButton setTitle:kPPickerAddPhotoText forState:UIControlStateNormal];
    [self.secondButton setTitle:kPPickerAddVideoText forState:UIControlStateNormal];
    self.secondButton.enabled = YES;

    markedAssets = [NSMutableSet new];
    
    [self.collectionAttaches reloadData];
    
    
    
    [self.attachView layoutIfNeeded];
    
    self.hidden = NO;
    
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.backgroundView.layer.opacity = 0.4f;
        
        self.viewBottomOffsetConstraint.constant= 0.f;
        
        [self.attachView layoutIfNeeded];
        
    } completion:^(BOOL finished){

    }];
}

-(void) _attachesCountChanged{
    NSInteger cnt = [markedAssets count];
    
    if(cnt > 0){
        [self.firstButton setTitle:[NSString stringWithFormat:kPPickerSendPhotosText,(long)cnt] forState:UIControlStateNormal];
        [self.secondButton setTitle:@"" forState:UIControlStateNormal];
        self.secondButton.enabled = NO;
    }else{
        [self.firstButton setTitle:kPPickerAddPhotoText forState:UIControlStateNormal];
        [self.secondButton setTitle:kPPickerAddVideoText forState:UIControlStateNormal];
        self.secondButton.enabled = YES;
    }
}


#pragma mark - MTAttachCollectionDataSourceDelegate

- (CGFloat)collectionVieoffset{
    return self.collectionAttaches.bounds.origin.x;
}


- (CGFloat)collectionViewSize{
    return self.collectionAttaches.frame.size.width;
}


- (void)select:(MTAttachCollectionCell *)cell
{
    
    [self.collectionAttaches scrollToItemAtIndexPath:[self.collectionAttaches indexPathForCell:cell] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    NSIndexPath * path = [self.collectionAttaches indexPathForCell:cell];
    
    [markedAssets addObject:[assets objectAtIndex:path.row]];
    [self _attachesCountChanged];
}

- (void)deselect:(MTAttachCollectionCell *)cell
{
    [self.collectionAttaches scrollToItemAtIndexPath:[self.collectionAttaches indexPathForCell:cell] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
   
    NSIndexPath * path = [self.collectionAttaches indexPathForCell:cell];
    [markedAssets removeObject:[assets objectAtIndex:path.row]];
    [self _attachesCountChanged];
}


#pragma mark - CollectionViewDelegate methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTAttachCollectionCell *cell = nil;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTAttachCollectionCell" forIndexPath:indexPath];

    cell.delegate = self;
    
    [cell setupWithAsset:[assets objectAtIndex:indexPath.row] selected:[markedAssets containsObject:[assets objectAtIndex:indexPath.row]]];

    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [assets count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ALAsset * asset = [assets objectAtIndex:indexPath.row];
    
    UIImage * thumbnail =  [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    
    CGSize size = CGSizeZero;
    
    CGFloat borderHeight = 10;
    
    size.height = collectionView.frame.size.height - borderHeight;
    
    float ration = (float)thumbnail.size.width / (float)thumbnail.size.height;
    
    
    size.width =  ration * size.height;
    
    return size;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSArray * cells = [self.collectionAttaches visibleCells];
    
    for(MTAttachCollectionCell * _cell in cells){
        [_cell redrawCheckMark];
    }
    
}

#pragma mark - private methods

-(void) _clipToView:(UIView *)targetView{
    
    
    
    [targetView  addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:targetView
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1
                                                            constant:0]];
    
    // Height constraint
    [targetView  addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:targetView
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1
                                                            constant:0]];
    
    // Center horizontally
    [targetView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:targetView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];

    // Center vertically
    [targetView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:targetView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
}

@end
