/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  The view controller displaying the root list of the app.
  
 */

#import "AAPLRootListViewController.h"

#import "AAPLAssetGridViewController.h"

@import Photos;


@interface AAPLRootListViewController () <PHPhotoLibraryChangeObserver>
@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@end

@implementation AAPLRootListViewController

static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

static NSString * const CollectionSegue = @"showCollection";

- (void)awakeFromNib
{
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchMomentListsWithSubtype:PHCollectionListSubtypeMomentListCluster options:nil];
    self.collectionsFetchResults = @[topLevelUserCollections];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    PHFetchResult *fetchResult = self.collectionsFetchResults[0];
    PHCollectionList *collectionList = fetchResult[indexPath.row];

    PHFetchResult *collectionsFetchResult = [PHCollection fetchCollectionsInCollectionList:collectionList options:nil];
    assetGridViewController.assetsFetchResults = collectionsFetchResult;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collectionsFetchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    PHFetchResult *fetchResult = self.collectionsFetchResults[0];
    numberOfRows = fetchResult.count;
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *localizedTitle = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
    PHFetchResult *fetchResult = self.collectionsFetchResults[0];
    PHAssetCollection *collection = fetchResult[indexPath.row];
    localizedTitle = collection.localizedTitle;

    cell.textLabel.text = localizedTitle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:collection.startDate], [dateFormatter stringFromDate:collection.endDate]];
    
    return cell;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
            [self.tableView reloadData];
        }
        
    });
}

@end
