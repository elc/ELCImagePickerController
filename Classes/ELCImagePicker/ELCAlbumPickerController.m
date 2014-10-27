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
@property (nonatomic, strong) NSString *loadedGroupID;
@property (nonatomic, strong) NSMutableArray *tempAssetGroups;

@end

@implementation ELCAlbumPickerController

//Using auto synthesizers

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem setTitle:NSLocalizedString(@"Loading...", nil)];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    self.library = assetLibrary;
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
       @autoreleasepool {
           
           // Group enumerator Block
           void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
           {
               if (group == nil) {
                   [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                   return;
               }
               
               // added fix for camera albums order
               NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
               NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
               
               if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                   [self.assetGroups insertObject:group atIndex:0];
               }
               else {
                   [self.assetGroups addObject:group];
               }
           };
           
           // Group Enumerator Failure Block
           void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
               
               UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
               [alert show];
               
               NSLog(@"A problem occurred %@", [error description]);
           };	
           
           // Enumerate Albums
           [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                       usingBlock:assetGroupEnumerator 
                                     failureBlock:assetGroupEnumberatorFailure];
           
       }
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAlbums) name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.loadedGroupID = @"";
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)checkAlbums
{
    if (!self.tempAssetGroups) {
        self.tempAssetGroups = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.tempAssetGroups removeAllObjects];
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
       @autoreleasepool {

           // Group enumerator Block
           void (^assetGroupEnumeratorCheck)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
           {
               if (group == nil) { // End of the enumeration
                   
                   NSMutableArray *arrayTemp = [[NSMutableArray alloc] initWithCapacity:1];
                   
                   // Check if an album has been added
                   for (ALAssetsGroup *group1 in self.tempAssetGroups) {
                       BOOL albumExists = NO;
                       NSString *groupID1 = (NSString *)[group1 valueForProperty:ALAssetsGroupPropertyPersistentID];
                       
                       for (ALAssetsGroup *group2 in self.assetGroups) {
                           NSString *groupID2 = (NSString *)[group2 valueForProperty:ALAssetsGroupPropertyPersistentID];
                           
                           if ([groupID1 isEqualToString:groupID2]) {
                               albumExists = YES;
                               break;
                           }
                       }
                       if (!albumExists) {
                           [arrayTemp addObject: group1];
                       }
                   }
                   //Add the new albums
                   if (arrayTemp.count > 0) {
                       [self.assetGroups addObjectsFromArray:arrayTemp];
                   }
                   [arrayTemp removeAllObjects];
                   
                   // Check if an album has been deleted
                   for (ALAssetsGroup *group1 in self.assetGroups) {
                       BOOL albumExists = NO;
                       NSString *groupID1 = (NSString *)[group1 valueForProperty:ALAssetsGroupPropertyPersistentID];
                       
                       for (ALAssetsGroup *group2 in self.tempAssetGroups) {
                           NSString *groupID2 = (NSString *)[group2 valueForProperty:ALAssetsGroupPropertyPersistentID];
                           
                           if ([groupID1 isEqualToString:groupID2]) {
                               albumExists = YES;
                               break;
                           }
                       }
                       if (!albumExists) {
                           [arrayTemp addObject:group1];
                       }
                   }
                   
                   //Remove the deleted albums
                   if (arrayTemp.count > 0) {
                       [self.assetGroups removeObjectsInArray:arrayTemp];
                   }
                   
                   // If an album is loaded, check if it has been deleted to get back
                   if (self.loadedGroupID.length > 0) {
                       BOOL albumExists = NO;
                       for (ALAssetsGroup *group in self.tempAssetGroups) {
                           NSString *groupID = (NSString *)[group valueForProperty:ALAssetsGroupPropertyPersistentID];
                           if ([groupID isEqualToString:self.loadedGroupID]) {
                               albumExists = YES;
                               break;
                           }
                       }
                       
                       // If the loaded album has been deleted pop the picker viewcontroller
                       if (!albumExists) {
                           [self.picker returnBack];
                       }
                   }else {
                       [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                   }
                   
                   return;
               }
               
               // added fix for camera albums order
               NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
               NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
               
               if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                   [self.tempAssetGroups insertObject:group atIndex:0];
               }
               else {
                   [self.tempAssetGroups addObject:group];
               }
           };
           
           // Group Enumerator Failure Block
           void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
               
               UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
               [alert show];
               
               NSLog(@"A problem occured %@", [error description]);	                                 
           };
        
            if (!self.library) {
                self.library = [[ALAssetsLibrary alloc] init];
            }
           
           // Enumerate Albums
           [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                       usingBlock:assetGroupEnumeratorCheck
                                     failureBlock:assetGroupEnumberatorFailure];
           
       }
    });
}

- (void)reloadTableView {
    
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

- (BOOL)isSelectableIndexNumber:(NSUInteger)indexNumber {
    
    if ([self.parent respondsToSelector:@selector(isSelectableIndexNumber:)]) {
        return [self.parent isSelectableIndexNumber:indexNumber];
    }else {
        return NO;
    }
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
    [cell.imageView setImage:[UIImage imageWithCGImage:[g posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.picker = [[ELCAssetTablePicker alloc] initWithNibName: nil bundle: nil];
	self.picker.parent = self;
    self.picker.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
    [self.picker.assetGroup setAssetsFilter:[self assetFilter]];
    self.picker.assetPickerFilterDelegate = self.assetPickerFilterDelegate;
	
    // Store the persistentID of the album to load
    self.loadedGroupID = (NSString *)[self.picker.assetGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    
	[self.navigationController pushViewController:self.picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 57;
}

@end

