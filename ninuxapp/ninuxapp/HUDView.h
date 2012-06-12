//
//  HUDView.h
//  ninuxapp
//
//  Created by Mara Sorella on 07/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol HUDViewDelegate <NSObject>



@required
- (IBAction) didPressOptionsButton;
@end



@interface HUDView : UIView{

id <HUDViewDelegate> delegate;

}


@end
