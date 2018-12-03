//
//  SJPresentationController.h
//  SJTestDemo
//
//  Created by Mac on 2018/11/21.
//  Copyright © 2018年 S.J. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SJPresentationTypeCenter,
    SJPresentationTypeBottom,

} SJPresentationType;

@interface SJPresentationController : UIPresentationController<UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) SJPresentationType presentationType;
/**
 点击背景视图是否消失
 */
@property (nonatomic, assign) BOOL backgroundDismissEnable;

@end

NS_ASSUME_NONNULL_END
