# MTPhotoPicker

[![CI Status](http://img.shields.io/travis/Ulyanov Dmitry/MTPhotoPicker.svg?style=flat)](https://travis-ci.org/Ulyanov Dmitry/MTPhotoPicker)
[![Version](https://img.shields.io/cocoapods/v/MTPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/MTPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/MTPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/MTPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/MTPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/MTPhotoPicker)

MTPhotoPicker is an imessage style photo picker for your application with customization and rotation support


## Features

 - automatically parse photolibrary
 - you can customize buttons/add your own
 - smooth animation and  iMessage style design
 - support screen rotation

##ScreenShots
![enter image description here](https://raw.githubusercontent.com/dima-u/MTPhotoPicker/master/Screenshots/example.gif)
## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

or

**create photo picker object**

```objective-c
MTPhotoPicker * _pickerView = [MTPhotoPicker pickerWithTitle:@"Choose Photo" alternateTitle:@"Attach photos (%ld)" otherTitles:@[@"Choose video",@"Capture"] cancelTitle:@"Cancel"];
```

**implement delegate methods**

```objective-c
#pragma mark - MTPhotoPickerDelegate
-(BOOL)photoPickerShouldDismissWithAssets:(NSArray *)assets{
    return YES;
}

-(void)photoPickerAssetsSelected:(NSArray *)assets{
    //use ALAsset array
}


-(void)photoPickerDidDismiss{

    _pickerView = nil;

}

-(void)photoPickerButtonItemClicked:(NSInteger)itemInedx{
    //handle custom  buttons click
}
```

**Show picker**

```objective-c
[_pickerView loadAssets:^{       
    [self.pickerView showInView:self.view];
}];
```
     
        

## Requirements

## Installation

MTPhotoPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MTPhotoPicker"
```

## Author

Ulyanov Dmitry, dima-u@inbox.ru

## License

MTPhotoPicker is available under the MIT license. See the LICENSE file for more info.
