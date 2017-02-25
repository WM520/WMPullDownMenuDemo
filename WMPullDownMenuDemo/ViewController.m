//
//  ViewController.m
//  WMPullDownMenuDemo
//
//  Created by wangmiao on 2017/2/25.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "ViewController.h"
#import "WMPullDownMenu.h"
#import "AllViewController.h"
#import "UIView+WMCategory.h"
#import "WMMenuButton.h"

@interface ViewController ()<WMPullDownMenuDataSource>
@property (nonatomic, strong) NSArray *titles;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor brownColor];
    
    // 创建下拉菜单
    WMPullDownMenu *menu = [[WMPullDownMenu alloc] init];
    menu.frame = CGRectMake(0, 20, self.view.width, 44);
    [self.view addSubview:menu];
    
    // 设置下拉菜单代理
    menu.dataSource = self;
    
    // 初始化标题
    _titles = @[@"小学"];
    
    // 添加子控制器
    [self setupAllChildViewController];

}

- (void)setupAllChildViewController
{
    AllViewController *allvc = [[AllViewController alloc] init];
    [self addChildViewController:allvc];
}

#pragma mark - WMPullDownMenuDataSource
- (NSInteger)numberOfColsInMenu:(WMPullDownMenu *)pullDownMenu
{
    return 1;
}
- (UIViewController *)pullDownMenu:(WMPullDownMenu *)pullDownMenu viewControllerForColAtIndex:(NSInteger)index
{
    return self.childViewControllers[index];
}
- (CGFloat)pullDownMenu:(WMPullDownMenu *)pullDownMenu heightForColAtIndex:(NSInteger)index
{
    return 400;
}
- (UIButton *)pullDownMenu:(WMPullDownMenu *)pullDownMenu buttonForColAtIndex:(NSInteger)index
{
    WMMenuButton *button = [WMMenuButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:_titles[index] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:25 /255.0 green:143/255.0 blue:238/255.0 alpha:1] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"标签-向下箭头"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"标签-向上箭头"] forState:UIControlStateSelected];
    
    return button;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
