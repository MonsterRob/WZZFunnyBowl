//
//  WZZView.m
//  WZZFunnyBowl
//
//  Created by 王召洲 on 16/8/26.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import "WZZView.h"

@implementation WZZView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(UIDynamicItemCollisionBoundsType)collisionBoundsType {
    return UIDynamicItemCollisionBoundsTypeEllipse;
}
@end
