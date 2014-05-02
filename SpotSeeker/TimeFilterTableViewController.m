//
//  TimeFilterTableViewController.m
//  SpaceScout
//
//  Created by Michael Seibel on 2/6/14.
//  Based on https://developer.apple.com/library/ios/samplecode/DateCell/Introduction/Intro.html
//
//

#import "TimeFilterTableViewController.h"

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kTitleKey       @"title"   // key for obtaining the filter item's title
#define kTimeKey        @"time"    // key for obtaining the filter item's time value
#define kDefaultKey     @"text"    // key for obtaining the filter item's default text

// keep track of which rows have date cells
#define kDateStartRow   0
#define kDateEndRow     1

#define UIColorFromRGB(rgbValue) [UIColor \
        colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
        green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
        blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kDateResetID = @"resetCell";

#pragma mark -


@interface TimeFilterTableViewController ()

@property (nonatomic, strong) NSArray *filterArray;
@property BOOL viewCancelled;
@property UIColor *detailTextColor;

// keep track which indexPath points to the cell with UIPicker
//@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

//@property (assign) NSInteger pickerCellRowHeight;

@end

@implementation TimeFilterTableViewController

@synthesize time_picker;
@synthesize filter;
@synthesize viewCancelled;

//-(IBAction)timeSelected:(id)sender {
//}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup our data source
    NSMutableDictionary *itemOne = [@{ kTitleKey :  NSLocalizedString(@"hours from", @"hours from"), kDefaultKey :
        NSLocalizedString(@"hours filter default start label", nil)} mutableCopy];
    [self setFilterTimeFromDateComponents:itemOne dateComponents:[self.filter objectForKey:@"open_at"]];
    NSMutableDictionary *itemTwo = [@{ kTitleKey :  NSLocalizedString(@"hours until", @"hours until"), kDefaultKey :
        NSLocalizedString(@"hours filter default end label", nil)} mutableCopy];
    [self setFilterTimeFromDateComponents:itemTwo dateComponents:[self.filter objectForKey:@"open_until"]];

    self.filterArray = @[itemOne, itemTwo];
    
    // obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

/*! Responds to region format or locale changes.
 */
- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
    [self.tableView reloadData];
}

#pragma mark - Utilities

/*! Returns the major version of iOS, (i.e. for iOS 6.1.3 it returns 6)
 */
NSUInteger DeviceSystemMajorVersion()
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIPickerView *checkDatePicker = (UIPickerView *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    return (self.time_picker_index_path != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.time_picker_index_path.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if ((indexPath.row == kDateStartRow) ||
        (indexPath.row == kDateEndRow || ([self hasInlineDatePicker] && (indexPath.row == kDateEndRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
}


#pragma mark - UITableViewDataSource

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"hours section name", @"hours section name");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        return self.filterArray.count + 1;
    }
    
    return self.filterArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *cellID = nil;
    
    if ([self indexPathHasPicker:indexPath])
    {
        // the indexPath is the one containing the inline date picker
        cellID = kDatePickerID;     // the current/opened date picker cell
    }
    else if ([self indexPathHasDate:indexPath])
    {
        // the indexPath is one that contains the date information
        cellID = kDateCellID;       // the start/end date cells
    }
    else
    {
        cellID = kDateResetID;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    // if we have a date picker open whose cell is above the cell we want to update,
    // then we have one more cell than the model allows
    //
    NSInteger modelRow = indexPath.row;
    if (self.time_picker_index_path != nil)
    {
        modelRow--;
    }

    // proceed to configure our cell
    if ([cellID isEqualToString:kDateCellID])
    {
        [self updateTableCellWithModelRow:cell modelRow:modelRow];
    }
    
	return cell;
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIPickerView.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    // indicates if the date picker is below "indexPath", help us determine which row to reveal
    BOOL before = NO;
    
    BOOL sameCellClicked = (self.time_picker_index_path.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        before = (self.time_picker_index_path.row < indexPath.row);
        NSInteger row = self.time_picker_index_path.row;

        // clear cell details decorations
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:0]];
        cell.detailTextLabel.textColor = self.detailTextColor;

        // remove the old picker
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.time_picker_index_path = nil;
    }
    
    if (!sameCellClicked)
    {
        // decorate cell details to show they're being edited
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        self.detailTextColor = cell.detailTextLabel.textColor;
//        cell.detailTextLabel.textColor = kSelectedDateDetailColor;
    
        // insert the new date picker
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:(before ? indexPath.row : indexPath.row + 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPathToReveal] withRowAnimation:UITableViewRowAnimationFade];
        self.time_picker_index_path = [NSIndexPath indexPathForRow:indexPathToReveal.row inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform time picker of the current date to match the current cell
    NSDateComponents *components = (indexPath.row > 0) ? [self getEndTime]: [self getStartTime];
    [self setPickerDateComponents:components];
}

/*! Reveals the UIPickerView as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath used to display the UIPickerView.
 */
- (void)displayExternalDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the date picker might already be showing, so don't add it to our view
    if (self.time_picker.superview == nil)
    {
        CGRect startFrame = self.time_picker.frame;
        CGRect endFrame = self.time_picker.frame;
        
        // the start position is below the bottom of the visible frame
        startFrame.origin.y = self.view.frame.size.height;
        
        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
        
        self.time_picker.frame = startFrame;
        
        [self.view addSubview:self.time_picker];
        
        // animate the date picker into view
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.time_picker.frame = endFrame; }
                         completion:^(BOOL finished) {
                             // add the "Done" button to the nav bar
                             self.navigationItem.rightBarButtonItem = self.doneButton;
                         }];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kDateCellID)
    {
        if (EMBEDDED_DATE_PICKER)
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        else
            [self displayExternalDatePickerForRowAtIndexPath:indexPath];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIPickerView.
 
 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.time_picker_index_path.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UIDatePicker *targetedDatePicker = sender;
    
    // update our data model
    NSMutableDictionary *itemData = self.filterArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kTimeKey];
}


/*! User chose to finish using the UIPIckerView by pressing the "Done" button, (used only for non-inline date picker), iOS 6.1.x or earlier
 
 @param sender The sender for this action: The "Done" UIBarButtonItem
 */
- (IBAction)doneAction:(id)sender
{
    CGRect pickerFrame = self.time_picker.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.time_picker.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.time_picker removeFromSuperview];
                     }];
    
    // remove the "Done" button in the navigation bar
	self.navigationItem.rightBarButtonItem = nil;
    
    // deselect the current table cell
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark button handling

/* User chose to exit time filter without updating any values
 */
-(IBAction)cancelBtnClick:(id)sender {
    self.viewCancelled = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


/* User popped back into the filter list, update the filter
 */
-(void) viewWillDisappear:(BOOL)animated {
    if (!self.viewCancelled) {
        NSDateComponents *new = [self.filterArray[kDateStartRow] valueForKey:kTimeKey];
        NSDateComponents *old = [self.filter objectForKey:@"open_at"];

        if ([new isKindOfClass:[NSNull class]]) {
            [self.filter setValue:nil forKey:@"open_at"];
        }
        else if (!(old.day == new.day && old.hour == new.hour && old.minute == new.minute)) {
            [self.filter setObject:new forKey:@"open_at"];
        }

        new = [self.filterArray[kDateEndRow] valueForKey:kTimeKey];
        old = [self.filter objectForKey:@"open_until"];

        if ([new isKindOfClass:[NSNull class]]) {
            [self.filter setValue:nil forKey:@"open_until"];
        }
        else if (!(old.day == new.day && old.hour == new.hour && old.minute == new.minute)) {
            [self.filter setObject:new forKey:@"open_until"];
        }
    }

    [super viewWillDisappear:animated];
}

/* User chose to reset times
 */
-(IBAction)resetBtnClick:(id)sender {
    // restart Start
    [self setPickerDateComponents:[self getDefaultStartTime]];
    [self updateTableRowWithDateComponents:kDateStartRow dateComponents:nil];
    
    // restart End
    [self setPickerDateComponents:[self getDefaultEndTime]];
    [self updateTableRowWithDateComponents:kDateEndRow dateComponents:nil];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"hours section name", @"hours section name");
}
 */

/* Cells map to the filterArray element
 */
- (void)updateTableWithModelRow:(NSInteger)row
{
    NSInteger offset = 0;
    
    if ([self hasInlineDatePicker] && self.time_picker_index_path.row <= row) {
        offset = 1;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row + offset inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self updateTableCellWithModelRow:cell modelRow:row];
}

/* Given the cell to update, update the title and details
 */
- (void) updateTableCellWithModelRow:(UITableViewCell *)cell modelRow:(NSInteger)row
{
    NSDictionary *filterData = self.filterArray[row];
    NSDateComponents *time = [filterData valueForKey:kTimeKey];
    NSString *text;

    cell.textLabel.text = [filterData valueForKey:kTitleKey];

    if ([time isKindOfClass:[NSNull class]]) {
        text = [[filterData valueForKey:kDefaultKey] capitalizedString];
    }
    else
    {
        text = [self stringForDateComponents:time];
    }

    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    cell.detailTextLabel.text = text;
}

/* given updated date components, update the given row
 */
-(void)updateTableRowWithDateComponents:(NSInteger)row dateComponents:(NSDateComponents *)components
{
    NSMutableDictionary *filterData = self.filterArray[row];

    [self setFilterTimeFromDateComponents:filterData dateComponents:components];
    [self updateTableWithModelRow:row];

}

/* store the updated date components to the model storedin filteArray
 */
-(void)setFilterTimeFromDateComponents:(NSMutableDictionary *)filterData dateComponents:(NSDateComponents *)components {
    if (!components) {
        components = (NSDateComponents *) [NSNull null];
    }
    
    [filterData setObject:components forKey:kTimeKey];
}


// PICKER START


#pragma mark -
#pragma mark update button display


-(NSString *)stringForDateComponents:(NSDateComponents *)components {
    NSInteger hour = components.hour;
    NSString *am_pm;
    
    if (hour >= 12) {
        am_pm = @"PM";
    }
    else {
        am_pm = @"AM";
    }
    
    if (hour > 12) {
        hour -= 12;
    }
    
    if (hour == 0) {
        hour = 12;
    }
    
    NSString *display = [NSString stringWithFormat:@"%@, %li:%02li %@", [self dayNameForIndex:components.weekday -1], (long)hour, (long)components.minute, am_pm];
    return display;
}

#pragma mark -
#pragma mark date math

-(NSDateComponents *)getStartTime {
    NSMutableDictionary *itemData = self.filterArray[kDateStartRow];
    NSDateComponents *start_time = [itemData objectForKey:kTimeKey];
    
    if ([start_time isKindOfClass:[NSNull class]]) {
        return [self getDefaultStartTime];
    }
    
    return start_time;
}

-(NSDateComponents *)getDefaultStartTime {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [cal components:( INT_MAX ) fromDate:now];
    
    // Get the minutes in the 15 minute interval format
    components.minute = (components.minute / 15) * 15;
    
    return components;
}

-(NSDateComponents *)getEndTime {
    NSMutableDictionary *itemData = self.filterArray[kDateEndRow];
    NSDateComponents *end_time = [itemData valueForKey:kTimeKey];

    if ([end_time isKindOfClass:[NSNull class]]) {
        return [self getDefaultEndTime];
    }
    
    return end_time;
}


-(NSDateComponents *)getDefaultEndTime {
    // SPOT-267
    return [self getStartTime];
}

-(void)setNewWeekDay:(NSInteger)weekday ForDateComponents:(NSDateComponents *)date_components {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *the_days = [[NSDateComponents alloc] init];
    the_days.day = weekday + 7 - date_components.weekday;
    
    NSDate *tmp_date = [cal dateFromComponents:date_components];
    
    NSDate *right_day = [cal dateByAddingComponents:the_days toDate:tmp_date options:0];
    
    NSDateComponents *right_values = [cal components:(INT_MAX) fromDate:right_day];
    
    date_components.day = right_values.day;
    date_components.month = right_values.month;
    date_components.year = right_values.year;
    date_components.weekday = right_values.weekday;
}

#pragma mark -
#pragma mark setting the picker value

-(void) setPickerDateComponents:(NSDateComponents *)components {
    int is_pm = 0;
    NSInteger hour = components.hour;
    
    if (hour >= 12) {
        is_pm = 1;
    }
    if (hour > 12) {
        hour -= 12;
    }
    
    if (hour == 0) {
        hour = 12;
    }
    
    BOOL is_animated = YES;
    // Sunday is 1 in components.weekday, but 0 in our spinner.
    [self.time_picker selectRow:(components.weekday - 1) inComponent:0 animated:is_animated];
    [self.time_picker selectRow:(hour-1) inComponent:1 animated:is_animated];
    [self.time_picker selectRow:(components.minute / 15) inComponent:2 animated:is_animated];
    
    [self.time_picker selectRow:is_pm inComponent:3 animated:is_animated];
    
}

#pragma mark -
#pragma mark picker methods

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)pickerView.superview.superview.superview];
    NSInteger modelRow = indexPath.row - 1;
    
    NSDateComponents *initial;
    if (modelRow == kDateStartRow) {
        initial = [self getStartTime];
    }
    else {
        initial = [self getEndTime];
    }
    
    NSDateComponents *new = [initial copy];
    
    NSInteger hour;
    switch (component) {
        case 0:
            [self setNewWeekDay:(row + 1) ForDateComponents:new];
            break;
        case 1:
            hour = row;
            if (hour == 11) {
                hour = -1;
            }
            if ([pickerView selectedRowInComponent:3] == 1) {
                new.hour = hour + 13;
            }
            else {
                new.hour = hour + 1;
            }
            break;
        case 2:
            new.minute = row * 15;
            break;
        case 3:
            hour = [pickerView selectedRowInComponent:1];
            if (hour == 11) {
                hour = -1;
            }
            
            if (row == 0) {
                new.hour = hour + 1;
            }
            else {
                new.hour = hour + 13;
            }
            break;
    }

    [self updateTableRowWithDateComponents:modelRow dateComponents:new];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    time_picker = pickerView;
    return 4;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 7;
        case 1:
            return 12;
        case 2:
            return 4;
        case 3:
            return 2;
        default:
            return -1;
    }
}



-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 140;
        case 1:
            return 45.0;
        case 2:
            return 45.0;
        default:
            return 60.0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 3) {
        switch (row) {
            case 0:
                return @"AM";
            case 1:
                return @"PM";
        }
    }
    else if (component == 2) {
        return [NSString stringWithFormat:@"%02i", (int)row * 15];
    }
    else if (component == 1) {
        return [NSString stringWithFormat:@"%i", (int)row+1];
    }
    else {
        return [self dayNameForIndex:row];
    }
    
    return @"OK";
}

-(NSString *)dayNameForIndex:(NSInteger)weekday {
    NSArray *days = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [days objectAtIndex:weekday];
}

@end
