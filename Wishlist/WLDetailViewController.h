//
//  WLDetailViewController.h
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLItem.h"

@interface WLDetailViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *occasionField;
@property (weak, nonatomic) IBOutlet UITextField *storeField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UILabel *dateMetadataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

// Non-outlet properties
@property (nonatomic, strong) WLItem *item;
@property (nonatomic, strong) UIPopoverController *imagePickerPopover;
@property (nonatomic, copy) void (^dismissBlock)(void);

// Methods
-(id)initForNewItem:(BOOL)isNew;

// Actions
- (IBAction)takePicture:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

@end
