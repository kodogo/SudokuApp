//
//  dance.h
//  dance
//
//  Created by ajs on 12/9/13.
//  Copyright (c) 2013 ajs. All rights reserved.
//

#ifndef dance_dance_h
#define dance_dance_h

typedef struct Node Node;
typedef struct Col Col;

struct Node {
    Node *left;
    Node *right;
    Node *up;
    Node *down;
    Col *col; // May not be needed if make header row sparse-ish
};

struct Col {
    Node head; // Head of list of rows for this node. Not actually a row itself, just used for up and down links
    int len; // The number of rows currently in the column's list
    int index;
    // Don't call the next two left and right because the column list is circular
    Col *prev;
    Col *next;
};

void copyboard(Cell *brd, int *board);
int knuthsolve(Cell *board);

#endif
