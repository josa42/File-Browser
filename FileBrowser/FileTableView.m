//
//  FileTableView.m
//  FileBrowser
//
//  Created by Josa Gesell on 30.10.12.
//  Copyright (c) 2012 Josa Gesell. All rights reserved.
//

#import "FileTableView.h"
#import "AppDelegate.h"

@implementation FileTableView

- (void) keyDown:(NSEvent *) theEvent
{
    if(searchString == nil) {
        searchString = @"";
    }
    
        
    AppDelegate *appDelegate = (AppDelegate *)self.delegate;
    NSString *chars = [theEvent charactersIgnoringModifiers];
    
    if ([theEvent type] == NSKeyDown && [chars length] == 1) {
        
        int val = [chars characterAtIndex:0];
        
        // NSLog(@"key: %d", val);
        
        switch (val) {
            case KEY_RETURN:
                
                if([self.delegate isKindOfClass: AppDelegate.class]) {
                    if ([theEvent modifierFlags] & NSShiftKeyMask) {
                        
                        [appDelegate openSelected];
                        return;
                    }
                    else if ([theEvent modifierFlags] & NSAlternateKeyMask) {
                        
                        [appDelegate openCurrent];
                        return;
                    }
                    [appDelegate changeDir];
                }
                return;
                
            case KEY_DOWN:
                
                if([self selectedRow] == [self numberOfRows]-1) {
                    [self selectRowIndex: 0];
                    return;
                }
                
                if ([theEvent modifierFlags] & NSShiftKeyMask) {
                    
                    [self selectRowIndex: [self selectedRow] + 10];
                    return;
                }
                [super keyDown:theEvent];
                break;
                
            case KEY_UP:
                
                if([self selectedRow] == 0) {
                    [self selectRowIndex: [self numberOfRows]-1];
                    return;
                }
                
                if ([theEvent modifierFlags] & NSShiftKeyMask) {
                    [self selectRowIndex: [self selectedRow] - 10];
                    return;
                }
                [super keyDown:theEvent];
                break;
            case KEY_TAB:
            case 25:
                
                if ([theEvent modifierFlags] & NSShiftKeyMask) {
                    [appDelegate selectPrevious: searchString];
                } else {
                    [appDelegate selectNext: searchString];
                }
                break;                
                
            case KEY_H:
                if ([theEvent modifierFlags] & NSCommandKeyMask) {
                    [appDelegate tooggleVisible];
                    return;
                }
            case KEY_SPACE:
                [appDelegate toggleDrawer];
            //     [appDelegate toogleQuickLook];
                break;
                
            case KEY_BACKSPACE:
            case KEY_ESC:
                searchString = @"";
                [appDelegate resetSearch];
                break;
                
                
                
            default:
                if(val >= 33 && val <= 126) {
                    [self addToQuickSearch:chars];
                }
                break;
        }
    }
    
    // [super keyDown:theEvent];
}



- (void) addToQuickSearch: (NSString *)chars
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    
    if(searchString == nil || (now - lastQuickSearch) > .5) {
        searchString = chars;
    } else {
        searchString = [NSString stringWithFormat:@"%@%@", searchString, chars ];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)self.delegate;
    
    NSInteger rowIndex = [appDelegate quickSearch: searchString];
    
    if(rowIndex >= 0) {
        [self selectRowIndex: rowIndex];
    } else {
        [self selectRowIndex: 0];
    }
    lastQuickSearch = now;
}

- (void) selectRowIndex:(NSInteger)rowIndex
{
    if(rowIndex < 0) {
        rowIndex = 0;
    } else if(rowIndex >= [self numberOfRows]) {
        rowIndex = [self numberOfRows] -1;
    }
    
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex]
      byExtendingSelection:NO];
    [self scrollRowToVisible:rowIndex];
    
    
}

/*
- (NSData *)getDataForFile:(NSString *)path
{
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    id preview = QLPreviewCreate(kCFAllocatorDefault, fileURL, 0);
    
    if (preview)
    {
        NSString* previewType = QLPreviewGetPreviewType(preview);
        
        if ([previewType isEqualToString:@"public.webcontent"])
        {
            // this preview is HTML data
            return QLPreviewCopyData(preview);
        }
        else
        {
            NSLog(@"this type is: %@", previewType);
            // do something else
        }
        
    }
    
    return nil;
}
*/



@end
