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
    [map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960)];
    //[map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:13 animated:YES];
	[self performSelectorInBackground:@selector(populateMap) withObject:nil];
    
    
    
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


#pragma mark Map Stuff
-(void) populateMap{
    [self createEditableCopyOfDatabaseIfNeeded];//check if i need to create a writable file of the sqlite database
    NSError* error = nil;
    NSString *rawJson = [NSString stringWithContentsOfURL:[NSURL URLWithString: @"http://map.ninux.org/nodes.json"] encoding:NSASCIIStringEncoding error:&error];
    
    NSDictionary *items = [rawJson JSONValue];
    NSDictionary *nodes = [items valueForKeyPath:@"active"];
    
    NSArray *keys = [nodes allKeys];
    int count = 0;
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
        for (NSString *key in keys) {
            NSDictionary *node = [nodes objectForKey:key];
            NSLog(@"Node name: %@\n",[node objectForKey:@"name"]);
            NSLog(@"Node status: %@\n",[node objectForKey:@"status"]);
            //if (![node objectForKey:@"dummy"])NSLog(@"dato non presente");
            
            
            
            
            
            
            const char *sql_ins = "";
            
            sqlite3_stmt *insert_statement;
            if (sqlite3_prepare_v2(database, sql_ins, -1, &insert_statement, NULL) != SQLITE_OK)
            {
                NSAssert1(0, @"Error: failed to prepare statement with message ‘%s’.", sqlite3_errmsg(database));
            }else {
                sqlite3_stmt *statement;
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO nodes (name,lat,lng,type) VALUES(\"%@\",\"%@\",\"%@\",\"%@\")",[node objectForKey:@"name"],[node objectForKey:@"lat"],[node objectForKey:@"lng"],[node objectForKey:@"status"]];
                NSLog(@"insertSQL: %@",insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                if(sqlite3_step(statement) == SQLITE_DONE){
                    NSLog(@"Insert successful node");
                }else{
                    NSLog(@"Insert failed");
                }
                sqlite3_finalize(statement); 
                
                //NSLog(@"Node added");
            }
            
            
            
            count ++;
        }
        sqlite3_close(database);
        
    }else {
        sqlite3_close(database);
        NSLog(@"Error in databse connection");
    }
    
    NSLog(@"Number of nodes: %i",count);
    [self populateMapFromDB];
}

- (void)createEditableCopyOfDatabaseIfNeeded
{
	// First, test for existence.
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) return;
	// The writable database does not exist, so copy the default to the appropriate location.
	[fileManager removeItemAtPath:writableDBPath error:&error];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathDB];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) {
		NSAssert1(0, @"Failed to create writable database file with message ‘%@’.", [error localizedDescription]);
		NSLog(@"Failed to create writable database file with message ‘%@’.", [error localizedDescription]);
		
	}
}

-(void)populateMapFromDB{
    
    
    
    int power=0;
    sqlite3_stmt *selectstmt;
	const char *sql = "select name,lat,lng,type from nodes";
    NSLog(@"writable path:%@",writableDBPath);
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
            
		
    
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                CLLocationCoordinate2D annotationCoord;
                
                annotationCoord.latitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)]doubleValue];
                annotationCoord.longitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)]doubleValue];
                
                MKPointAnnotation *annotationPoint;
                annotationPoint = [[MKPointAnnotation alloc] init];
                annotationPoint.coordinate = annotationCoord;
                annotationPoint.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                annotationPoint.subtitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
                
                [map addAnnotation:annotationPoint];
                NSLog(@"added");
               
            }
        }
    }

    
    

}

@end
