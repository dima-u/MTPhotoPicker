//
//  MTPhotoPicker.h
//  MTTPhotoPicker
//
//  Created by dmitriy Uyanov on 19.08.15.
//  Copyright (c) 2015 company. All rights reserved.
//

#import <UIKit/UIKit.h>

//max number of photos that can be loaded from photo library
#define kPhotoPickerAssetsCount 50


//can be replaced with NSLocalizedString(..., nil):
//#define kPPickerAddPhotoText    NSLocalizedString(@"AddPhoto", nil)

#define kPPickerAddPhotoText    @"Add photo"
#define kPPickerAddVideoText    @"Add video"
#define kPPickerCancelText    @"Cancel"
#define kPPickerSendPhotosText   @"Send photos (%ld)"


@protocol MTPhotoPickerDelegate;


@interface MTPhotoPicker : UIView

+(instancetype)pickerWithTitle:(NSString *)title alternateTitle:(NSString *)atitle otherTitles:(NSArray *)titles cancelTitle:(NSString *)cTitle;

/*!
 * @discussion Will preload photos
 * @param view An UIView or subclass that will be parent for photo picker
 */
- (void) loadAssets:(dispatch_block_t) completion;


/*!
 * @discussion Will show photo picker with animation
 * @param view An UIView or subclass that will be parent for photo picker
 */

- (void) showInView:(UIView *)view;

/*!
 * @discussion Will hide photo picker with animation
 */
- (void) hideAnimated;


/*!
 * @discussion set delegate
 *@param id <MTPhotoPickerDelegate> object
 */
- (void) setDelegate:(id <MTPhotoPickerDelegate>) delegate;


- (void) setButtonItems:(NSArray *)options;

@end




@protocol MTPhotoPickerDelegate <NSObject>


- (void)photoPickerButtonItemClicked:(NSInteger) itemInedx;


/*!
 * @discussion will be called to ask owner if the picker should be closed after selection
 * @param array of ALAsset objects that user seleted
 */
-(BOOL)photoPickerShouldDismissWithAssets:(NSArray *)assets;

/*!
 * @discussion will be called when user picked photos and photopicker is about to close
 * @param array of ALAsset objects that user seleted
 */
-(void)photoPickerAssetsSelected:(NSArray *)assets;

/*!
 * @discussion will be called when photo picker is dismissed and reference to it should be cleared
 */
-(void)photoPickerDidDismiss;

@end

