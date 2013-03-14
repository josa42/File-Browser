//
//  FileTableView.h
//  FileBrowser
//
//  Created by Josa Gesell on 30.10.12.
//  Copyright (c) 2012 Josa Gesell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "keycodes.h"
#import <Quartz/Quartz.h>

@interface FileTableView : NSTableView {
    
    NSString *searchString;
    NSTimeInterval lastQuickSearch;
}

- (void) keyDown:(NSEvent *) theEvent;
- (void) addToQuickSearch: (NSString *)chars;
- (void) selectRowIndex:(NSInteger)rowIndex;

@end
