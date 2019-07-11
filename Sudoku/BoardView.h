//
//  BoardView.h
//  Doodle
//
//  Created by ajs on 30/3/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "board.h"

@interface BoardView : UIView
@property int cellwidth;
@property Cell *board;
@property int selectedSquare;
@property int solved;
@property int checking;
@property (weak, nonatomic) ViewController  *parentVC;
@end
