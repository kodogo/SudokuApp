//
//  ViewController.m
//  Doodle
//
//  Created by ajs on 30/3/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "ViewController.h"
#import "BoardView.h"
#import "KeyboardView.h"
#import "board.h"
#include <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "dance.h"

#define TOOLBARHEIGHT 44
#define STATUSBARHEIGHT 20

@interface ViewController ()
@property(strong, nonatomic) BoardView *boardView;
@property(strong, nonatomic) KeyboardView *keyboardView;
@property int cellWidth;
@property int boardWidth;
@property (strong, nonatomic) NSArray *problemTypes;
@property int selectedIndex;
@property (copy, nonatomic) NSArray *sounds;
@property SystemSoundID alertSoundId;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation ViewController

Cell board[81];

- (void)viewDidLoad {
	int cHeight, cWidth;
    [super viewDidLoad];
    // Create the board view
	cHeight = self.view.bounds.size.height - (TOOLBARHEIGHT + STATUSBARHEIGHT);
	cWidth = self.view.bounds.size.width;
	self.boardWidth = 0.8 * MIN(cHeight, cWidth);
    self.cellWidth = (self.boardWidth - (4 * MAJORWIDTH) - (6 * MINORWIDTH)) / 9;
    self.boardWidth = (9 * self.cellWidth) + (4 * MAJORWIDTH) + (6 * MINORWIDTH);

	CGRect boardFrame;
    CGRect keyFrame;
    [self getSubviewFrames:&boardFrame keyboardFrame:&keyFrame windowSize:self.view.bounds.size];
    
    self.boardView = [[BoardView alloc] initWithFrame:CGRectMake(boardFrame.origin.x, boardFrame.origin.y, self.boardWidth, self.boardWidth)];
    self.boardView.backgroundColor = [UIColor whiteColor];
    self.boardView.cellwidth = self.cellWidth;
	self.boardView.parentVC = self;
    [self.view addSubview: self.boardView]; // add it to main view
    
    self.keyboardView = [[KeyboardView alloc] initWithFrame:CGRectMake(keyFrame.origin.x, keyFrame.origin.y, keyFrame.size.width, keyFrame.size.height)];
    self.keyboardView.backgroundColor = [UIColor whiteColor];
    self.keyboardView.cellwidth = self.cellWidth;
	self.keyboardView.parentVC = self;
    [self.view addSubview: self.keyboardView]; // add it to main view
    
    self.keyboardView.boardView = self.boardView;
    self.boardView.board = board;
    [self clearBoard:self];
    self.problemTypes = @[@"Very easy", @"Easy", @"Medium", @"Hard", @"Very hard"];

	OSStatus status;
	status = AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([[NSBundle mainBundle] URLForResource: @"alert" withExtension: @"aif"]),											  &_alertSoundId);
	if (status != noErr) {
		NSLog(@"Cannot create sound: %d", (int)status);
	}
	
	self.sounds = @[@"snd000", @"snd001", @"snd002", @"snd010", @"snd012", @"snd060",
					@"snd111", @"snd112", @"snd120", @"snd122", @"snd132", @"snd140"];

	[self newPuzzle:self];
}

-(void)getSubviewFrames:(CGRect *) boardFrame keyboardFrame:(CGRect *) keyFrame windowSize:(CGSize) size
{
	int cHeight, cWidth;
	cHeight = size.height - (TOOLBARHEIGHT + STATUSBARHEIGHT);
	cWidth = size.width;
	self.boardWidth = 0.8 * MIN(cHeight, cWidth);
	self.cellWidth = (self.boardWidth - (4 * MAJORWIDTH) - (6 * MINORWIDTH)) / 9;
	self.boardWidth = (9 * self.cellWidth) + (4 * MAJORWIDTH) + (6 * MINORWIDTH);
	self.boardView.cellwidth = self.cellWidth;
	self.keyboardView.cellwidth = self.cellWidth;
	if(size.width < size.height) {
        boardFrame->origin.x = (size.width - self.boardWidth) / 2;
        boardFrame->origin.y = STATUSBARHEIGHT + boardFrame->origin.x;
        boardFrame->size.width = self.boardWidth;
        boardFrame->size.height = self.boardWidth;
        keyFrame->size.height = (3 * KEYWIDTH) + (2 * self.cellWidth);
        keyFrame->size.width = (6 * KEYWIDTH) + (5 * self.cellWidth);
        keyFrame->origin.x = boardFrame->origin.x + (self.boardWidth - keyFrame->size.width) / 2;
        keyFrame->origin.y = boardFrame->origin.y + self.boardWidth + self.cellWidth;
    }
    else {
        boardFrame->origin.y = STATUSBARHEIGHT + (cHeight - self.boardWidth) / 2;
        //boardFrame->origin.x = boardFrame->origin.y;
		boardFrame->origin.x = self.cellWidth;
        boardFrame->size.width = self.boardWidth;
        boardFrame->size.height = self.boardWidth;
        keyFrame->size.width = (3 * KEYWIDTH) + (2 * self.cellWidth);
        keyFrame->size.height = (6 * KEYWIDTH) + (5 * self.cellWidth);
        keyFrame->origin.x = boardFrame->origin.x + self.boardWidth + self.cellWidth;
        keyFrame->origin.y = boardFrame->origin.y + (self.boardWidth - keyFrame->size.height) / 2;
    }
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    CGRect boardFrame;
    CGRect keyFrame;
    [self getSubviewFrames:&boardFrame keyboardFrame:&keyFrame windowSize:size];
    [self.boardView setFrame:boardFrame];
    [self.keyboardView setFrame:keyFrame];
    [self.boardView setNeedsDisplay];
    [self.keyboardView setNeedsDisplay];
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

- (IBAction)clearBoard:(id)sender {
    for(int i = 0; i < 81; i++) {
        board[i].digit = -1;
        board[i].solve = -1;
        board[i].locked = 0;
     }
    self.boardView.selectedSquare = -1;
    self.boardView.solved = 0;
    [self.boardView setNeedsDisplay];
}

- (IBAction)resetBoard:(id)sender {
    for(int i = 0; i < 81; i++) {
        if(!board[i].locked) {
            board[i].digit = -1;
            //board[i].solve = -1;
        }
    }
    self.boardView.selectedSquare = -1;
    [self.boardView setNeedsDisplay];
}

- (IBAction)solveBoard:(id)sender {
    if(knuthsolve(board)) {
        for(int i = 0; i < 81; i++)
            board[i].digit = board[i].solve;
        self.boardView.selectedSquare = -1;
        [self.boardView setNeedsDisplay];
    }
    else
        [self displayFailAlert];
}

-(void)displayFailAlert
{
    UIAlertController *noSolutionAlert =
    [UIAlertController
     alertControllerWithTitle:@"No Solution"
     message:@"The Soduko problem you specified has no solution."
     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:@"OK"
                             style: UIAlertActionStyleCancel handler:nil];
    [noSolutionAlert addAction:cancelAction];
    [self presentViewController:noSolutionAlert animated:YES completion:nil];
}

- (IBAction)newPuzzle:(id)sender {
    int brd[Psize];
    if(makep(brd)) {
        copyboard(board, brd);
        self.boardView.solved = 1;
        [self.boardView setNeedsDisplay];
        self.boardView.selectedSquare = -1;
    }
}

- (IBAction)checkOn:(id)sender {
    self.boardView.checking = 1;
    [self.boardView setNeedsDisplay];
}

- (IBAction)checkOff:(id)sender {
    self.boardView.checking = 0;
    [self.boardView setNeedsDisplay];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake)
	{
		int nsounds = [self.sounds count];
		int n = arc4random_uniform(nsounds);
		NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.sounds[n]
																			ofType:@"mp3"]];
		NSError *error;
		self.audioPlayer = [[AVAudioPlayer alloc]
						initWithContentsOfURL:url
						error:&error];
		if (error) {
			NSLog(@"Error in audioPlayer: %@",
				  [error localizedDescription]);
		} else {
			[self.audioPlayer play];
		}
	}
}

- (void) playAlert
{
	AudioServicesPlayAlertSound(self.alertSoundId);
}

@end
