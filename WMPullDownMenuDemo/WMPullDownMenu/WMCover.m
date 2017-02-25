//
//  WMCover.m
//  WMPullDownMenuDemo
//
//  Created by wangmiao on 2017/2/25.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "WMCover.h"

@implementation WMCover

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_clickcover) {
        _clickcover();
    }
}

@end
