//
//  WLDetailViewController.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLDetailViewController.h"
#import "WLImageStore.h"

@interface WLDetailViewController ()

@end

@implementation WLDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Populate fields from item
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

    // Set the image
    NSString *imageKey = [_item imageKey];
    UIImage *image = nil;
    if (imageKey) {
        image = [[WLImageStore defaultStore] imageForKey:imageKey];
    }
    [_imageView setImage:image];
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

    // If item being edited has an image already, remove it from the item store
    NSString *oldImageKey = [_item imageKey];
    if (oldImageKey) {
        [[WLImageStore defaultStore] deleteImageForKey:oldImageKey];
    }

    // Grab the picked image
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // Create a new unique ID
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);

    // Create a string reference from the UUID
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);

    // Cast the string reference to an NSString (toll-free bridged)
    NSString *key = [NSString stringWithFormat:@"img-%@", (__bridge NSString *)newUniqueIDString];

    // Store the image key in the item
    [_item setImageKey:key];

    // Store the image
    [[WLImageStore defaultStore] setImage:image forKey:[_item imageKey]];

    // Release the Core Foundation objects
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);

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
