//
//  WLDetailViewController.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLDetailViewController.h"

@interface WLDetailViewController ()

@end

@implementation WLDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_nameField setText:[_item itemName]];
    [_occasionField setText:[_item occasion]];
    [_storeField setText:[_item store]];
    [_priceField setText:[NSString stringWithFormat:@"%d", [_item price]]];
    [_dateMetadataLabel setText:[self dateMetadataText]];

    // Setup text changed notifcations
    [self addTextChangedNotification:_nameField];
    [self addTextChangedNotification:_occasionField];
    [self addTextChangedNotification:_storeField];
    [self addTextChangedNotification:_priceField];
}

-(void)addTextChangedNotification:(UITextField *)textField {
    // When any text field changes, invoke textChanged:
    [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
}

-(void)textChanged:(id)sender {
    // Text has changed in a field, so update the modified date and date metadata label
    [_item setDateModified:[[NSDate alloc] init]];
    [_dateMetadataLabel setText:[self dateMetadataText]];
}

-(NSString *)dateMetadataText {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    NSString *dateMetadata;
    NSString *dateAddedMetadata = [NSString stringWithFormat:@"Added %@",
                                   [dateFormatter stringFromDate:[_item dateCreated]]];

    if ([_item dateModified] == nil) {
        dateMetadata = [NSString stringWithFormat:@"%@", dateAddedMetadata];
    }
    else {
        NSString *dateModifiedMetadata = [NSString stringWithFormat:@"modified %@",
                                          [dateFormatter stringFromDate:[_item dateModified]]];
        dateMetadata = [NSString stringWithFormat:@"%@, %@", dateAddedMetadata, dateModifiedMetadata];
    }

    return dateMetadata;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Clear first responder status (endEditing forces any stubborn subviews to resign)
    [[self view] endEditing:YES];

    // Save changes to item (modified date is handled via text change notifications)
    [_item setItemName:[_nameField text]];
    [_item setOccasion:[_occasionField text]];
    [_item setStore:[_storeField text]];
    [_item setPrice:[[_priceField text] intValue]];
}

-(void)setItem:(WLItem *)item {
    _item = item;
    [[self navigationItem] setTitle:[_item itemName]];
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    // If device has camera take a picture, otherwise select from photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }

    // Set ourself as the image picker's delegate so we can respond when user chooses a photo or cancels
    [imagePicker setDelegate:self];

    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark Image Picker Delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Get selected image and update the image view
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_imageView setImage:image];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Text Field Delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
