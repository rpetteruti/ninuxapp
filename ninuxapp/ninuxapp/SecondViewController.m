//
//  SecondViewController.m
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "SBJson.h"



@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:pathDB];
    NSLog(@"Start populating map...");
  
    //[map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:13 animated:YES];
	    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchNodes:)     object:searchText];
    
    NSLog(@"Search bar:%@",searchText);
    
    [self performSelector:@selector(searchNodes:) withObject:searchText afterDelay:1.5];
}

-(void)searchNodes:(NSString *)searchText{
    sqlite3_stmt *selectstmt;
	//const char *sql = "select name from nodes";
    NSString *sqlSearch = [NSString stringWithFormat:@"SELECT name FROM nodes WHERE name LIKE '%%%@%%'",searchText];
    NSLog(@"Search query:%@",sqlSearch);
    const char *sql = [sqlSearch UTF8String];
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {   
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
         
                NSString *nodeName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)] ;
             
                NSLog(@"Node found:%@",nodeName);
                
            }
        }
    }
    
}




@end
