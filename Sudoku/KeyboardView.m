//
//  KeyboardView.m
//  Doodle
//
//  Created by ajs on 6/4/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "KeyboardView.h"
#import "board.h"

@interface KeyboardView ()
-(void)drawNumberInCell:(int) number atRow:(int) r atCol:(int) c;
@end

@implementation KeyboardView

int pressed[10];
int nrows;
int ncols;
int nSelected;

-(instancetype) initWithFrame:(CGRect) rect
{
    self = [super initWithFrame:rect];
    for(int i = 0; i < 10; i++)
        pressed[i] = 0;
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    int boardheight = self.bounds.size.height;
    int boardwidth = self.bounds.size.width;
    int i;
    int pos;
    double offset;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(context, KEYWIDTH);
    if(self.bounds.size.height < self.bounds.size.width) {
        nrows = 2;
        ncols = 5;
    }
   else {
       nrows = 5;
       ncols = 2;
   }
       
    offset = KEYWIDTH / 2.0;
    CGContextBeginPath(context);
    pos = 0;
    for(i = 0; i < nrows+1; i++) {
        CGContextMoveToPoint(context, 0, pos + offset);
        CGContextAddLineToPoint(context, boardwidth, pos + offset);
        pos += (self.cellwidth + KEYWIDTH);
    }
    
    pos = 0;
    for(i = 0; i < ncols+1; i++) {
        CGContextMoveToPoint(context, pos + offset, 0);
        CGContextAddLineToPoint(context, pos + offset, boardheight);
        pos += (self.cellwidth + KEYWIDTH);
       
    }
    CGContextStrokePath(context);

    for(int r = 0; r < nrows; r++)
        for(int c = 0; c < ncols; c++) {
            int number = (nrows > ncols) ? (r + 5*c) : (c + 5*r);
            CGRect cellrect = [self cellRect:r column:c];
            if(pressed[number])
                [[UIColor colorWithRed:0.8 green:1 blue:1 alpha:1] setFill];
            else
                [[UIColor colorWithRed:1 green:1 blue:0.9 alpha:1] setFill];
            CGContextFillRect(context, cellrect);
            [self drawNumberInCell:number atRow:r atCol:c];
        }

}

-(CGRect)cellRect:(int) r column:(int) c
{
    int cellx = (self.cellwidth * c) + (KEYWIDTH * (c + 1));
    int celly = (self.cellwidth * r) + (KEYWIDTH * (r + 1));
    return CGRectMake(cellx, celly, self.cellwidth, self.cellwidth);
}

-(void)drawNumberInCell:(int) number atRow:(int) r atCol:(int) c
{
    
    CGRect cellRect = [self cellRect:r column:c];
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.cellwidth/2],
                                  NSForegroundColorAttributeName: [UIColor blackColor] };
    const NSString *text;
    if(number == 9)
        text = @"⌫";
    else
        text = [NSString stringWithFormat:@"%d", number+1];
    const CGSize textSize = [text sizeWithAttributes:attributes];
    CGFloat x = cellRect.origin.x + 0.5*(self.cellwidth - textSize.width);
    CGFloat y = cellRect.origin.y + 0.5*(self.cellwidth - textSize.height);
    const CGRect textRect = CGRectMake(x, y, textSize.width, textSize.height);
    [text drawInRect:textRect withAttributes:attributes];
}

- (void)showRules:(int) num
{
	NSString *msg;
	msg = [NSString stringWithFormat:@"Number %d not allowed in square", num];
	UIAlertController *helpAlert =
	[UIAlertController
	 alertControllerWithTitle:@"Error"
	 message:msg
	 preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okAction =
	[UIAlertAction actionWithTitle:@"OK"
							 style: UIAlertActionStyleCancel handler:nil];
	[helpAlert addAction:okAction];
	[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:helpAlert animated:YES completion:nil];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.boardView.selectedSquare < 0)
        return;
    UITouch *t = [touches anyObject];
    CGPoint location = [t locationInView:self];
    int r = location.y / (self.cellwidth + KEYWIDTH);
    int c = location.x / (self.cellwidth + KEYWIDTH);
    nSelected = (nrows > ncols) ? (r + 5*c) : (c + 5*r);
    pressed[nSelected] = 1;
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	pressed[nSelected] = 0;

	if((nSelected >= 0) && (nSelected != 9) &&
	   !checkpossible(self.boardView.board, self.boardView.selectedSquare, nSelected)) {
		[self.parentVC playAlert];
		[self setNeedsDisplay];
		return;
	}
		
    if(nSelected != 9)
        self.boardView.board[self.boardView.selectedSquare].digit = nSelected;
    else
        self.boardView.board[self.boardView.selectedSquare].digit = -1;
    
//    self.boardView.selectedSquare = -1;
    [self setNeedsDisplay];
    [self.boardView setNeedsDisplay];
    
}
@end

