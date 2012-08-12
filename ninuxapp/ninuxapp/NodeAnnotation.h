//
//  NodeAnnotation.h
//  ninuxapp
//
//  Created by Mara Sorella on 11/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface NodeAnnotation : MKAnnotationView{
    
    IBOutlet UIButton *showLinksButton;
    IBOutlet UILabel *nodeNameLabel;
    
    
}


@property (nonatomic,retain) IBOutlet UIButton *showLinksButton;
@property (nonatomic,retain) IBOutlet UILabel *nodeNameLabel;


@end
