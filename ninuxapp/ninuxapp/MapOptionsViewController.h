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
    NSInteger state;

}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) id <MapOptionsDelegate> delegate;
@property (nonatomic, assign) NSInteger state;

-(IBAction) valueChanged;
@end
