//
//  ZZFLEXChainSectionModel.m
//  zhuanzhuan
//
//  Created by 李伯坤 on 2017/8/15.
//  Copyright © 2017年 转转. All rights reserved.
//

#import "ZZFLEXChainSectionModel.h"
#import "ZZFlexibleLayoutSectionModel.h"

#pragma mark - ## ZZFLEXChainSectionBaseModel (基类)
@interface ZZFLEXChainSectionBaseModel ()

@property (nonatomic, strong) ZZFlexibleLayoutSectionModel *sectionModel;

@end

@implementation ZZFLEXChainSectionBaseModel

- (instancetype)initWithSectionModel:(ZZFlexibleLayoutSectionModel *)sectionModel
{
    if (self = [super init]) {
        self.sectionModel = sectionModel;
    }
    return self;
}

- (id (^)(CGFloat minimumLineSpacing))minimumLineSpacing
{
    return ^(CGFloat minimumLineSpacing) {
        [self.sectionModel setMinimumLineSpacing:minimumLineSpacing];
        return self;
    };
}

- (id (^)(CGFloat minimumInteritemSpacing))minimumInteritemSpacing
{
    return ^(CGFloat minimumInteritemSpacing) {
        [self.sectionModel setMinimumInteritemSpacing:minimumInteritemSpacing];
        return self;
    };
}

- (id (^)(UIEdgeInsets sectionInsets))sectionInsets
{
    return ^(UIEdgeInsets sectionInsets) {
        [self.sectionModel setSectionInsets:sectionInsets];
        return self;
    };
}

- (id (^)(UIColor *backgrounColor))backgrounColor
{
    return ^(UIColor *backgrounColor) {
        [self.sectionModel setBackgroundColor:backgrounColor];
        return self;
    };
}

@end

#pragma mark - ## ZZFLEXChainSectionModel （添加）
@implementation ZZFLEXChainSectionModel

@end

#pragma mark - ## ZZFLEXChainSectionInsertModel （插入）
@interface ZZFLEXChainSectionInsertModel()

@property (nonatomic, strong) NSMutableArray *listData;

@end

@implementation ZZFLEXChainSectionInsertModel

- (instancetype)initWithSectionModel:(ZZFlexibleLayoutSectionModel *)sectionModel listData:(NSMutableArray *)listData
{
    if (self = [super initWithSectionModel:sectionModel]) {
        self.listData = listData;
    }
    return self;
}

- (ZZFLEXChainSectionInsertModel *(^)(NSInteger index))toIndex
{
    return ^(NSInteger index) {
        [self p_insertToListDataAtIndex:index];
        return self;
    };
}

- (ZZFLEXChainSectionInsertModel *(^)(NSInteger sectionTag))beforeSection
{
    return ^(NSInteger sectionTag) {
        for (int i = 0; i < self.listData.count; i++) {
            ZZFlexibleLayoutSectionModel *model = self.listData[i];
            if (model.sectionTag == sectionTag) {
                [self p_insertToListDataAtIndex:i];
                break;
            }
        }
        return self;
    };
}

- (ZZFLEXChainSectionInsertModel *(^)(NSInteger sectionTag))afterSection
{
    return ^(NSInteger sectionTag) {
        for (int i = 0; i < self.listData.count; i++) {
            ZZFlexibleLayoutSectionModel *model = self.listData[i];
            if (model.sectionTag == sectionTag) {
                [self p_insertToListDataAtIndex:i + 1];
                break;
            }
        }
        return self;
    };
}

- (BOOL)p_insertToListDataAtIndex:(NSInteger)index
{
    if (self.listData && index >= 0 && index < self.listData.count) {
        [self.listData insertObject:self.sectionModel atIndex:index];
        self.listData = nil;
        return YES;
    }
    NSLog(@"!!!!! ZZFLEX, section插入失败");
    return NO;
}

@end

#pragma mark - ## ZZFLEXChainSectionEditModel （编辑）
@implementation ZZFLEXChainSectionEditModel

#pragma mark 获取数据源
- (NSArray *)dataModelArray
{
    NSArray *viewModelArray = self.sectionModel.itemsArray;
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:viewModelArray.count];
    for (ZZFlexibleLayoutViewModel *viewModel in data) {
        if (viewModel.dataModel && ![viewModel.dataModel isKindOfClass:[NSNull class]]) {
            [data addObject:viewModel.dataModel];
        }
    }
    return data;
}

- (id)dataModelForHeader
{
    return self.sectionModel.headerViewModel;
}

- (id)dataModelForFooter
{
    return self.sectionModel.footerViewModel;
}

/// 根据viewTag获取数据源
- (id (^)(NSInteger viewTag))dataModelByViewTag
{
    return ^(NSInteger viewTag) {
        id dataModel;
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            if (viewModel.viewTag == viewTag) {
                dataModel = [viewModel.dataModel isKindOfClass:[NSNull class]] ? nil : viewModel.dataModel;
                break;
            }
        }
        if (self.sectionModel.headerViewModel.viewTag == viewTag) {
            dataModel = self.sectionModel.headerViewModel;
        }
        else if (self.sectionModel.footerViewModel.viewTag == viewTag) {
            dataModel = self.sectionModel.footerViewModel;
        }
        return dataModel;
    };
}

/// 根据viewTag批量获取数据源
- (NSArray *(^)(NSInteger viewTag))dataModelArrayByViewTag
{
    return ^(NSInteger viewTag) {
        NSMutableArray *data = [[NSMutableArray alloc] init];
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            if (viewModel.viewTag == viewTag) {
                id dataModel = [viewModel.dataModel isKindOfClass:[NSNull class]] ? nil : viewModel.dataModel;
                [data addObject:dataModel];
            }
        }
        if (self.sectionModel.headerViewModel.viewTag == viewTag) {
            [data addObject:self.sectionModel.headerViewModel];
        }
        if (self.sectionModel.footerViewModel.viewTag == viewTag) {
            [data addObject:self.sectionModel.footerViewModel];
        }
        return data;
    };
}

#pragma mark 删除
- (ZZFLEXChainSectionEditModel *(^)(void))clear
{
    return ^(void) {
        self.sectionModel.headerViewModel = nil;
        self.sectionModel.footerViewModel = nil;
        [self.sectionModel.itemsArray removeAllObjects];
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(void))clearCells
{
    return ^(void) {
        [self.sectionModel.itemsArray removeAllObjects];
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(void))deleteHeader
{
    return ^(void) {
        self.sectionModel.headerViewModel = nil;
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(void))deleteFooter
{
    return ^(void) {
        self.sectionModel.footerViewModel = nil;
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(NSInteger tag))deleteCellByTag
{
    return ^(NSInteger tag) {
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            if (viewModel.viewTag == tag) {
                [self.sectionModel removeObject:viewModel];
                break;
            }
        }
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(NSInteger tag))deleteAllCellsByTag
{
    return ^(NSInteger tag) {
        NSMutableArray *deleteData = @[].mutableCopy;
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            if (viewModel.viewTag == tag) {
                [deleteData addObject:viewModel];
            }
        }
        for (ZZFlexibleLayoutViewModel *viewModel in deleteData) {
            [self.sectionModel removeObject:viewModel];
        }
        return self;
    };
}

#pragma mark 刷新
- (ZZFLEXChainSectionEditModel *(^)(void))update
{
    return ^(void) {
        [self.sectionModel.headerViewModel updateViewHeight];
        [self.sectionModel.footerViewModel updateViewHeight];
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            [viewModel updateViewHeight];
        }
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(void))updateCells
{
    return ^(void) {
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            [viewModel updateViewHeight];
        }
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(void))updateHeader
{
    return ^(void) {
        [self.sectionModel.headerViewModel updateViewHeight];
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(void))updateFooter
{
    return ^(void) {
        [self.sectionModel.footerViewModel updateViewHeight];
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(NSInteger tag))updateCellByTag
{
    return ^(NSInteger tag) {
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            if (viewModel.viewTag == tag) {
                [viewModel updateViewHeight];
                break;
            }
        }
        return self;
    };
}

- (ZZFLEXChainSectionEditModel *(^)(NSInteger tag))updateAllCellsByTag
{
    return ^(NSInteger tag) {
        for (ZZFlexibleLayoutViewModel *viewModel in self.sectionModel.itemsArray) {
            if (viewModel.viewTag == tag) {
                [viewModel updateViewHeight];
            }
        }
        return self;
    };
}

@end