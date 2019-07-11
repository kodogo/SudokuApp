//
//  ViewController.h
//  Doodle
//
//  Created by ajs on 30/3/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ViewController : UIViewController
    <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>
	-(void) playAlert;
@end

