//
//  board.h
//  Doodle
//
//  Created by ajs on 1/4/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#ifndef Doodle_board_h
#define Doodle_board_h

#define MAJORWIDTH 2
#define MINORWIDTH 1
#define KEYWIDTH 1
#define MARGIN 50

enum{
    Brdsize 	= 9,
    Psize 		= Brdsize * Brdsize,
    Alldigits 	= 0x1FF,
    Digit 		= 0x0000000F,
    Solve 		= 0x000000F0,
    Allow 		= 0x0001FF00,
    MLock 		= 0x00020000,
};

typedef struct Cell {
    int digit;
    int solve;
    int locked;
} Cell;

/* game.c */
int getrow(int cell);
int getcol(int cell);
int getbox(int cell);
void setdigit(int *board, int cc, int num);
int boxcheck(int *board);
int rowcheck(int *board);
int colcheck(int *board);
int setallowed(int *board, int cc, int num);
int chksolved(int *board);
void attempt(int *pboard, int level);
void clearp(int *board);
int makep(int *board);
int checkpossible(Cell *board, int squarenum, int num);


#endif
