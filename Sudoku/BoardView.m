//
//  BoardView.m
//  Doodle
//
//  Created by ajs on 30/3/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "BoardView.h"
//#import "board.h"

static int nMinorLines[] = {0, 1, 2, 2, 3, 4, 4, 5, 6};
static int nMajorLines[] = {1, 1, 1, 2, 2, 2, 3, 3, 3};

@interface BoardView ()


@end

@implementation BoardView

-(instancetype) initWithFrame:(CGRect) rect
{
    self = [super initWithFrame:rect];
    self.selectedSquare = -1;
    self.solved = 0;
    self.checking = 0;
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    int boardwidth = self.bounds.size.width;
    int i;
    double pos;
    double minorOffset = MINORWIDTH / 2.0;
    double majorOffset = MAJORWIDTH / 2.0;
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Draw the thinner lines first
    CGContextSetLineWidth(context, MINORWIDTH);
    [[UIColor lightGrayColor] setStroke];
    CGContextBeginPath(context);
    pos = MAJORWIDTH + self.cellwidth + minorOffset;
    for(i = 0; i < 6; i++) {
        CGContextMoveToPoint(context, 0, pos);
        CGContextAddLineToPoint(context, boardwidth, pos);
        CGContextMoveToPoint(context, pos, 0);
        CGContextAddLineToPoint(context, pos, boardwidth);
        if((i % 2) == 0)
            pos += (self.cellwidth + MINORWIDTH);
        else
            pos += (self.cellwidth*2 + MINORWIDTH + MAJORWIDTH);
    }
    CGContextStrokePath(context);

    [[UIColor blackColor] setStroke];
    CGContextBeginPath(context);
    pos = majorOffset;
    CGContextSetLineWidth(context, MAJORWIDTH);
    for(i = 0; i < 4; i++) {
        CGContextMoveToPoint(context, 0, pos);
        CGContextAddLineToPoint(context, boardwidth, pos);
        CGContextMoveToPoint(context, pos, 0);
        CGContextAddLineToPoint(context, pos, boardwidth);
        pos += (self.cellwidth*3 + MINORWIDTH*2 + MAJORWIDTH);
    }
    CGContextStrokePath(context);
    
    int cellNum = 0;
    for(int r = 0; r < 9; r++)
        for(int c = 0; c < 9; c++) {
            int num = 1 + self.board[cellNum].digit;
            UIColor *numColour;
            if (self.board[cellNum].locked)
                numColour = [UIColor blueColor];
            else if(self.solved && self.checking && !self.board[cellNum].locked) {
                if (self.board[cellNum].digit != self.board[cellNum].solve)
                    numColour = [UIColor redColor];
                else
                    numColour = [UIColor greenColor];
            }
            else
                numColour = [UIColor blackColor];
            [self drawCell:num atRow: r atColumn: c selected:(cellNum == self.selectedSquare) textColour:numColour];
            cellNum++;
         }
}

-(CGRect)cellRect:(int) r column:(int) c
{
    int cellx = (self.cellwidth * c) + (MAJORWIDTH * nMajorLines[c]) + (MINORWIDTH * nMinorLines[c]);
    int celly = (self.cellwidth * r) + (MAJORWIDTH * nMajorLines[r]) + (MINORWIDTH * nMinorLines[r]);
    return CGRectMake(cellx, celly, self.cellwidth, self.cellwidth);
}

-(void)drawCell:(int) number
                  atRow:(int) r
               atColumn:(int) c
               selected:(int) s
            textColour:(UIColor *) tcolour
{
    CGRect cellrect = [self cellRect:r column:c];
    if(s)
        [[UIColor colorWithRed:0.8 green:1 blue:1 alpha:1] setFill];
    else
        [[UIColor colorWithRed:1 green:1 blue:0.9 alpha:1] setFill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, cellrect);
    if(number == 0)
        return;
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.cellwidth/2],
            NSForegroundColorAttributeName: tcolour};
    const NSString *text = [NSString stringWithFormat:@"%d", number];
    const CGSize textSize = [text sizeWithAttributes:attributes];
    CGFloat x = cellrect.origin.x + 0.5*(self.cellwidth - textSize.width);
    CGFloat y = cellrect.origin.y + 0.5*(self.cellwidth - textSize.height);
    const CGRect textRect = CGRectMake(x, y, textSize.width, textSize.height);
    [text drawInRect:textRect withAttributes:attributes];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint location = [t locationInView:self];
    int avgsize = self.bounds.size.width / 9;
    int r = location.y / avgsize;
    int c = location.x / avgsize;
    int cellnum = 9*r + c;
    if(self.board[cellnum].locked)
        return;
    if(cellnum == self.selectedSquare) {
        self.selectedSquare  = -1;
    }
    else {
        self.selectedSquare  = cellnum;
    }
    [self setNeedsDisplay];

}

@end

