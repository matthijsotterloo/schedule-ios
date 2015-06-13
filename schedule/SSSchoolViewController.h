//
//  SSSchoolViewController.h
//  schedule
//
//  Created by Thomas Schoffelen on 13/06/15.
//  Copyright © 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SSSchoolViewController : UIViewController <UISearchBarDelegate>

@property IBOutlet UISearchBar *schoolsSearchBar;
@property IBOutlet UITableView *schoolsTableView;

- (void)setResults:(NSMutableArray*)results;

@end
