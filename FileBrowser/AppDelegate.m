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
    
    hightlightedRows = [NSMutableDictionary dictionary];
    doHighlight = NO;
    
    
    // _tableView.dataSource = self;
    [_tableView setUsesAlternatingRowBackgroundColors:YES];
    [_tableView setAllowsColumnReordering:NO];
    [_tableView setAllowsColumnResizing:NO];
    [_tableView setAllowsTypeSelect:NO];
    
    [_tableView setDoubleAction:@selector(handleDoubleClick:)];
    
    // [_tableView reloadData];
    //[_drawer setMinContentSize:NSMakeSize(800, 400)];
    //[_drawer setContentSize:NSMakeSize(300, 400)];
    
    // [_drawer setMinContentSize:NSMakeSize(400, 400)];
    // [_drawer setMaxContentSize:NSMakeSize(400, 400)];
    // [_drawer openOnEdge:NSMaxXEdge];
    
}

- (void)toggleDrawer
{
    
    NSDrawerState state = [_drawer state];
    if (NSDrawerOpeningState == state || NSDrawerOpenState == state) {
        [_drawer close];
        //[_drawer setContentSize:NSMakeSize(0, 400)];
    } else {
        
        // [_drawer setContentSize:self.window.frame.size];
        [_drawer setContentSize:NSMakeSize(self.window.frame.size.width -34, 400)];
        [_drawer openOnEdge:NSMaxXEdge];
        //[_drawer setContentSize:NSMakeSize(300, 400)];
    }
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    // NSLog(@"%@", filename);
    [self changeDir:filename];
    
    return YES;
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
    
    /*
    filelist = [filemgr contentsOfDirectoryAtURL:url
                      includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                         options:0
                                           error:&error];
    if(showInvisible != YES) {
        NSMutableArray *tmpfiles = [NSMutableArray array];
        
        NSEnumerator *e = [filelist objectEnumerator];
        NSURL *fielUrl;
        while (fielUrl = (NSURL *)[e nextObject]) {
            
            NSString* theFileName = [[[fielUrl absoluteString] lastPathComponent] stringByDeletingPathExtension];
            
            NSLog(theFileName);
            
            if (![[theFileName substringToIndex:1] isEqualToString:@"."]) {
                [tmpfiles addObject:fielUrl];
            }
        }
        
        filelist = tmpfiles;
    }*/
    
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
    
    doHighlight = NO;
    
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
    NSInteger index = -1;
    
        if(offset < 0) {
            offset = 0;
        }
    
        [hightlightedRows removeAllObjects];
    
    doHighlight = NO;

        for (NSInteger rowIndex = 0; rowIndex < filelist.count; rowIndex++) {
        
        
            NSString *fileName;
            NSURL *theURL = [filelist objectAtIndex: rowIndex];
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
            NSRange r = [fileName rangeOfString:searchString options:NSCaseInsensitiveSearch];
            
            if(r.length > 0) {
                
                
                // NSLog(@"i: %i", rowIndex);
                if (searchString != nil) {
                    
                    if (index < 0 && rowIndex >= offset) {
                        index = (rowIndex + 1);
                        doHighlight =  YES;
                    }
                    
                    [hightlightedRows setObject:[NSNumber numberWithBool:YES] forKey: [NSNumber numberWithInteger:(rowIndex + 1) ]];
                
                }
            
            }
        }
    
    NSInteger row = [self.tableView selectedRow];
    [self.tableView reloadData];
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    return index;
}

- (void) resetSearch
{
    doHighlight = NO;
    [self.tableView reloadData];
    [_tableView selectRowIndex:0];
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

- (void) selectPrevious:(NSString *)searchString
{
    
    NSInteger result = [self quickSearch:searchString withOffset:([_tableView selectedRow])];
    
    
    if(result < 0) {
        result = [self quickSearch:searchString];
    }
    
    if(result > 0) {
        [_tableView selectRowIndex:result];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger rowIndex = ([_tableView selectedRow]);
    
    if(rowIndex != 0) {
        
        NSURL *theURL = [filelist objectAtIndex: (rowIndex-1)];
        _previewView.image = [self imageWithPreviewOfFileAtPath:[[theURL absoluteString] substringFromIndex:16] ofSize:NSMakeSize(400, 400) asIcon:NO];
    } else {
        _previewView.image = nil;
    }
    
    
}

- (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path ofSize:(NSSize)size asIcon:(BOOL)icon
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!path || !fileURL) {
        return nil;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:icon]
                                                     forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault,
                                            (__bridge CFURLRef)fileURL,
                                            CGSizeMake(size.width, size.height),
                                            (__bridge CFDictionaryRef)dict);
    
    if (ref != NULL) {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out to me.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep) {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];
            
            if (newImage) {
                return newImage;
            }
        }
        CFRelease(ref);
    } else {
        // If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        if (icon) {
            [icon setSize:size];
        }
        return icon;
    }
    
    return nil;
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
        
        if(rowIndex == 0) {
            cellView.imageView.objectValue = [NSImage imageNamed:@"NSImageNameFolder"];
            
            cellView.textField.stringValue = @"..";
        }
        else {
            
            NSURL *url = [filelist objectAtIndex: (rowIndex-1)];
            NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[[url absoluteString] substringFromIndex:16]];
			[cellView.imageView setImage:image];
            
            NSString *fileName;
            [url getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            cellView.textField.stringValue = fileName; // [name objectAtIndex:name.count -1];
        }       
    }
    
    NSNumber *n = (NSNumber *)[hightlightedRows objectForKey:[NSNumber numberWithInteger:rowIndex]];
    
    if (doHighlight == NO || (n != NULL && [n boolValue] == YES)) {
        // cellView.textField.drawsBackground = YES;
        [cellView.textField setTextColor: [NSColor blackColor]];
    } else {
        // cellView.textField.drawsBackground = NO;
        [cellView.textField setTextColor: [NSColor lightGrayColor]];
    }
    
    // [cellView.textField setBackgroundColor:[NSColor lightGrayColor]];
    // [cellView.imageView setBackgroundColor:[NSColor lightGrayColor]];
    // cellView.textField.drawsBackground = YES;
    
    return cellView;

}
#pragma mark -


@end
