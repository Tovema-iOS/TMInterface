//
//  FLViewController.m
//  FLInterface
//
//  Created by linxiaobin on 03/15/2016.
//  Copyright (c) 2016 linxiaobin. All rights reserved.
//

#import "FLViewController.h"
#import <TMInterface/TMInterface.h>

#if __has_include("FaceUnityStickerInterface.h")
#import "FaceUnityStickerInterface.h"
#define kFaceUnityStickerFlag 1
#endif

#define kSectionTitleKey @"SectionTitle"
#define kCellTitleArrayKey @"CellTitleArray"
#define kCellTitleKey @"Title"
#define kCellOperationKey @"Operation"

@interface FLViewController()

@property (nonatomic, retain) NSMutableArray *sections;
#if kFaceUnityStickerFlag
@property (nonatomic, strong) FLFaceUnityStickerNetLogic *netLogic;
#endif
@end

@implementation FLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sections = [NSMutableArray array];
    {
        NSMutableArray *array = [NSMutableArray array];

        [array addObject:@{kCellTitleKey: @"测试1", kCellOperationKey: [NSBlockOperation blockOperationWithBlock:^{
                               NSDictionary *dictionary = @{@"A": @"aaa"};
                               NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:NULL];
#if TARGET_OS_SIMULATOR
                               //TODO: 测试
                               [data writeToFile:@"/tmp/data.txt" atomically:YES];
#endif
                           }]}];


        [self.sections addObject:@{kSectionTitleKey: @"测试",
                                   kCellTitleArrayKey: array}];
    }
    {
#if kFaceUnityStickerFlag
        {
            [self initFaceUnitySticker];
            __weak typeof(self) weakSelf = self;
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:@{kCellTitleKey: @"分类--单个", kCellOperationKey: [NSBlockOperation blockOperationWithBlock:^{
                                   [weakSelf loadStickerCategorys];
                               }]}];
            [array addObject:@{kCellTitleKey: @"标签--单个", kCellOperationKey: [NSBlockOperation blockOperationWithBlock:^{
                                   [weakSelf loadStickerTagsWithCateID:842];
                               }]}];
            [array addObject:@{kCellTitleKey: @"标签--合集", kCellOperationKey: [NSBlockOperation blockOperationWithBlock:^{
                                   [weakSelf loadStickerTags];
                               }]}];
            [array addObject:@{kCellTitleKey: @"列表", kCellOperationKey: [NSBlockOperation blockOperationWithBlock:^{
                                   [weakSelf loadStickerListsWithTagID:145064];
                               }]}];
            [self.sections addObject:@{kSectionTitleKey: @"相芯-贴纸",
                                       kCellTitleArrayKey: array}];
        }
#endif
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [self.sections objectAtIndex:section];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict[kSectionTitleKey];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [self.sections objectAtIndex:section];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return [dict[kCellTitleArrayKey] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCellIDentifier" forIndexPath:indexPath];

    NSDictionary *dict = [self.sections objectAtIndex:indexPath.section];
    NSArray *titles = dict[kCellTitleArrayKey];
    if ([titles isKindOfClass:[NSArray class]]) {
        NSDictionary *cellDict = titles[indexPath.row];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%zd-%zd %@", indexPath.section, indexPath.row, cellDict[kCellTitleKey]];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dict = [self.sections objectAtIndex:indexPath.section];
    NSArray *titles = dict[kCellTitleArrayKey];
    if ([titles isKindOfClass:[NSArray class]]) {
        NSDictionary *cellDict = titles[indexPath.row];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSBlockOperation *operation = cellDict[kCellOperationKey];
            for (void (^block)(void) in operation.executionBlocks) {
                block();
            }
        }
    }
}

@end
