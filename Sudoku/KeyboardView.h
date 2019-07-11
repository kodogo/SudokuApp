//
//  KeyboardView.h
//  Doodle
//
//  Created by ajs on 6/4/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "BoardView.h"

@interface KeyboardView : UIView
@property int cellwidth;
@property (strong, nonatomic) BoardView *boardView;
@property (weak, nonatomic) ViewController  *parentVC;
@end
