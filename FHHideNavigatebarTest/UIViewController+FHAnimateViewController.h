//
//  UIViewController+FHAnimateViewController.h
//  FHHideNavigatebarTest
//
//  Created by Forr on 15/12/7.
//  Copyright © 2015年 Forr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FHAnimateViewController)<UIGestureRecognizerDelegate>


/**
 *  绑定滚动视图
 *
 *  @param scrollView
 */
- (BOOL)bindingAnimateScrollView:(UIView *)scrollView;

/**
 *  对滚动视图解除绑定，delloe中调用
 *
 *  @return 是否解除成功
 */
- (BOOL)removeBindingScrollView;

@end
