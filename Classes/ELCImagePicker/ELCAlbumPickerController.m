//
//  AlbumPickerController.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ELCAlbumPickerController ()

@property (nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation ELCAlbumPickerController

- (NSInteger)maximumImagesCount
{
	return self.parent.maximumImagesCount;
}

//Using auto synthesizers

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	[self.navigationItem setTitle:NSLocalizedString(@"Loading...", nil)];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = nil;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    self.library = assetLibrary;

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
		@autoreleasepool {
			
			// Group enumerator Block
			void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
			{
				if (group) {
					[tempArray addObject:group];
				} else {
					// finished adding groups.
					// now sort them and put them into the table
					NSDictionary *typeOrderReplacements = @{
															@(ALAssetsGroupSavedPhotos) : @(-3),
															@(ALAssetsGroupPhotoStream) : @(-2),
															@(ALAssetsGroupEvent) : @(-1)
															};
					[tempArray sortUsingComparator:^NSComparisonResult(ALAssetsGroup *group1, ALAssetsGroup *group2) {
						NSNumber *originalType1 = [group1 valueForProperty:ALAssetsGroupPropertyType];
						NSNumber *type1 = typeOrderReplacements[originalType1];
						if (!type1) {
							type1 = originalType1;
						}
						NSNumber *originalType2 = [group2 valueForProperty:ALAssetsGroupPropertyType];
						NSNumber *type2 = typeOrderReplacements[originalType2];
						if (!type2) {
							type2 = originalType2;
						}
						// first, we sort by album type (SavedPhotos, PhotoStream, Event, Library, Album, Faces, unknown, ...)
						NSComparisonResult result = [type1 compare:type2];
						if (result == NSOrderedSame) {
							// second, we sort by album name.
							// When sorting PhotoStream albums, we prefix the name with underscore when having "stream" in it;
							// this should put the main photo stream to the top (assuming it is named something like "stream" in the current language).
							NSString *name1 = [group1 valueForProperty:ALAssetsGroupPropertyName];
							if ([originalType1 intValue] == ALAssetsGroupPhotoStream && [name1 rangeOfString:@"stream" options:NSCaseInsensitiveSearch].location != NSNotFound) {
								name1 = [@"_" stringByAppendingString:name1];
							}
							NSString *name2 = [group2 valueForProperty:ALAssetsGroupPropertyName];
							if ([originalType2 intValue] == ALAssetsGroupPhotoStream && [name2 rangeOfString:@"stream" options:NSCaseInsensitiveSearch].location != NSNotFound) {
								name2 = [@"_" stringByAppendingString:name2];
							}
							result = [name1 caseInsensitiveCompare:name2];
							if (result == NSOrderedSame) {
								// the last fallback is to sort by pointer comparison.
								if (group1 < group2) {
									result = NSOrderedAscending;
								} else if (group1 > group2) {
									result = NSOrderedDescending;
								}
							}
						}
						return result;
					}];

					self.assetGroups = tempArray;
					// Reload albums
					[self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
				}
			};

			// Group Enumerator Failure Block
			void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {

				if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
					NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
					NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"This app does not have access to your photos or videos. You can enable access in Privacy Settings.", nil), appName];
					[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil] show];

				} else {
					NSString *errorMessage = [NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]];
					[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil] show];
				}

				[self.navigationItem setTitle:nil];
				NSLog(@"A problem occured %@", [error description]);
			};

			// Enumerate Albums
			[self.library enumerateGroupsWithTypes:ALAssetsGroupAll
										usingBlock:assetGroupEnumerator
									  failureBlock:assetGroupEnumberatorFailure];

		}
    });

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:ALAssetsLibraryChangedNotification object:nil];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)reloadTableView
{
	[self.tableView reloadData];
	[self.navigationItem setTitle:NSLocalizedString(@"Select an Album", nil)];
}

- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    return [self.parent shouldSelectAsset:asset previousCount:previousCount];
}

- (BOOL)shouldDeselectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    return [self.parent shouldDeselectAsset:asset previousCount:previousCount];
}

- (void)selectedAssets:(NSArray*)assets
{
	[_parent selectedAssets:assets];
}

- (ALAssetsFilter *)assetFilter
{
    if([self.mediaTypes containsObject:(NSString *)kUTTypeImage] && [self.mediaTypes containsObject:(NSString *)kUTTypeMovie])
    {
        return [ALAssetsFilter allAssets];
    }
    else if([self.mediaTypes containsObject:(NSString *)kUTTypeMovie])
    {
        return [ALAssetsFilter allVideos];
    }
    else
    {
        return [ALAssetsFilter allPhotos];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[self assetFilter]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",[g valueForProperty:ALAssetsGroupPropertyName], (long)gCount];
    UIImage* image = [UIImage imageWithCGImage:[g posterImage]];
    image = [self resize:image to:CGSizeMake(78, 78)];
    [cell.imageView setImage:image];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

// Resize a UIImage. From http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
- (UIImage *)resize:(UIImage *)image to:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName: nil bundle: nil];
	picker.parent = self;

    picker.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[self assetFilter]];
    
	picker.assetPickerFilterDelegate = self.assetPickerFilterDelegate;
	
	[self.navigationController pushViewController:picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 95;
}

@end

