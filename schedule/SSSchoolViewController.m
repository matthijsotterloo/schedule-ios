//
//  SSSchoolViewController.m
//  schedule
//
//  Created by Thomas Schoffelen on 13/06/15.
//  Copyright © 2015 Scholica. All rights reserved.
//

#import "SSSchoolViewController.h"

@interface SSSchoolViewController ()

@end

@implementation SSSchoolViewController

NSArray* schools;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UISearchBar appearanceWhenContainedIn:[UIView class], nil] setBarTintColor:[UIColor whiteColor]];
    //[[UISearchBar appearanceWhenContainedIn:[UIView class], nil] setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText {
    if(searchBar == self.schoolsSearchBar){
        [[SSDataProvider instance] getSchoolsForProvider:@"magister" searchText:searchText controller:self];
    }
}

- (void)setResults:(NSMutableArray*)results {
    schools = [[NSArray alloc] initWithArray:results];
    [self.schoolsTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //return 4;
    return [schools count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"Testje";
    cell.detailTextLabel.text = @"Nog eentje";
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
