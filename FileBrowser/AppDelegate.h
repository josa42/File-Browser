//
//  AppDelegate.h
//  FileBrowser
//
//  Created by Josa Gesell on 29.10.12.
//  Copyright (c) 2012 Josa Gesell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileTableView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate> {
    
    NSFileManager *filemgr;
    
    BOOL showInvisible;
    
    NSString *currentpath;
    NSArray *filelist;
    
    
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void) handleDoubleClick:(id)sender;
- (void) loadFiles;
- (void) openCurrent;
- (void) openSelected;
- (void) changeDir;
- (void) changeDir: (NSString *)dir;
- (NSInteger) quickSearch:(NSString *)searchString;
- (NSInteger) quickSearch:(NSString *)searchString withOffset: (NSInteger)offset;
- (void) selectNext:(NSString *)searchString;
- (void) tooggleVisible;

#pragma mark -
#pragma mark NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
#pragma mark -

@property (assign) IBOutlet NSWindow *window;
@property(assign) IBOutlet FileTableView *tableView;
@property(assign) IBOutlet NSTextField *headerLabel;

@end
