//
//  ViewController.m
//  PlateScan
//
//  Created by Rafael Barzotto on 14/10/16.
//  Copyright © 2016 Rafael Barzotto. All rights reserved.
//

#import "ViewController.h"
#import "PlateScanner.h"
#import "Plate.h"

@interface ViewController ()
@property PlateScanner *plateScanner;
@property (strong, nonatomic) NSMutableArray *plates;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    if (! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *deviceNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"No Device" message:@"Camera is not available"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
        [deviceNotFoundAlert show];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)choosePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)runRecognition:(UIButton *)sender {
    //NSString *plateFilename = @"savedImage.jpg";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
   // NSLog(@"%@", paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
   // NSLog(@"%@", documentsDirectory);
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.jpg"];
    NSLog(@"%@", imagePath);
    
    // Do any additional setup after loading the view, typically from a nib.
    //self.imageView.image = [UIImage imageNamed:plateFilename];
    self.plateScanner = [[PlateScanner alloc] init];
    self.plates = [NSMutableArray arrayWithCapacity:0];
    
    
    //NSString *imagePath = [[NSBundle mainBundle] pathForResource:plateFilename ofType:nil];
    //NSLog(@"%@", imagePath);
    
    cv::Mat image = imread([imagePath UTF8String], CV_LOAD_IMAGE_COLOR);
    
    if (imagePath) {
        [self.plateScanner
         scanImage:image
         onSuccess:^(NSArray * results) {
             [self.plates addObjectsFromArray:results];
             [self.tableView reloadData];
         }
         onFailure:^(NSError * error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Error: %@", [error localizedDescription]);
                 [self showErrorDialogWithTitle:@"Error with scan."
                                        message:[NSString stringWithFormat:@"Unable to process license plate image: %@", [error localizedDescription]]];
             });
         }];
        
    }
    else {
        // Hackity Hack Hack
        Plate *placeHolder = [[Plate alloc] init];
        placeHolder.number = @"ERROR: plateFileName not found";
        [self.plates addObject:placeHolder];
    }

}

- (IBAction)getImg:(UIButton *)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.jpg"];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    self.imageView.image = img;
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.jpg"];
    //UIImage *image = chosenImage // imageView is my image from camera
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    [imageData writeToFile:savedImagePath atomically:NO];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.plates.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Placas:";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Plate *plate = self.plates[indexPath.row];
    cell.textLabel.text = [plate number];
    return cell;
}

#pragma mark error

- (void)showErrorDialogWithTitle:(NSString *)title
                         message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    });
}
@end
