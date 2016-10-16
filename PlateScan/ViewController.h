//
//  ViewController.h
//  PlateScan
//
//  Created by Rafael Barzotto on 14/10/16.
//  Copyright © 2016 Rafael Barzotto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)choosePhoto:(UIButton *)sender;
- (IBAction)runRecognition:(UIButton *)sender;
- (IBAction)getImg:(UIButton *)sender;

@end

