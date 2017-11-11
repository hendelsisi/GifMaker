//
//  HWVideoButton.m
//  LoopVideo
//
//  Created by hend elsisi on 12/4/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

#import "HWVideoButton.h"

@implementation HWVideoButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    persent = 0.f;
}

- (void)setPersent:(float)pst
{
    persent = pst;
    [self setNeedsDisplay];
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setPersent:0];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    float inset = contentRect.size.width - contentRect.size.width / 1.25;
    return CGRectInset(contentRect, inset, inset);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if ([self isSelected]) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 3.f);
        [[UIColor redColor] setStroke];
        CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, rect.size.width/2-2, -M_PI_2, -M_PI_2 + M_PI * 2 * persent, 0);
        CGContextStrokePath(ctx);
        CGContextFillPath(ctx);
    }
}


@end
