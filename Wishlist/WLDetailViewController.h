//
//  WLDetailViewController.h
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLDetailViewController : UIViewController

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *occasionField;
@property (weak, nonatomic) IBOutlet UITextField *storeField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UILabel *dateMetadataLabel;


@end
