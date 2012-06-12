//
//  FirstViewController.h
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUDView.h"
#import "MapVisualizationOptionsViewController.h"

@interface FirstViewController : UIViewController <UIGestureRecognizerDelegate,HUDViewDelegate>{
    
    NSTimer *myTimer;
    
    UISearchDisplayController *displayController;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UIView * view;
    BOOL  controlsAreDisplayed;
    HUDView *hudView;
}



@end
