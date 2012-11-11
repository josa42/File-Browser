//
//  AppDelegate.m
//  FileBrowser
//
//  Created by Josa Gesell on 29.10.12.
//  Copyright (c) 2012 Josa Gesell. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    showInvisible = NO;
    
    filemgr = [NSFileManager defaultManager];
    
    [self changeDir:@"/Users/josa/"];
    
    
    // _tableView.dataSource = self;
    [_tableView setUsesAlternatingRowBackgroundColors:YES];
    [_tableView setAllowsColumnReordering:NO];
    [_tableView setAllowsColumnResizing:NO];
    [_tableView setAllowsTypeSelect:NO];
    
    [_tableView setDoubleAction:@selector(handleDoubleClick:)];
    
    // [_tableView reloadData];
    
}


- (void) handleDoubleClick:(id)sender
{
    [self changeDir];
}


- (void) tooggleVisible
{
    showInvisible = showInvisible == NO? YES: NO;
    NSInteger rowIndex = [_tableView selectedRow];
    NSString *fileName;
    if(rowIndex > 0) {
        NSURL *theURL = [filelist objectAtIndex: (rowIndex - 1)];
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
    }
    else {
        fileName = @"..";
    }
    
    [self loadFiles];
    [_tableView reloadData];
    
    rowIndex = [self quickSearch:fileName];
    [_tableView selectRowIndex:rowIndex];
}

- (void) loadFiles
{
    
    NSError *error;
    
    NSURL *url = [NSURL URLWithString: [currentpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if(showInvisible == YES) {
        filelist = [filemgr contentsOfDirectoryAtURL:url
                          includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                             options:0
                                               error:&error];
    } else {
        
        filelist = [filemgr contentsOfDirectoryAtURL:url
                          includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                               error:&error];
    }
    
    // NSLog(@"%@", error);
}

- (void)openCurrent
{
    [[NSWorkspace sharedWorkspace] openFile:currentpath];
}

- (void)openSelected
{
    NSInteger rowIndex = ([_tableView selectedRow]);
    
    if(rowIndex != 0) {
        
        NSURL *theURL = [filelist objectAtIndex: (rowIndex-1)];
        
        
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        
        [[NSWorkspace sharedWorkspace] openFile:fileName];
    }
    
}

- (void) changeDir
{
    NSInteger rowIndex = ([_tableView selectedRow]);
    
    NSString *dir;
    if(rowIndex == 0) {
        
        dir = @"..";
    } else {
        
        NSURL *theURL = [filelist objectAtIndex: (rowIndex-1)];
        
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        if(isDirectory.boolValue == YES) {
            [theURL getResourceValue:&dir forKey:NSURLNameKey error:NULL];
        } else {
            dir = @".";
        }
    }
    
    
    [self changeDir:dir];
}


- (void) changeDir: (NSString *)dir
{
    
    [filemgr changeCurrentDirectoryPath:dir];
    currentpath = [filemgr currentDirectoryPath];
    
    [self loadFiles];
    [_tableView reloadData];
    [_tableView selectRowIndex:0];
    
    
    self.headerLabel.stringValue = currentpath;
}




- (NSInteger) quickSearch:(NSString *)searchString
{
    return [self quickSearch:searchString withOffset:0];
}

- (NSInteger) quickSearch:(NSString *)searchString withOffset: (NSInteger)offset
{
    if(searchString != nil) {
        if(offset < 0) {
            offset = 0;
        }
    
        for (NSInteger rowIndex = offset; rowIndex < filelist.count; rowIndex++) {
        
        
            NSString *fileName;
            NSURL *theURL = [filelist objectAtIndex: rowIndex];
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
            NSRange r = [fileName rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if(r.length > 0) {
                
                return rowIndex + 1;
            }
        }
    }
    
    return -1;
}


- (void) selectNext:(NSString *)searchString
{
    NSInteger result = [self quickSearch:searchString withOffset:([_tableView selectedRow])];
    if(result < 0) {
        result = [self quickSearch:searchString];
    }
   
    if(result > 0) {
        [_tableView selectRowIndex:result];
    }
}


#pragma mark -
#pragma mark NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [filelist count] + 1;
}
- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    
    NSString *identifier = [aTableColumn identifier];
    
    
    NSTableCellView *cellView = [aTableView makeViewWithIdentifier:identifier owner:self];
    if ([identifier isEqualToString:@"name"]) {
        
        
        //[NSImage imageNamed:@"NSImageNameFolder"];
        
        // cellView.imageView.objectValue = image;
        
        if(rowIndex == 0) {
            cellView.imageView.objectValue = [NSImage imageNamed:@"NSImageNameFolder"];
            
            cellView.textField.stringValue = @"..";
        }
        else {
            
            NSURL *url = [filelist objectAtIndex: (rowIndex-1)];
            cellView.imageView.objectValue = [[NSWorkspace sharedWorkspace] iconForFile:[[url absoluteString] substringFromIndex:16]];
            
            NSString *fileName;
            [url getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            cellView.textField.stringValue = fileName; // [name objectAtIndex:name.count -1];
        }       
    }
    return cellView;

}
#pragma mark -


@end
