//
//  WMPullDownMenu.h
//  WMPullDownMenuDemo
//
//  Created by wangmiao on 2017/2/25.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMPullDownMenu;

// 下拉数据源协议
@protocol WMPullDownMenuDataSource <NSObject>
/**
 * 下拉菜单有多少列
 */
- (NSInteger)numberOfColsInMenu:(WMPullDownMenu *)pullDownMenu;

/**
 * 下拉菜单每列按钮外观
 */
- (UIButton *)pullDownMenu:(WMPullDownMenu *)pullDownMenu buttonForColAtIndex:(NSInteger)index;

/**
 * 下拉菜单每列对应的控制器
 */
- (UIViewController *)pullDownMenu:(WMPullDownMenu *)pullDownMenu viewControllerForColAtIndex:(NSInteger)index;

/**
 * 下拉菜单每列对应的高度
 */
- (CGFloat)pullDownMenu:(WMPullDownMenu *)pullDownMenu heightForColAtIndex:(NSInteger)index;

@end

extern NSString *const WMUpdateMenuTitleNote;

@interface WMPullDownMenu : UIView

/**
 * 下拉数据源
 */
@property (nonatomic, weak) id<WMPullDownMenuDataSource> dataSource;

/**
 * 分割线颜色
 */
@property (nonatomic, strong) UIColor *separateLineColor;

/**
 * 分割线距离顶部间距，默认10
 */
@property (nonatomic, assign) NSInteger separateLineTopMargin;

/**
 * 蒙版颜色
 */
@property (nonatomic, strong) UIColor *coverColor;

/**
 * 刷新下拉菜单
 */
- (void)reload;

@end
