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

@property(nonatomic,strong) MTPhotoPicker * attachView;
@end

@implementation MTViewController

-(MTPhotoPicker *)attachView{
    if(!_attachView){
        
        
    
        NSBundle *bundle = [NSBundle bundleWithURL:[
                                                    [NSBundle mainBundle] URLForResource:@"MTPhotoPicker" withExtension:@"bundle"]];
        
        _attachView =  [[bundle loadNibNamed:@"MTPhotoPicker" owner:self options:nil] objectAtIndex:0];
        [_attachView setDelegate:self];
    }
    return _attachView;
}


-(IBAction)choosePhotos:(id)sender{
    
    [self.attachView showInView:self.view];
    
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
    
    _photos = assets;
    
    [table reloadData];
}


-(void)photoPickerDidDismiss{

    _attachView = nil;

}

- (void)photoPickerAddPhoto{
    [[[UIAlertView alloc] initWithTitle:@"Choose photo/video" message:@"launch photo viewer" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

- (void)photoPickerAddVideo{
    [[[UIAlertView alloc] initWithTitle:@"Capture photo/video" message:@"launch photo camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
