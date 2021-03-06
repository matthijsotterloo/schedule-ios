//
//  ParentTableView.m
//  SubTableExample
//
//  Created by Alex Koshy on 7/16/14.
//  Copyright (c) 2014 ajkoshy7. All rights reserved.
//

#import "ParentTableView.h"
#import "ParentTableViewCell.h"
#import "ExpandedContainer.h"

@interface ParentTableView () {
    
    ParentTableViewCell *previouslySelectedCell;
    UIView *previousFooter;
}

@end

@implementation ParentTableView
@synthesize tableViewDelegate, expansionStates, isRefreshing= _isRefreshing;

NSNumber* extendedRow;

- (id)initWithFrame:(CGRect)frame dataSource:dataDelegate tableViewDelegate:tableDelegate {
    
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}
- (void)initialize {
    
    [self setDataSource:self];
    [self setDelegate:self];
    
    self.backgroundColor = [UIColor whiteColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.separatorColor = [UIColor darkGrayColor];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableFooterView = footer;
    
}

- (void)removeFooter {
    previousFooter = self.tableFooterView;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableFooterView = footer;
}
- (void)restoreFooter {
    self.tableFooterView = previousFooter;
}

- (IBAction)restoreFooterAction:(id)sender {
    [self restoreFooter];
}



#pragma mark - Configuration

- (id)getDataSourceDelegate {
    
    return dataSourceDelegate;
}
- (void)setDataSourceDelegate:(id)deleg {
    
    dataSourceDelegate = deleg;
    [self initExpansionStates];
}
- (void)initExpansionStates {
    
    expansionStates = [[NSMutableArray alloc] initWithCapacity:[self.dataSourceDelegate numberOfParentCells]];
    for(int i = 0; i < [self.dataSourceDelegate numberOfParentCells]; i++) {
        [expansionStates addObject:@"NO"];
    }
}



#pragma mark - Table Interaction

- (void)expandForParentAtRow:(NSInteger)row {
    
    NSUInteger parentIndex = [self parentIndexForRow:row];
    
    if (!self.shouldntReindent) {
        if ([[self.expansionStates objectAtIndex:parentIndex] boolValue]) {
            return;
        }
    }
    
    // update expansionStates so backing data is ready before calling insertRowsAtIndexPaths
    [self.expansionStates replaceObjectAtIndex:parentIndex withObject:@"YES"];
    
    [self removeFooter];
    
    if (!self.shouldntReindent) {
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        
        int actualRow = 0;
        
        for (int i = 0; i < row; i++) {
            
           actualRow += [self numberOfChildrenUnderParentIndex:i] + 1;
        }
        
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(actualRow+1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(restoreFooterAction:) userInfo:nil repeats:NO];
    
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    extendedRow = [NSNumber numberWithInteger:row];
}

- (void)collapseForParentAtRow:(NSInteger)row {
    
    if (![self.dataSourceDelegate numberOfParentCells] > 0) {
        return;
    }
    
    NSUInteger parentIndex = [self parentIndexForRow:row];
    
    if (![[self.expansionStates objectAtIndex:parentIndex] boolValue]) {
        return;
    }
    
    // update expansionStates so backing data is ready before calling deleteRowsAtIndexPaths
    [self.expansionStates replaceObjectAtIndex:parentIndex withObject:@"NO"];
    [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    extendedRow = nil;
}
- (void)collapseAllRows {
    
    if ([self.expansionStates containsObject:@"YES"]) {
        
        NSInteger row = [self.expansionStates indexOfObject:@"YES"];
        
        [self.expansionStates replaceObjectAtIndex:row withObject:@"NO"];
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        // TODO: will this crash the thing?
        self.contentOffset = CGPointMake(self.contentOffset.x, 0);
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        extendedRow = nil;
    }
}


#pragma mark - Table Information

- (NSUInteger)rowForParentIndex:(NSUInteger)parentIndex {
    
    NSUInteger row = 0;
    NSUInteger currentParentIndex = 0;
    
    if (parentIndex == 0) {
        return 0;
    }
    
    while (currentParentIndex < parentIndex) {
        BOOL expanded = [[self.expansionStates objectAtIndex:currentParentIndex] boolValue];
        if (expanded) {
            row++;
        }
        currentParentIndex++;
        row++;
    }
    return row;
}
- (NSUInteger)parentIndexForRow:(NSUInteger)row {
    
    NSUInteger parentIndex = -1;

    NSUInteger i = 0;
    while (i <= row) {
        parentIndex++;
        i++;
        if ([[self.expansionStates objectAtIndex:parentIndex] boolValue]) {
            i++;
        }
    }
    return parentIndex;
}
- (BOOL)isExpansionCell:(NSUInteger)row {
    
    if (row < 1) {
        return NO;
    }
    NSUInteger parentIndex = [self parentIndexForRow:row];
    NSUInteger parentIndex2 = [self parentIndexForRow:(row-1)];
    return (parentIndex == parentIndex2);
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    NSInteger rowHeight = [self.dataSourceDelegate heightForParentRows];
    
    BOOL isExpansionCell = [self isExpansionCell:row];
    if (isExpansionCell) {
        
        NSInteger parentIndex = [self parentIndexForRow:row];
        NSInteger numberOfChildren = [self.dataSourceDelegate numberOfChildCellsUnderParentIndex:parentIndex];
        NSInteger childRowHeight = [self.dataSourceDelegate heightForChildRows];
        if(numberOfChildren == 0) {
            return 0;
        }
        NSInteger maxHeight = childRowHeight * numberOfChildren + 32;
        NSInteger minHeight = tableView.frame.size.height - rowHeight - 64;
        return fmax(maxHeight, minHeight);
    } else {
        return rowHeight;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (![self.dataSourceDelegate numberOfParentCells] > 0) {
        return 0;
    }
    
    // returns sum of parent cells and expanded cells
    NSInteger parentCount = [self.dataSourceDelegate numberOfParentCells];
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:self.expansionStates];
    NSUInteger expandedParentCount = [countedSet countForObject:@"YES"];
    
    return parentCount + expandedParentCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *PARENT_IDENTIFIER = @"CellReuseId_Parent";
    static NSString *CHILD_CONTAINER_IDENTIFIER = @"CellReuseId_Container";
    
    NSInteger row = indexPath.row;
    NSUInteger parentIndex = [self parentIndexForRow:row];
    BOOL isParentCell = ![self isExpansionCell:row];
    
    if (isParentCell) {
        
        ParentTableViewCell *cell = (ParentTableViewCell *)[self dequeueReusableCellWithIdentifier:PARENT_IDENTIFIER];
        if (cell == nil) {
            cell = [[ParentTableViewCell alloc] initWithReuseIdentifier:PARENT_IDENTIFIER];
        }
        
        cell.titleLabel.text = [self.dataSourceDelegate titleLabelForParentCellAtIndex:parentIndex];
        [cell setCellBackgroundColor:[self.dataSourceDelegate backgroundColorForParentCellAtIndex:parentIndex]];
        [cell setParentIndex:parentIndex];
        cell.tag = parentIndex;
        
        return cell;
    }
    else {
        
        ExpandedContainer *cell = (ExpandedContainer *)[self dequeueReusableCellWithIdentifier:CHILD_CONTAINER_IDENTIFIER];
        if (cell == nil) {
            cell = [[ExpandedContainer alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHILD_CONTAINER_IDENTIFIER];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell setSubTableForegroundColor:[self.dataSourceDelegate backgroundColorForParentCellAtIndex:parentIndex]];
        [cell setParentIndex:parentIndex];
        
        [cell setDelegate:self];
        [cell reload];
        
        return cell;
    }
}


#pragma mark - Table view - Cell Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedPCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedPCell isKindOfClass:[ParentTableViewCell class]]) {
        
        ParentTableViewCell *pCell = (ParentTableViewCell *)selectedPCell;
        self.selectedRow = [pCell parentIndex];
        
        if ([[self.expansionStates objectAtIndex:[pCell parentIndex]] boolValue]) {
           
            if (!self.shouldntReindent) {
                // clicked an already expanded cell
                [self collapseForParentAtRow:indexPath.row];
                previouslySelectedCell = nil;
                [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
        else {
            
            // clicked a collapsed cell
            if (!self.shouldntReindent) {
                [self collapseAllRows];
            }
            
            [self expandForParentAtRow:[pCell parentIndex]];
            
            previouslySelectedCell = pCell;
        }
        
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectParentCellAtIndex:)]) {
            [self.tableViewDelegate tableView:tableView didSelectParentCellAtIndex:[pCell parentIndex]];
        }
    }
}


# pragma mark - TableView - Section

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}


#pragma mark - SubRow Delegate

// @required
- (NSInteger)numberOfChildrenUnderParentIndex:(NSInteger)parentIndex {
    
    return [self.dataSourceDelegate numberOfChildCellsUnderParentIndex:parentIndex];
}
- (NSInteger)heightForChildRows {
    
    return [self.dataSourceDelegate heightForChildRows];
}

// @optional
- (void)didSelectRowAtChildIndex:(NSInteger)childIndex
                underParentIndex:(NSInteger)parentIndex {
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self rowForParentIndex:parentIndex] inSection:0];
    UITableViewCell *selectedCell = [self cellForRowAtIndexPath:indexPath];
    if ([selectedCell isKindOfClass:[ParentTableViewCell class]]) {
        
        // ParentTableViewCell * pCell = (ParentTableViewCell *)selectedCell;
        
        // Insert code here to detect and handle child cell selection
        // ...
    }
}
- (NSString *)titleLabelForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex {
    
    return [self.dataSourceDelegate titleLabelForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
}
- (NSString *)subtitleLabelForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex {
    
    return [self.dataSourceDelegate subtitleLabelForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
}
- (NSString *)timeLabelForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex {
    
    return [self.dataSourceDelegate timeLabelForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
}
- (NSString *)durationLabelForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex {
    
    return [self.dataSourceDelegate durationLabelForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y <= -160) {
        if(self.isRefreshing){
            return;
        }
        if(extendedRow != nil){
            return;
        }
        
        if(![self viewWithTag:10]){
            MMMaterialDesignSpinner *indicator = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(self.frame.size.width /2 - 15, -63, 30, 30)];
            indicator.lineWidth = 1.5f;
            indicator.tintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
            indicator.tag = 10;
            [indicator startAnimating];
                
            [self addSubview:indicator];
        }else if(self.contentOffset.y < -160){
            self.contentOffset = CGPointMake(self.contentOffset.x, -160);
        }
    }else if([self viewWithTag:10]){
        if(!self.isRefreshing){
            [self.ownDelegate userPulledToRefresh];
            self.isRefreshing = YES;
        }
        self.contentOffset = CGPointMake(self.contentOffset.x, -160);
    }
}

- (void) startRefreshing {
    if(![self viewWithTag:10]){
        MMMaterialDesignSpinner *indicator = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(self.frame.size.width /2 - 15, -63, 30, 30)];
        indicator.lineWidth = 1.5f;
        indicator.tintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        indicator.tag = 10;
        [indicator startAnimating];
        
        [self addSubview:indicator];
    }
    
    self.isRefreshing = YES;
}

- (void) doneRefreshing {
    self.isRefreshing = NO;
    if([self viewWithTag:10] != nil){
        [[self viewWithTag:10] removeFromSuperview];
    }
    if(self.contentOffset.y <= -160){
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
