//
//  MapOptionsViewController.h
//  ninuxapp
//
//  Created by Mara Sorella on 11/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MapOptionsDelegate <NSObject>
@required
- (void) setMapType:(NSUInteger)type;
@end



@interface MapOptionsViewController : UIViewController {

    
IBOutlet UISegmentedControl *segmentedControl;

}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) id <MapOptionsDelegate> delegate;


-(IBAction) valueChanged;
@end
