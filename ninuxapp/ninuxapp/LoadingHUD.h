//
//  LoadingHUD.h
//  ninuxapp
//
//  Created by Mara Sorella on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingHUD : UIView {
    
    UIActivityIndicatorView *spinner;
    
    
    
}


@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@end
