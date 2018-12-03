//
//  SJCustomAlertController.h
//  SJTestDemo
//
//  Created by Mac on 2018/11/26.
//  Copyright © 2018年 S.J. All rights reserved.
//

#import "SJViewController.h"
#import "SJPresentationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJCustomAlertController : SJViewController

/**
 使用自定义view初始化

 @param customView 自定义View
 @return 返回实例
 */
- (instancetype)initWithCustomView:(UIView *)customView;

/**
 模态出当前控制器

 @param controller 控制器
 @param type 显示类型
 @param animated 是否有动画
 @param completion 显示完成回调
 */
- (void)presentInController:(UIViewController *)controller type:(SJPresentationType)type animated:(BOOL)animated complete:(nullable void (^)(void))completion;

/** 点击背景视图是否消失 */
@property (nonatomic, assign) BOOL backgroundDismissEnable;

@end

NS_ASSUME_NONNULL_END
