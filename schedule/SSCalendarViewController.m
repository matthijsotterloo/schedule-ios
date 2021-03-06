//
//  SSCalendarViewController.m
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SSCalendarViewController.h"
#import "ParentTableView.h"
#import "ParentTableViewCell.h"
#import "SubTableView.h"
#import "SubTableViewCell.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "MMMaterialDesignSpinner.h"

@interface SSCalendarViewController (){

    UIImage *userImage;
    bool syncing;
    bool userImageFromFile;
    NSInteger deltaTime;
    NSInteger baseTime;
    MMMaterialDesignSpinner *spinner;
}

@end

@implementation SSCalendarViewController

@synthesize data;
@synthesize footericon;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"MY SCHEDULE";
        
        self.data = [NSDictionary alloc];
        
        deltaTime = 0;
        baseTime = 0;
        userImageFromFile = NO;
    }
    
    return self;
}

-(void)login:(BOOL)animated {
    LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    [self.parentViewController presentViewController:vc animated:NO completion:nil];
}

-(void)viewDidLoad {
    
    [self.tableView setDataSourceDelegate:self];
    [self.tableView setTableViewDelegate:self];
    [self.tableView setOwnDelegate:self];
    
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    NSDictionary *dict = [self getDictFromFile:@"ScheduleCache-0"];
    if(dict){
        NSLog(@"Loading base entry from cache");
        [self loadWithData:dict];
    }
    
    self.title = [self labelFor:6];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-prev"] style:UIBarButtonItemStyleBordered target:self action:@selector(swipeFromLeft)];
    self.navigationItem.leftBarButtonItem = prevButton;
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-next"] style:UIBarButtonItemStyleBordered target:self action:@selector(swipeFromRight)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    // TODO: temporarily disabled this, needs to be improved some more to be user friendly
    
    //    NSString *provider = [[SSDataProvider instance] provider];
    //    if ([provider isEqualToString:@"somtoday"]) {
    //        // Grade button
    //        UIBarButtonItem *gradeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"GradesIcon"] style:UIBarButtonItemStyleBordered target:self action:@selector(goToGrades)];
    //        self.navigationItem.rightBarButtonItem = gradeButton;
    //        // Homework button
    //        UIBarButtonItem *homeworkButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HomeworkIcon"] style:UIBarButtonItemStyleBordered target:self action:@selector(goToHomework)];
    //        self.navigationItem.leftBarButtonItem = homeworkButton;
    //    }
}

- (void)goToGrades {
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [appDelegate.navigationController pushViewController:[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier:@"Grades"] animated:YES];
}

- (void)goToHomework {
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [appDelegate.navigationController pushViewController:[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier:@"Homework"] animated:YES];
}

-(NSString *) labelForInt:(int)m {
    switch (m) {
        case 0:
            return @"Oh, seems like not much is going on this week. Field trip? 🌴";
        
        case 1:
            return @"Whassup %@?";
            
        case 2:
            return @"\"In the first place, God made idiots. That was for practice. Then he made school boards.\" – Mark Twain";
            
        case 3:
            return @"Cancel";
            
        case 4:
            return @"Logout";
            
        case 5:
            return @"Refresh";
            
        case 6:
            return @"THIS WEEK";
            
        case 7:
            return @"LAST WEEK";
        
        case 8:
            return @"%i WEEKS AGO";
            
        case 9:
            return @"NEXT WEEK";
            
        case 10:
            return @"IN %i WEEKS";
            
        case 11:
            return @"Hint: swipe left or right.";
        
        case 12:
            return @"Credits";
        
        case 13:
            return @"Grades";
    }
    
    return nil;
}

- (NSString *) labelFor:(int)m {
    return NSLocalizedString([self labelForInt:m], nil);
}

-(void) initFooter:(bool)empty {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, empty ? screenRect.size.height-100 : 128)];
    
    if(!userImage){
        UIImage *img = [self getDictFromFile:@"UserImage"];
        if(img){
            userImage = img;
            userImageFromFile = YES;
        }
    }
    
    self.footericon = [[UIImageView alloc] initWithImage:userImage?:[UIImage imageNamed:@"userPlaceholder"]];
    footericon.frame = CGRectMake(screenRect.size.width/2-32, empty ? screenRect.size.height-164 : 32, 64, 64);
    footericon.layer.cornerRadius = 32;
    footericon.clipsToBounds = YES;
    [footericon setClipsToBounds:YES];
    
    footericon.userInteractionEnabled = YES;
    footericon.contentMode = UIViewContentModeScaleAspectFit;
    [footericon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)]];
    [footer addSubview:footericon];
    
    if(empty){
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, (screenRect.size.height-128)/3, screenRect.size.width-96, 100)];
        footerLabel.text = [self labelFor:0];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        footerLabel.numberOfLines = 3;
        footerLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        footerLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [footer addSubview:footerLabel];
        
        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, screenRect.size.height-220, screenRect.size.width-96, 20)];
        hintLabel.text = [self labelFor:11];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
        hintLabel.numberOfLines = 1;
        hintLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        hintLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        [footer addSubview:hintLabel];
    }
    
    self.tableView.tableFooterView = footer;
}

-(bool) writeDict:(id)dict file:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.dat", documentsDirectory, file];
    NSData *content = [NSKeyedArchiver archivedDataWithRootObject:dict];
    return [content writeToFile:fileName atomically:NO];
}
- (id)getDictFromFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.dat", documentsDirectory, file];
    NSData *content = [[NSData alloc] initWithContentsOfFile:fileName];
    if(!content) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithData:content];
}

-(void)handleUserTap:(UITapGestureRecognizer *)recognizer {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIAlertView *userAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:[self labelFor:1], appDelegate.user.name] message:[self labelFor:2] delegate:self cancelButtonTitle:[self labelFor:3] otherButtonTitles: [self labelFor:4], [self labelFor:12], nil];
    [userAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:[self labelFor:4]])
    {
        [appDelegate logout];
    }
    else if([title isEqualToString:[self labelFor:5]])
    {
        [self synchronize];
    }
    else if([title isEqualToString:[self labelFor:13]]){
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [appDelegate.navigationController pushViewController:[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier:@"Grades"] animated:YES];
    }
    else if([title isEqualToString:[self labelFor:12]]){
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [appDelegate.navigationController pushViewController:[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier:@"CreditsScreen"] animated:YES];
    }
}

- (void) loadWithData:(NSDictionary*)input {
    self.data = input;
    
    if (deltaTime == 0) {
        baseTime = [[self.data objectForKey:@"week_timestamp"] integerValue];
        NSLog(@"Set baseTime to %ld", (long)baseTime);
    }
    
    [self.tableView reloadData];
    
    [self initFooter:([[self.data objectForKey:@"days"] count] == 0)];
    [self updateTitle];
}

- (void) updateTitle {
    long weeks = deltaTime / 604800;
    
    // Current week
    if(weeks == 0){
        self.title = [self labelFor:6];
    }
    
    // Last/next week
    if(weeks == 1){
        self.title = [self labelFor:9];
    }
    if(weeks == -1){
        self.title = [self labelFor:7];
    }
    
    // X weeks ago/forward
    if(weeks < -1){
        self.title = [NSString stringWithFormat:[self labelFor:8], -weeks];
    }
    if(weeks > 1){
        self.title = [NSString stringWithFormat:[self labelFor:10], weeks];
    }
}

- (void) swipeFromLeft {
    deltaTime -= 604800;
    [self synchronize];
    [self updateTitle];
}
- (void) swipeFromRight {
    deltaTime += 604800;
    [self synchronize];
    [self updateTitle];
}

- (void) startSync {
    syncing = YES;
    [self.tableView startRefreshing];
}
- (void) stopSync {
    syncing = NO;
    [self.tableView doneRefreshing];
}

- (void) synchronize {
    if(syncing){
        NSLog(@"Sync already started");
        return;
    }
    
    NSLog(@"Sync started");
    
    [self startSync];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.tableView collapseAllRows];
    
    NSNumber *time = [NSNumber numberWithInt:(int)baseTime+(int)deltaTime];
    NSLog(@"Base: %ld, delta: %ld, TIME: %@", (long)baseTime, (long)deltaTime, time);
    
    NSDictionary *dict = [self getDictFromFile:[NSString stringWithFormat:@"ScheduleCache-%@", time]];
    if(dict){
        NSLog(@"Loading entry %@ from cache", time);
        [self loadWithData:dict];
        if(deltaTime <= 604800){
            [spinner stopAnimating];
        }
    }
    
    if(appDelegate.user.community){
        [[SSDataProvider instance] getCalendarWithTimestamp:(deltaTime == 0 ? @0 : time) callback:^(SARequestResult *result) {
            [self stopSync];
            
            if(result.status == SARequestStatusOK){
                NSLog(@"Sync successful");
                [self loadWithData:result.data];
                if (deltaTime == 0) {
                    [self writeDict:result.data file:@"ScheduleCache-0"];
                }
                [self writeDict:result.data file:[NSString stringWithFormat:@"ScheduleCache-%@", time]];
            }else if(result.error.code > 900){
                // Show login dialog, but only if the error is a Scholica error, not a network error
                NSLog(@"Scholica error, present login view: %@", result.error.errorDescription);
                [self login:YES];
            }else{
                // Network error, so try again in a couple of seconds
                NSLog(@"Network error, will try again soon.");
                [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(synchronize) userInfo:nil repeats:NO];
            }
        }];
    }else{
        syncing = NO;
        [appDelegate getUser];
    }
    
    if (!userImage || (userImageFromFile && [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi)) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData * data2 = [[NSData alloc] initWithContentsOfURL: appDelegate.user.picture];
                if ( data2 == nil ) return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Downloaded user image");
                    if (footericon){
                        userImageFromFile = NO;
                        footericon.image = userImage = [UIImage imageWithData: data2];
                        [self writeDict:userImage file:@"UserImage"];
                    }
                });
            });
    }
}

- (NSDictionary *)getDay:(NSInteger)num {
    NSArray *days = [self getDays];
    if([days count] <= num){
        return nil;
    }
    return [[self getDays] objectAtIndex:num];
}

- (NSDictionary *)getItem:(NSInteger)num forDay:(NSInteger)day {
    id items = [[[self getDays] objectAtIndex:day] objectForKey:@"items"];
    NSArray *objects;
    
    if([items isKindOfClass:[NSDictionary class]]){
        NSArray *sortedKeys = [items keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
            if ([[obj1 objectForKey:@"start"] intValue] > [[obj2 objectForKey:@"start"] intValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([[obj1 objectForKey:@"start"] intValue] < [[obj2 objectForKey:@"start"] intValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        objects = [items objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    }else{
        [items sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]]];
        objects = items;
    }
    
    return [objects objectAtIndex:num];
}

-(NSArray *)getDays {
    NSLog(@"Clas: %@", [[self.data objectForKey:@"days"] class]);
    if(self.data == nil || ![self.data objectForKey:@"days"]){
        return @[];
    }
    NSLog(@"DaysData: %@", [self.data objectForKey:@"days"]);
    NSDictionary *dict = [self.data objectForKey:@"days"];
    if(![dict respondsToSelector:@selector(allKeys)]){
        return @[];
    }
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSArray *objects = [dict objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    //NSLog(@"%@", objects);
    return objects;
}

#pragma mark - SubTableViewDelegate

// @optional
- (void)tableView:(UITableView *)tableView didSelectCellAtChildIndex:(NSInteger)childIndex withInParentCellIndex:(NSInteger)parentIndex {
    // ...
}
- (void)tableView:(UITableView *)tableView didDeselectCellAtChildIndex:(NSInteger)childIndex withInParentCellIndex:(NSInteger)parentIndex {
    // ...
}
- (void)tableView:(UITableView *)tableView didSelectParentCellAtIndex:(NSInteger)parentIndex {
    // ..
}


#pragma mark - SubTableDataSource - Parent

// @required
- (NSInteger)numberOfParentCells {
    if(self.data && [[self.data objectForKey:@"days"] count] == 0){
        return 0;
    }
    return 5;
}
- (NSInteger)heightForParentRows {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger numCells = [self numberOfParentCells];
    appDelegate.cellSize = (self.view.frame.size.height - 62) / numCells;
    return appDelegate.cellSize;
}

// @optional
- (NSString *)titleLabelForParentCellAtIndex:(NSInteger)parentIndex {
    
    if(self.data && [self getDay:parentIndex]){
        return [[[self getDay:parentIndex] objectForKey:@"day_title"] uppercaseString];
    }
    return @"";
}

- (UIColor *)backgroundColorForParentCellAtIndex:(NSInteger)parentIndex {
    
    if(![self getDay:parentIndex]){
        return [UIColor whiteColor];
    }
    
    switch ([[[self getDay:parentIndex] objectForKey:@"day_ofweek"] integerValue]) {
        case 1:
            return [UIColor colorWithRed:0.929 green:0.290 blue:0.392 alpha:1];
        case 2:
            return [UIColor colorWithRed:0.455 green:0.424 blue:0.906 alpha:1];
        case 3:
            return [UIColor colorWithRed:0.180 green:0.616 blue:0.969 alpha:1];
        case 4:
            return [UIColor colorWithRed:0.443 green:0.875 blue:0.443 alpha:1];
        case 5:
            return [UIColor colorWithRed:0.925 green:0.882 blue:0.373 alpha:1];
            
        default:
            return [UIColor whiteColor];
    }
}



#pragma mark - SubTableDataSource - Child

// @required
- (NSInteger)numberOfChildCellsUnderParentIndex:(NSInteger)parentIndex {
    if(self.data && [self getDay:parentIndex]){
        return [[[self getDay:parentIndex] objectForKey:@"items"] count];
    }
    return 0;
}
- (NSInteger)heightForChildRows {
    
    return 75;
}

// @optional
- (NSString *)titleLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    if(self.data){
        return [[self getItem:childIndex forDay:parentIndex] objectForKey:@"title"];
    }
    return @"";
}
- (NSString *)subtitleLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    if(self.data){
        NSDictionary* lesson = [self getItem:childIndex forDay:parentIndex];
        if([lesson objectForKey:@"teacher"]){
            return [NSString stringWithFormat:@"%@ - %@", [lesson objectForKey:@"teacher"],[lesson objectForKey:@"subtitle"]];
        }else{
            return [lesson objectForKey:@"subtitle"];
        }
    }
    return @"";
}

- (NSString *)durationLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    if(self.data){
        NSDictionary* lesson = [self getItem:childIndex forDay:parentIndex];
        if([lesson objectForKey:@"duration_str"]){
            return [lesson objectForKey:@"duration_str"];
        }
    }
    return @"";
}

- (NSString *)timeLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    if(self.data){
        NSDictionary* lesson = [self getItem:childIndex forDay:parentIndex];
        return [lesson objectForKey:@"start_str"];
    }
    return @"";
}

#pragma mark Pull to refresh

- (void)userPulledToRefresh {
    
    [self synchronize];
}

@end
