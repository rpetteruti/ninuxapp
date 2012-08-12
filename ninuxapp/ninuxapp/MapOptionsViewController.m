//
//  MapOptionsViewController.m
//  ninuxapp
//
//  Created by Mara Sorella on 11/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapOptionsViewController.h"



@implementation MapOptionsViewController


@synthesize segmentedControl,delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     NSLog(@"BLAH");
    [segmentedControl addTarget:self
                         action:@selector(valueChanged)
               forControlEvents:UIControlEventValueChanged];
    
    [segmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(IBAction)valueChanged{
    NSLog(@"Telling delegate to change map type to %u ...",[segmentedControl selectedSegmentIndex]);
    [self.delegate setMapType:[segmentedControl selectedSegmentIndex]];
}


@end
