//
//  ViewController.m
//  JTGestureBasedTableViewDemo
//
//  Created by James Tang on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "JTTransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"

// Configure your viewController to conform to JTTableViewGestureEditingRowDelegate
// and/or JTTableViewGestureAddingRowDelegate depends on your needs
@interface ViewController () <JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate, JTTableViewGestureMoveRowDelegate>
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITextField *editText;
- (void)moveRowToBottomForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ViewController
@synthesize rows;
@synthesize tableViewRecognizer;
@synthesize grabbedObject;

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // In this example, we setup self.rows as datasource
    self.rows = [NSMutableArray arrayWithObjects:
                 @"Swipe to the right to complete",
                 @"Swipe to left to delete",
                 @"Drag down to create a new cell",
                 @"Pinch two rows apart to create cell",
                 @"Long hold to start reorder cell",
                 nil];


    // Setup your tableView.delegate and tableView.datasource,
    // then enable gesture recognition in one line.
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight       = NORMAL_CELL_FINISHING_HEIGHT;
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //TODO: keyboard was shown
    NSLog(@"keyboard was shown");
}
#pragma mark Private Method

- (void)moveRowToBottomForIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    
    id object = [self.rows objectAtIndex:indexPath.row];
    [self.rows removeObjectAtIndex:indexPath.row];
    [self.rows addObject:object];

    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.rows count] - 1 inSection:0];
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:lastIndexPath];

    [self.tableView endUpdates];

    [self.tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:lastIndexPath afterDelay:JTTableViewRowAnimationDuration];
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSObject *object = [self.rows objectAtIndex:indexPath.row];
    UIColor *backgroundColor = [[UIColor redColor] colorWithHueOffset:0.12 * indexPath.row / [self tableView:tableView numberOfRowsInSection:indexPath.section]];
    if ([object isEqual:ADDING_CELL]) {
        NSString *cellIdentifier = nil;
        JTTransformableTableViewCell *cell = nil;

        // IndexPath.row == 0 is the case we wanted to pick the pullDown style
        if (indexPath.row == 0) {
            cellIdentifier = @"PullDownTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [JTTransformableTableViewCell transformableTableViewCellWithStyle:JTTransformableTableViewCellStylePullDown
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor whiteColor];
            }
            
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = backgroundColor;
                cell.textLabel.text = @"Release to create cell...";
            } else {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = backgroundColor;
                cell.textLabel.text = @"Continue Pulling...";
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.textLabel.shadowOffset = CGSizeMake(0, 1);
            cell.textLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            return cell;

        } else {
            // Otherwise is the case we wanted to pick the pullDown style
            cellIdentifier = @"UnfoldingTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

            if (cell == nil) {
                cell = [JTTransformableTableViewCell transformableTableViewCellWithStyle:JTTransformableTableViewCellStyleUnfolding
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor whiteColor];
            }
            
            // Setup tint color
            cell.tintColor = backgroundColor;
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.textLabel.text = @"Release to create cell...";
            } else {
                cell.textLabel.text = @"Continue Pinching...";
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.textLabel.shadowOffset = CGSizeMake(0, 1);
            cell.textLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            return cell;
        }
    
    } else {

        static NSString *cellIdentifier = @"MyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        cell.textLabel.text = [NSString stringWithFormat:@"%@", (NSString *)object];
        if ([object isEqual:DONE_CELL]) {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.contentView.backgroundColor = [UIColor darkGrayColor];
        } else if ([object isEqual:DUMMY_CELL]) {
            cell.textLabel.text = @"";
            cell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = backgroundColor;
        }
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        cell.textLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NORMAL_CELL_FINISHING_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self editCellAtIndexPath:indexPath];
    //TODO: didSelect
    NSLog(@"tableView:didSelectRowAtIndexPath: %@", indexPath);
    
}


#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows insertObject:ADDING_CELL atIndex:indexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows replaceObjectAtIndex:indexPath.row withObject:@"Added!"];
    JTTransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    
    cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
    cell.imageView.image = nil;
    cell.textLabel.text = @"";

    [self editCellAtIndexPath:indexPath];

}

- (void)maskViewTapped:(id)sender{
    
    if (!self.editText) {
        return;
    }
    
    if ([self.editText.text length]==0) {
        NSInteger row = self.editText.tag;
        [self.rows removeObjectAtIndex:row];
        //TODO: Section
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [self.rows replaceObjectAtIndex:self.editText.tag withObject:self.editText.text];
        [self.tableView reloadData];
    }
    
    CGFloat offset = fabs(self.tableView.frame.origin.y);
    [UIView beginAnimations:@"scrollBack" context:nil];
    [UIView setAnimationDuration:0.5];
    self.tableView.frame = CGRectOffset(self.tableView.frame, 0,offset);
    [UIView commitAnimations];
    [self.maskView removeFromSuperview];
    [self.editText removeFromSuperview];
    self.maskView = nil;
    self.editText = nil;
}
- (void)editCellAtIndexPath:(NSIndexPath *)indexPath{
    
    //TODO: pay attention to oriention
    UIView *maskView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    maskView.backgroundColor = [UIColor iBlackColor:0.5];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:nil];
    [maskView addGestureRecognizer:recognizer];
    [maskView addGestureRecognizer:panRecognizer];
    [maskView addGestureRecognizer:pinchRecognizer];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField * textField = [[UITextField alloc] initWithFrame:cell.textLabel.frame];
    textField.text = cell.textLabel.text;
    textField.textColor = cell.textLabel.textColor;
    textField.font = cell.textLabel.font;
    textField.tag = indexPath.row;
    [cell.textLabel removeFromSuperview];
    cell.textLabel.text = @"";
    [cell addSubview:textField];
    [maskView addSubview:cell];
    [self.tableView addSubview:maskView];
    self.maskView = maskView;
    self.editText = textField;
   
    CGFloat offsetY = NORMAL_CELL_FINISHING_HEIGHT*indexPath.row;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    self.tableView.frame = CGRectOffset(self.tableView.frame, 0,-offsetY);
    [UIView commitAnimations];
     
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //如果不放在这里，可能会产生同步方面的问题
        [textField becomeFirstResponder];
    });

}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows removeObjectAtIndex:indexPath.row];
}

// Uncomment to following code to disable pinch in to create cell gesture
//- (NSIndexPath *)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer willCreateCellAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        return indexPath;
//    }
//    return nil;
//}

#pragma mark JTTableViewGestureEditingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    UIColor *backgroundColor = nil;
    switch (state) {
        case JTTableViewCellEditingStateMiddle:
            backgroundColor = [[UIColor redColor] colorWithHueOffset:0.12 * indexPath.row / [self tableView:self.tableView numberOfRowsInSection:indexPath.section]];
            break;
        case JTTableViewCellEditingStateRight:
            backgroundColor = [UIColor iGreenColor:1];
            break;
        default:
            backgroundColor = [[UIColor redColor] colorWithHueOffset:0.12 * indexPath.row / [self tableView:self.tableView numberOfRowsInSection:indexPath.section]];
            break;
    }
    
    //TODO: add check and cross icon
    cell.contentView.backgroundColor = backgroundColor;
    if ([cell isKindOfClass:[JTTransformableTableViewCell class]]) {
        ((JTTransformableTableViewCell *)cell).tintColor = backgroundColor;
    }
}

// This is needed to be implemented to let our delegate choose whether the panning gesture should work
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    
    
    NSIndexPath *rowToBeMovedToBottom = nil;

    [tableView beginUpdates];
    if (state == JTTableViewCellEditingStateLeft) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
        [self.rows removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else if (state == JTTableViewCellEditingStateRight) {
        // An example to retain the cell at commiting at JTTableViewCellEditingStateRight
        [self.rows replaceObjectAtIndex:indexPath.row withObject:DONE_CELL];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        rowToBeMovedToBottom = indexPath;
    } else {
        // JTTableViewCellEditingStateMiddle shouldn't really happen in
        // - [JTTableViewGestureDelegate gestureRecognizer:commitEditingState:forRowAtIndexPath:]
    }
    [tableView endUpdates];


    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];

    if (rowToBeMovedToBottom) {
        [self performSelector:@selector(moveRowToBottomForIndexPath:) withObject:rowToBeMovedToBottom afterDelay:JTTableViewRowAnimationDuration * 2];
    }
}

#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.grabbedObject = [self.rows objectAtIndex:indexPath.row];
    [self.rows replaceObjectAtIndex:indexPath.row withObject:DUMMY_CELL];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id object = [self.rows objectAtIndex:sourceIndexPath.row];
    [self.rows removeObjectAtIndex:sourceIndexPath.row];
    [self.rows insertObject:object atIndex:destinationIndexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    self.grabbedObject = nil;
}

@end
