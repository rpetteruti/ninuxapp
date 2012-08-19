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

/*!
 @function valueChanged
 It is called when a type of map is selected and call the delegate method
 */
-(IBAction) valueChanged;
@end
