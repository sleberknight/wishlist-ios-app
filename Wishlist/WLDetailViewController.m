//
//  WLDetailViewController.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLDetailViewController.h"
#import "WLImageStore.h"
#import "WLItemStore.h"
#import <QuartzCore/QuartzCore.h>

@interface WLDetailViewController ()

@property (nonatomic, assign) BOOL isNewItem;

@end

@implementation WLDetailViewController

-(id)initForNewItem:(BOOL)isNew {
    NSLog(@"%@, isNew: %u", NSStringFromSelector(_cmd), isNew);

    self = [super initWithNibName:@"WLDetailViewController" bundle:nil];

    if (self && isNew) {
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [[self navigationItem] setRightBarButtonItem:doneItem];

        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];

        // Set whether this is for a new item
        _isNewItem = isNew;
    }

    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem"
                                 userInfo:nil];
    return nil;
}

-(void)done:(id)sender {
    // Note that we only dismiss here; we save the item details in viewWillDisappear:animated:
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
}

-(void)cancel:(id)sender {
    // User cancelled so remove item from the store
    [[WLItemStore defaultStore] removeItem:_item];

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // If on iPad set the background to a light gray to match the table view's background
        UIColor *bgColor = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1];
        [[self view] setBackgroundColor:bgColor];
    }
    else {
        // On iPhone the groupTableViewBackgroundColor is deprecated and gives a white background,
        // per http://stackoverflow.com/questions/12452810/is-grouptableviewbackgroundcolor-deprecated-on-ios-6
        // The solution (read as "hack") is to create an empty table view and place it behind the content.
        // TODO This "solution" for background breaks the UIControl sending "touch up inside" action (i.e. to
        //      the backgroundTapped: method in this class). Can that be fixed?
        CGRect rect = [[self view] bounds];
        UITableView *tv = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
        [[self view] addSubview:tv];
        [[self view] sendSubviewToBack:tv];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Populate fields from item
    [_nameField setText:[_item itemName]];
    [_occasionField setText:[_item occasion]];
    [_storeField setText:[_item store]];
    [self setPriceFieldText];
    [_dateMetadataLabel setText:[self dateMetadataText]];

    // Setup text changed notifications
    [self addTextChangedNotification:_nameField];
    [self addTextChangedNotification:_occasionField];
    [self addTextChangedNotification:_storeField];
    [self addTextChangedNotification:_priceField];

    // Get image from store
    NSString *imageKey = [_item imageKey];
    UIImage *image = nil;
    if (imageKey) {
        image = [[WLImageStore defaultStore] imageForKey:imageKey];

        UIImage *imageWithBorder = [self drawBorderAround:image];
        [self addShadowToImageView];

        [_imageView setImage:imageWithBorder];
    }
}

-(void)setPriceFieldText {
    if ([_item price] == 0) {
        [_priceField setText:@""];
    }
    else {
        [_priceField setText:[NSString stringWithFormat:@"%d", [_item price]]];
    }
}

-(UIImage *)drawBorderAround:(UIImage *)image {
    CGSize imageSize = [image size];
    CGRect imageRect = [WLImageStore rectForImage:image withSize:imageSize];
    UIGraphicsBeginImageContext(imageSize);
    [image drawInRect:imageRect];

    CGFloat frameWidth = 2.0;
    CGRect frameRect = CGRectInset(imageRect, frameWidth / 2.0, frameWidth / 2.0);
    UIBezierPath *frame = [UIBezierPath bezierPathWithRect:frameRect];
    [frame setLineWidth:frameWidth];
    [[UIColor darkGrayColor] setStroke];
    [frame stroke];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

-(void)addShadowToImageView {
    CALayer *layer = [_imageView layer];
    [layer setShadowRadius:5.0];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOffset:CGSizeMake(8.0, 8.0)];
    [layer setShadowOpacity:0.75];
}

-(void)addTextChangedNotification:(UITextField *)textField {
    // When any text field changes, invoke textChanged:
    [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
}

-(void)textChanged:(id)sender {
    // Text has changed in a field, so update the modified date and date metadata label
    [self updateDataMetadataForNewModification];
}

-(void)updateDataMetadataForNewModification {
    if (!_isNewItem) {
        // Only ever update modified date when editing existing items
        [_item setDateModified:[[NSDate alloc] init]];
        [_dateMetadataLabel setText:[self dateMetadataText]];
    }
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

    if ([_imagePickerPopover isPopoverVisible]) {
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
        return;
    }

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

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [_imagePickerPopover setDelegate:self];
        [_imagePickerPopover presentPopoverFromBarButtonItem:sender
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
    }
    else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

// When the user touches anywhere on the view while editing, causes the view or a text field
// being edited to resign as first responder, which dismisses the keyboard
- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
}

#pragma mark Popover Controller Delegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _imagePickerPopover = nil;
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

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Need to set image here since the detail view is not going to reload like it does
        // when the image picker controller is modal (like with iPhone)
        // TODO Add border and shadow around image for iPad here...
        [_imageView setImage:image];
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    [self updateDataMetadataForNewModification];
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
