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
    
    NSError* error = nil;
    NSString *rawJson = [NSString stringWithContentsOfURL:[NSURL URLWithString: @"http://map.ninux.org/nodes.json"] encoding:NSASCIIStringEncoding error:&error];
    
    NSDictionary *items = [rawJson JSONValue];
    NSDictionary *nodes = [items valueForKeyPath:@"potential"];
    
    NSArray *keys = [nodes allKeys];
    int count = 0;
    for (NSString *key in keys) {
        NSDictionary *node = [nodes objectForKey:key];
        NSLog(@"Nome nodo: %@\n",[node objectForKey:@"name"]);
        NSLog(@"Stato nodo: %@\n",[node objectForKey:@"status"]);
        if (![node objectForKey:@"dummy"])NSLog(@"dato non presente");
        count ++;
    }
    
    NSLog(@"Totale numero di nodi: %i",count);
    
    
    
    
    
    
    
    
    
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

@end
