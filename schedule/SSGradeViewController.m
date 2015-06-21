//
//  SSCalendarViewController.m
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SSGradeViewController.h"
#import "ParentTableView.h"
#import "ParentTableViewCell.h"
#import "SubTableView.h"
#import "SubTableViewCell.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "MMMaterialDesignSpinner.h"

@interface SSGradeViewController (){
    
    UIImage *userImage;
    bool syncing;
    bool userImageFromFile;
    NSInteger deltaTime;
    NSInteger baseTime;
    MMMaterialDesignSpinner *spinner;
}

@end

@implementation SSGradeViewController

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
    
    [self synchronize];
    
    [self.tableView setDataSourceDelegate:self];
    [self.tableView setTableViewDelegate:self];
    
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
  
    spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    spinner.lineWidth = 1.5f;
    spinner.tintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    NSDictionary *dict = [self getDictFromFile:@"GradesCache-0"];
    if(dict){
        NSLog(@"Loading base entry from cache");
        [self loadWithData:dict];
    }
    
    self.title = [self labelFor:6];
    
    [self.tableView tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
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
            return @"LAATSTE CIJFERS";
            
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
    
    UIAlertView *userAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:[self labelFor:1], appDelegate.user.name] message:[self labelFor:2] delegate:self cancelButtonTitle:[self labelFor:3] otherButtonTitles:[self labelFor:5], [self labelFor:4], [self labelFor:12], nil];
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
    else if([title isEqualToString:[self labelFor:12]]){
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [appDelegate.navigationController pushViewController:[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier:@"CreditsScreen"] animated:YES];
    }
    else if([title isEqualToString:[self labelFor:13]]){
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [appDelegate.navigationController pushViewController:[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier:@"Grades"] animated:YES];
    }
    
    
}

- (void) loadWithData:(NSDictionary*)input {
    self.data = input;
    
    if (deltaTime == 0) {
        baseTime = [[self.data objectForKey:@"week_timestamp"] integerValue];
        NSLog(@"Set baseTime to %ld", (long)baseTime);
    }
    
    [self.tableView reloadData];
    
    [self initFooter:([[self.data objectForKey:@"items"] count] == 0)];
}

- (void) startSync {
    syncing = YES;
    [spinner startAnimating];
}
- (void) stopSync {
    syncing = NO;
    [spinner stopAnimating];
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
    
    NSDictionary *dict = [self getDictFromFile:[NSString stringWithFormat:@"GradesCache-%@", time]];
    if(dict){
        NSLog(@"Loading entry %@ from cache", time);
        [self loadWithData:dict];
        if(deltaTime <= 604800){
            [spinner stopAnimating];
        }
    }
    
    if(appDelegate.user.community){
        
        [[SSDataProvider instance] getGrades: ^(SARequestResult *result) {
            [self stopSync];
            
            if(result.status == SARequestStatusOK){
                NSLog(@"Sync successful");
                
                [self loadWithData:result.data];
                if (deltaTime == 0) {
                    [self writeDict:result.data file:@"GradesCache-0"];
                }
                [self writeDict:result.data file:[NSString stringWithFormat:@"GradesCache-%@", time]];
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
    NSDictionary *dict = [self.data objectForKey:@"days"];
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSArray *objects = [dict objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    //NSLog(@"%@", objects);
    return objects;
}

- (NSDictionary *)getGradeInfoForChildIndex:(NSInteger)index {
    
    return [(NSArray *)[self.data objectForKey:@"items"] objectAtIndex:index];
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

    return 1;
}
- (NSInteger)heightForParentRows {
    
    return 0;
}

// @optional
- (NSString *)titleLabelForParentCellAtIndex:(NSInteger)parentIndex {
    
    return @"";
}

- (UIColor *)backgroundColorForParentCellAtIndex:(NSInteger)parentIndex {
        
        return [UIColor colorWithRed:0.0 green:0.05 blue:0.4 alpha:1.0];
}



#pragma mark - SubTableDataSource - Child

// @required
- (NSInteger)numberOfChildCellsUnderParentIndex:(NSInteger)parentIndex {
    
    if(self.data){
        return [[self.data objectForKey:@"items"] count];
    }
    return 0;
}
- (NSInteger)heightForChildRows {
    
    
    return 75;
}

// @optional
- (NSString *)titleLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    if(self.data){
        return [[self getGradeInfoForChildIndex:childIndex] objectForKey:@"description"];
    }
    return @"";
}
- (NSString *)subtitleLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    
    if(self.data){
        return [NSString stringWithFormat:@"%@ - %@", [[self getGradeInfoForChildIndex:childIndex] objectForKey:@"title"],  [[self getGradeInfoForChildIndex:childIndex] objectForKey:@"subtitle"]];
    }
    return @"";
}

- (NSString *)timeLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    if(self.data){
        return [[self getGradeInfoForChildIndex:childIndex] objectForKey:@"grade"];
    }
    return @"";
}

@end
