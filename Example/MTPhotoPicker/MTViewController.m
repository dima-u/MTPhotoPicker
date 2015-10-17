//
//  ViewController.m
//  MTPhotoPickerExample
//
//  Created by dmitriy Uyanov on 09.10.15.
//  Copyright (c) 2015 mycompany. All rights reserved.
//

#import "MTViewController.h"

#import "MTPhotoPicker.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "PhotoCell.h"

@interface MTViewController () <UITableViewDataSource,MTPhotoPickerDelegate>{
    
    IBOutlet UITableView * table;

    NSArray * _photos;

}

@property(nonatomic,strong) MTPhotoPicker * pickerView;
@end

@implementation MTViewController

-(MTPhotoPicker *)pickerView{
    if(!_pickerView){
        
        _pickerView = [MTPhotoPicker pickerWithTitle:@"Choose Photo" alternateTitle:@"Attach %ld photo" otherTitles:@[@"Open gallery",@"Other title"] cancelTitle:@"Cancel"];
        
        
        [_pickerView setDelegate:self];
        
        
        //optional
        [_pickerView setThemeColor:[UIColor redColor]];
        
        [_pickerView setMaximumSelectCount:2];
    
    }
    return _pickerView;
}


-(IBAction)choosePhotos:(id)sender{
    
    
    [self.pickerView loadAssets:^{
        
      [self.pickerView showInView:self.view];
    
    }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",[NSBundle allBundles]);
    
    table.dataSource = self;
    _photos = [NSArray new];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



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


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_photos count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCell * cell = (PhotoCell *)[tableView dequeueReusableCellWithIdentifier:@"PhotoCellID"];
    

    ALAsset * asset = [_photos objectAtIndex:indexPath.row];
    
    cell.title.text = asset.description;
    
    [cell.photo setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    
    return cell;
}

@end
