//
//  WMPullDownMenu.m
//  WMPullDownMenuDemo
//
//  Created by wangmiao on 2017/2/25.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "WMPullDownMenu.h"
#import "WMCover.h"
#import "UIView+WMCategory.h"

NSString *const WMUpdateMenuTitleNote = @"WMUpdateMenuTitleNote";

@interface WMPullDownMenu ()

/**
 * 下拉菜单所有按钮
 */
@property (nonatomic, strong) NSMutableArray * menuButtons;

/**
 * 下拉菜单所有分割线
 */
@property (nonatomic, strong) NSMutableArray * separateLines;

/**
 * 下拉菜单所有控制器
 */
@property (nonatomic, strong) NSMutableArray * controllers;

/**
 * 下拉菜单每列高度
 */
@property (nonatomic, strong) NSMutableArray * colsHeight;

/**
 * 下拉菜单内容View
 */
@property (nonatomic, strong) UIView * contentView;

/**
 * 下拉菜单蒙版
 */
@property (nonatomic, strong) WMCover * coverView;

/**
 * 下拉菜单底部View
 */
@property (nonatomic, strong) UIView * bottomLine;

/**
 * 观察者
 */
@property (nonatomic, weak) id observer;

@end

@implementation WMPullDownMenu

#pragma mark - 懒加载
- (NSMutableArray *)separateLines
{
    if (!_separateLines) {
        _separateLines = [NSMutableArray array];
    }
    return _separateLines;
}

- (NSMutableArray *)menuButtons
{
    if (!_menuButtons) {
        _menuButtons = [NSMutableArray array];
    }
    return _menuButtons;
}

- (NSMutableArray *)controllers
{
    if (!_controllers) {
        _controllers = [NSMutableArray array];
    }
    return _controllers;
}

- (WMCover *)coverView
{
    if (_coverView == nil) {
        CGFloat coverX = 0;
        CGFloat coverY = CGRectGetMaxY(self.frame);
        CGFloat coverW = self.frame.size.width;
        CGFloat coverH = self.superview.bounds.size.height - coverY;
        _coverView = [[WMCover alloc] initWithFrame:CGRectMake(coverX, coverY, coverW, coverH)];
        [self.superview addSubview:_coverView];
        
        __weak typeof(self) weakSelf = self;
        
        _coverView.clickcover = ^() {
            [weakSelf dismiss];
        };
        
    }
    return _coverView;
}

- (UIView *)contentView
{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.frame = CGRectMake(0, 0, self.bounds.size.width, 0);
        _contentView.clipsToBounds = YES;
        [self.coverView addSubview:_contentView];
    }
    return _contentView;
}
- (NSMutableArray *)colsHeight
{
    if (_colsHeight == nil) {
        _colsHeight = [NSMutableArray array];
    }
    return _colsHeight;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    _separateLineTopMargin = 10;
    _separateLineColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:0.7];
    _coverColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:0.7];
    
    // 监听更新菜单标题通知
    self.observer = [[NSNotificationCenter defaultCenter]
                 addObserverForName:WMUpdateMenuTitleNote
                            object:nil
                            queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification * _Nonnull note) {
                            NSInteger col = [self.controllers indexOfObject:note.object];
                            UIButton *btn = self.menuButtons[col];
                            [self dismiss];
                            NSArray *allValues = note.userInfo.allValues;
                            if (allValues.count > 1 || [allValues.firstObject isKindOfClass:[NSArray class]]) {
                                return;
                            }
                            [btn setTitle:allValues.firstObject forState:UIControlStateNormal];
    }];
}

#pragma mark - 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    // 布局子控件
    NSInteger count = self.menuButtons.count;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = self.bounds.size.width / count;
    CGFloat btnH = self.bounds.size.height;
    
    for (NSInteger i = 0; i < count; i++) {
        // 设置按钮位置
        UIButton *btn = self.menuButtons[i];
        btnX = i * btnW;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        // 设置分割线位置
        if (i < count - 1) {
            UIView *separateLine = self.separateLines[i];
            separateLine.frame = CGRectMake(CGRectGetMaxX(btn.frame), _separateLineTopMargin, 1, btnH - 2 * _separateLineTopMargin);
        }
    }
    
    // 设置底部View位置
    CGFloat bottomH = 1;
    CGFloat bottomY = btnH - bottomH;
    _bottomLine.frame = CGRectMake(0, bottomY, self.bounds.size.width, bottomH);

}

#pragma mark - 即将进入窗口
- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    [self reload];
}

#pragma mark - 下拉菜单功能
// 删除之前所有数据,移除之前所有子控件
- (void)clear
{
    self.bottomLine = nil;
    self.coverView = nil;
    self.contentView = nil;
    [self.separateLines removeAllObjects];
    [self.menuButtons removeAllObjects];
    [self.controllers removeAllObjects];
    [self.colsHeight removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
// 刷新下拉菜单
- (void)reload
{
    // 删除之前所有数据,移除之前所有子控件
    [self clear];
    
    // 没有数据源，直接返回
    if (self.dataSource == nil) return;
    
    // 判断之前是否添加过,添加过就不添加了
    if (self.menuButtons.count) return;
    
    
    // 判断有没有实现numberOfColsInMenu:
    if (![self.dataSource respondsToSelector:@selector(numberOfColsInMenu:)]) {
        @throw [NSException exceptionWithName:@"WMError" reason:@"未实现（numberOfColsInMenu:）" userInfo:nil];
    }
    
    // 判断有没有实现pullDownMenu:buttonForColAtIndex:
    if (![self.dataSource respondsToSelector:@selector(pullDownMenu:buttonForColAtIndex:)]) {
        @throw [NSException exceptionWithName:@"WMError" reason:@"pullDownMenu:buttonForColAtIndex:）" userInfo:nil];
    }
    
    // 判断每一列控制器的方法是否实现
    if (![self.dataSource respondsToSelector:@selector(pullDownMenu:viewControllerForColAtIndex:)]) {
        @throw [NSException exceptionWithName:@"WMError" reason:@"pullDownMenu:viewControllerForColAtIndex:这个方法未实现）" userInfo:nil];
        return;
    }
    
    // 判断每一列控制器的方法是否实现
    if (![self.dataSource respondsToSelector:@selector(pullDownMenu:heightForColAtIndex:)]) {
        @throw [NSException exceptionWithName:@"WMError" reason:@"pullDownMenu:heightForColAtIndex:这个方法未实现）" userInfo:nil];
        return;
    }
    
    // 获取有多少列
    NSInteger cols = [self.dataSource numberOfColsInMenu:self];
    
    // 没有列直接返回
    if (cols == 0) return;
    
    // 添加按钮
    for (NSInteger col = 0; col < cols; col++) {
        
        // 获取按钮
        UIButton *menuButton = [self.dataSource pullDownMenu:self buttonForColAtIndex:col];
        
        menuButton.tag = col;
        
        [menuButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (menuButton == nil) {
            @throw [NSException exceptionWithName:@"WMError" reason:@"pullDownMenu:buttonForColAtIndex:这个方法不能返回空的按钮）" userInfo:nil];
            return;
        }
        
        [self addSubview:menuButton];
        
        // 添加按钮
        [self.menuButtons addObject:menuButton];
        
        // 保存所有列的高度
        CGFloat height = [self.dataSource pullDownMenu:self heightForColAtIndex:col];
        [self.colsHeight addObject:@(height)];
        
        // 保存所有子控制器
        UIViewController *vc = [self.dataSource pullDownMenu:self viewControllerForColAtIndex:col];
        [self.controllers addObject:vc];
    }
    
    // 添加分割线
    NSInteger count = cols - 1;
    for (NSInteger i = 0; i < count; i++) {
        UIView *separateLine = [[UIView alloc] init];
        separateLine.backgroundColor = _separateLineColor;
        [self addSubview:separateLine];
        [self.separateLines addObject:separateLine];
    }
    
    // 添加底部View
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = _separateLineColor;
    _bottomLine = bottomView;
    [self addSubview:bottomView];
    
    // 设置所有子控件的尺寸
    [self layoutSubviews];
    
}


#pragma mark - 下拉菜单弹回
- (void)dismiss
{
    // 取消所有按钮选中
    for (UIButton *button in self.menuButtons) {
        button.selected = NO;
    }
    
    // 移除蒙版
    _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect frame = self.contentView.frame;
        frame.size.height = 0;
        self.contentView.frame = frame;
        
    } completion:^(BOOL finished) {
        self.coverView.hidden = YES;
        
        self.coverView.backgroundColor = _coverColor;
    }];
    
}

#pragma mark - 点击菜单标题按钮
- (void)btnClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    // 取消其他按钮选中
    for (UIButton *otherButton in self.menuButtons) {
        if (otherButton == button) continue;
        otherButton.selected = NO;
    }
    
    if (button.selected == YES) { // 当按钮选中，弹出蒙版
        // 添加对应蒙版
        self.coverView.hidden = NO;
        
        // 获取角标
        NSInteger i = button.tag;
        
        // 移除之前子控制器的View
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // 添加对应子控制器的view
        UIViewController *vc = self.controllers[i];
        vc.view.frame = self.contentView.bounds;
        [self.contentView addSubview:vc.view];
        
        // 设置内容的高度
        CGFloat height = [self.colsHeight[i] floatValue];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            CGRect frame = self.contentView.frame;
            frame.size.height = height;
            self.contentView.frame = frame;
        } ];
    } else { // 当按钮未选中，收回蒙版
        [self dismiss];
    }
}

#pragma mark - 界面销毁
- (void)dealloc
{
    [self clear];
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}


@end
