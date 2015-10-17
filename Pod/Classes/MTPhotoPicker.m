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

-(void) setupWithTitle:(NSString *)title alternateTitle:(NSString *)atitle otherTitles:(NSArray *)titles cancelTitle:(NSString *)cTitle;

-(void) _clipToView:(UIView *)targetView;

- (void) showAnimated;

-(void) _addAsset:(ALAsset *) asset;

@property (nonatomic, weak) IBOutlet UIView * otherButtonsContainer;

@property (nonatomic, weak) IBOutlet UIView * backgroundView;
@property (nonatomic, weak) IBOutlet UIView * attachView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewBottomOffsetConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *attachViewHeightConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *otherButtonsHeight;

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
    NSMutableArray * markedAssets;
    
    __weak id <MTPhotoPickerDelegate> _delegate;
    
    
    NSArray * _buttonItems;
    
    NSString * _selectTitle;
    
    NSString * _alternateSelectTitle;
    
    NSString * _cancelTitle;
    
    BOOL _loadingAssets;
    
    dispatch_block_t _preloadCompletionBlock;
    
    BOOL _assetsLoaded;
    
    NSInteger _maxSelectCount;
    
    UIColor * _themeColor;
    
}


+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}




+(instancetype)pickerWithTitle:(NSString *)title alternateTitle:(NSString *)atitle otherTitles:(NSArray *)titles cancelTitle:(NSString *)cTitle{
    
    MTPhotoPicker * _picker = [[[NSBundle mainBundle] loadNibNamed:@"MTPhotoPicker" owner:self options:nil] objectAtIndex:0];
    [_picker setupWithTitle:title alternateTitle:atitle otherTitles:titles cancelTitle:cTitle];
    return _picker;
    
}

-(void) _addAsset:(ALAsset *) asset{
    [assets addObject:asset];
}

- (void) setDelegate:(id <MTPhotoPickerDelegate>) delegate{
    _delegate = delegate;
}

-(void) setupWithTitle:(NSString *)title alternateTitle:(NSString *)atitle otherTitles:(NSArray *)titles cancelTitle:(NSString *)cTitle{
    
    _selectTitle = title;
    
    _alternateSelectTitle = atitle;
    
    _buttonItems = titles;
    
    _cancelTitle = cTitle;
    
    
    
    
    
    
    
}

- (void)awakeFromNib
{
    self.selectedAttaches = [NSMutableArray new];
    
    assets = [NSMutableArray new];
    
    markedAssets = [NSMutableArray new];
    
    [self.collectionAttaches registerNib:[UINib nibWithNibName:@"MTAttachCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MTAttachCollectionCell"];
    
    self.collectionAttaches.dataSource = self;
    
    self.collectionAttaches.delegate = self;

    self.backgroundView.layer.opacity = 0.f;

    self.viewBottomOffsetConstraint.constant= -(self.attachView.frame.size.height);

    self.hidden = YES;
    

}


#pragma mark - KVO view


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    
    if(!self.hidden){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray * cells = [self.collectionAttaches visibleCells];
            
            for(MTAttachCollectionCell * _cell in cells){
                [_cell redrawCheckMark];
            }
        });

        
    }
    
    
    
}

#pragma mark - public methods

- (void) setMaximumSelectCount:(NSInteger) maxCount{

    _maxSelectCount = maxCount;
    
}


- (void) setThemeColor:(UIColor *) color{
    _themeColor = color;
}


- (void) loadAssets:(dispatch_block_t) completion
{
    

    if(_assetsLoaded){
        [self.collectionAttaches reloadData];
        return;
    }
    
    if(_loadingAssets) return;
    
    if(completion) _preloadCompletionBlock = completion;
    
    _loadingAssets = YES;
    
    assets = [NSMutableArray new];
    
    markedAssets = [NSMutableArray new];
    
    __weak id me = self;
    
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
                                   
                             //      dispatch_async(dispatch_get_main_queue(), ^{
                             //          if(table)
                             //              [table reloadData];
                             //      });
                                   
                                   count++;
                               }
                           }];
                           
    
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               if(_preloadCompletionBlock){
                                   _preloadCompletionBlock();
                                   _preloadCompletionBlock = nil;
                               }
                                _assetsLoaded = YES;
                               _loadingAssets = NO;
                               
                        //       if(table)
                        //           [table reloadData];
                           });
                           
                       } failureBlock: ^(NSError *error) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               if(_preloadCompletionBlock){
                                   _preloadCompletionBlock();
                                   _preloadCompletionBlock = nil;
                               }
                               _assetsLoaded = YES;
                               _loadingAssets = NO;
                               
                           });
                           
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
    [self.firstButton setTitle:_selectTitle forState:UIControlStateNormal];
    [self.cancelButton setTitle:_cancelTitle forState:UIControlStateNormal];
    
    [self _styleButton:self.firstButton];
    [self _styleButton:self.cancelButton];
    
    
    self.otherButtonsHeight.constant = [_buttonItems count] > 0 ? [_buttonItems count] * 45.f - 1.f : 0.f;
    
    int i=0;
    for(NSString * title in _buttonItems){
        [self addButton:title atIndex:i];
        i++;
    }
    
    if(IS_IPHONE_4 || IS_IPHONE_5){
        self.attachViewHeightConstraint.constant = 280.f;
    }
    
    
    self.frame = CGRectZero;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.layer addObserver:self forKeyPath:@"bounds" options:0 context:NULL];
    
    [self setNeedsUpdateConstraints];
    
}

-(void) _styleButton:(UIButton *)button{
    
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
    
    
    if(_themeColor)
        [button setTitleColor:_themeColor forState:UIControlStateNormal];
    
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
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
            [_delegate photoPickerButtonItemClicked:0];
            [self onCancelButtonTouch:nil];
        }
        
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
    
    [self p_setupUI];
    
    [self loadAssets:NULL];
    
    [view addSubview:self];
    
    [self _clipToView:view];
    
    [self showAnimated];
}

- (void) showAnimated{
    
    [self.firstButton setTitle:_selectTitle forState:UIControlStateNormal];

    markedAssets = [NSMutableArray new];
    
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
        if([_alternateSelectTitle containsString:@"%ld"])
            [self.firstButton setTitle:[NSString stringWithFormat:_alternateSelectTitle,(long)cnt] forState:UIControlStateNormal];
        else
            [self.firstButton setTitle:_alternateSelectTitle forState:UIControlStateNormal];
            //_alternateSelectTitle
        
  //      [self.secondButton setTitle:@"" forState:UIControlStateNormal];
  //      self.secondButton.enabled = NO;
    }else{
        [self.firstButton setTitle:_selectTitle forState:UIControlStateNormal];
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
    
    if(_maxSelectCount){
        if(_maxSelectCount==[markedAssets count]){
            //should remove first added element
            
            ALAsset * asset = [markedAssets objectAtIndex:0];
            
            NSInteger assetIndex = [assets indexOfObject:asset];
            
            [markedAssets removeObjectAtIndex:0];
            
            [self.collectionAttaches reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:assetIndex inSection:0]]];
            
        }
    }
    
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
    
    if(_themeColor)
        cell.themeColor = _themeColor;
    
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



-(void) addButton:(NSString *) title atIndex:(NSInteger) bIndex{
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.otherButtonsContainer addSubview:button];
    
    [button setTitle:title forState:UIControlStateNormal];

    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    button.tag = bIndex;
    
    [button addTarget:self action:@selector(optionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self _styleButton:button];
    
    
    
    [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:44.f]];
    
    
    [self.otherButtonsContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.otherButtonsContainer
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0f
                                                                            constant:bIndex * 45.f]];
    
    [self.otherButtonsContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeLeftMargin
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.otherButtonsContainer
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0f
                                                                            constant:0.f]];
    
    [self.otherButtonsContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeRightMargin
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.otherButtonsContainer
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0f
                                                                            constant:0.f]];
    
}


-(void) optionButtonClicked:(id)sender{
    
    UIButton * button = (UIButton *)sender;
    [_delegate photoPickerButtonItemClicked:(button.tag+1)];
    [self onCancelButtonTouch:nil];
    
}


@end
