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
NSString* site;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.schoolsSearchBackgroundView.backgroundColor = [UIColor colorWithRed:0.929 green:0.290 blue:0.392 alpha:1];
    
    [self.schoolsSearchLabel setText:NSLocalizedString(@"SEARCH YOUR SCHOOL", nil)];
    
    [self.schoolsSearchBar setPlaceholder:NSLocalizedString(@"Search your school...", nil)];
    [self.schoolsSearchBar setBarTintColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [[SSDataProvider instance] prefillListForProvider:self.provider controller:self];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText {
    if(searchBar == self.schoolsSearchBar){
        [[SSDataProvider instance] getSchoolsForProvider:self.provider searchText:searchText controller:self];
    }
}

- (void)setSearchResults:(NSMutableArray*)results {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[schools objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    return cell;
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if([schools objectAtIndex:indexPath.row]) {
        site = [[schools objectAtIndex:indexPath.row] objectForKey:@"site"];
        [SSDataProvider invokeLoginDialogForProvider:self.provider site:site title:[[schools objectAtIndex:indexPath.row] objectForKey:@"title"]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
