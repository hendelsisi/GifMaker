//
//  JWGifFrame.h
//  SaveGifToAlblum
//
//  Created by ZJW on 16/10/12.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JWGifFrame : NSObject

@property (nonatomic,assign) NSUInteger index;  /**< 表示第几帧 */

@property (nonatomic,assign) NSTimeInterval duration;   /**< 持续时间 */

@property (nonatomic,strong) UIImage *image;    /**< 图片 */

@end
