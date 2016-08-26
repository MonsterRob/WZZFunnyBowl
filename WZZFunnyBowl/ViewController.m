//
//  ViewController.m
//  WZZFunnyBowl
//
//  Created by 王召洲 on 16/8/26.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import "ViewController.h"

#import "WZZView.h"
@interface ViewController ()<UICollisionBehaviorDelegate>
@property (strong,nonatomic) UIDynamicAnimator * animator;// 动画总管
@property (strong,nonatomic) NSMutableArray * items;
@end

@implementation ViewController

-(UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    }
    return _animator;
}
-(void)setupUI {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, 100, 40);
    btn.layer.cornerRadius = 5;
    btn.backgroundColor = [UIColor colorWithRed: arc4random_uniform(256)/255.0  green:arc4random_uniform(256)/255.0 blue: arc4random_uniform(256)/255.0 alpha:1 ];
    [btn setTitle:@"开启动画" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(self.view.center.x, 40);
    [self.view addSubview:btn];
    
    
    btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, 100, 40);
    btn.layer.cornerRadius = 5;
    btn.backgroundColor = [UIColor colorWithRed: arc4random_uniform(256)/255.0  green:arc4random_uniform(256)/255.0 blue: arc4random_uniform(256)/255.0 alpha:1 ];
    [btn setTitle:@"归位" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(self.view.center.x, 40+ 60);
    [self.view addSubview:btn];

    // 模拟碗所在的位置 路径必须闭合的
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:100 startAngle:0 endAngle:M_PI clockwise:YES];
    [path addArcWithCenter:self.view.center radius:100 startAngle:M_PI endAngle:0 clockwise:NO];
    CAShapeLayer *bowl = [CAShapeLayer layer];
    bowl.path = path.CGPath;
    bowl.lineWidth = 2;
    bowl.strokeColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:bowl];
    
    //==========能够弹的小球=====================================//
    self.items = [NSMutableArray array];
    for (int i = 0; i < 6; i ++) {
        UIView *item = [[WZZView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        item.center = CGPointMake(50+i*60, 50 + i * 60);
        item.backgroundColor =[UIColor colorWithRed: arc4random_uniform(256)/255.0  green:arc4random_uniform(256)/255.0 blue: arc4random_uniform(256)/255.0 alpha:1 ];
        item.layer.cornerRadius = item.bounds.size.width/2;
        [self.view addSubview:item];
        [self.items addObject:item];
        
    }
    
    
}

-(void)refresh:(UIButton *)sender {
    
    // 太懒了，就这么滴吧 删了重新来过
    NSArray *subviews = [self.view subviews];
    for (UIView *item in subviews) {
        [item removeFromSuperview];
    }
    [self setupUI];
}
-(void)tap:(UIButton *)sender {
    
    [self.animator removeAllBehaviors];
    
    // 动画领队
    UIDynamicBehavior * processor = [[UIDynamicBehavior alloc]init];
    
    // 重力行为 使用默认设置
    UIGravityBehavior *gra= [[UIGravityBehavior alloc]initWithItems:self.items];
    
    // 碰撞行为
    UICollisionBehavior *col = [[UICollisionBehavior alloc]initWithItems:self.items];
    col.collisionDelegate = self;// 代理检测碰撞进行过程
    col.translatesReferenceBoundsIntoBoundary = YES;
    col.collisionMode = UICollisionBehaviorModeEverything;
    
    UIBezierPath *bowlPath = [UIBezierPath bezierPath];
    
    //    [bowlPath moveToPoint:CGPointMake(0, self.view.center.y)];
    //    [bowlPath addLineToPoint:CGPointMake(self.view.center.x, self.view.center.y + 250)];
    //    [bowlPath addLineToPoint:CGPointMake(self.view.bounds.size.width, self.view.center.y)];
    //
    //    [bowlPath addLineToPoint:CGPointMake(self.view.center.x, self.view.center.y + 250)];
    //    [bowlPath addLineToPoint:CGPointMake(0, self.view.center.y)];
    
    
    // 路径必须自己手动闭合，否则系统会自己闭合，达不到自己的效果
    bowlPath = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:100 startAngle:0 endAngle:M_PI clockwise:YES];
    [bowlPath addArcWithCenter:self.view.center radius:100 startAngle:M_PI endAngle:2*M_PI clockwise:NO];

    [col addBoundaryWithIdentifier:@"path" forPath:bowlPath];
    
    // 控制item 自身的一些动画属性
    UIDynamicItemBehavior *itemBehavior= [[UIDynamicItemBehavior alloc]initWithItems:self.items];
    itemBehavior.elasticity = 1.1;// 弹性系数 大于1 不好，弹到千里之外去了，建议值 0~1
    itemBehavior.density = 0.3;// 相对密度 单位呢？
    itemBehavior.allowsRotation = YES;// 是否旋转 圆的看不出来
    
    [processor addChildBehavior:gra];
    [processor addChildBehavior:col];
    [processor addChildBehavior:itemBehavior];
    [self.animator addBehavior:processor];// 添加动画后 立马开始
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    
    UIView * view = (UIView*)item1;
    UIView *view2 = (UIView*)item2;
    view.backgroundColor = [UIColor colorWithRed: arc4random_uniform(256)/255.0  green:arc4random_uniform(256)/255.0 blue: arc4random_uniform(256)/255.0 alpha:1 ];
    view2.backgroundColor = [UIColor colorWithRed: arc4random_uniform(256)/255.0  green:arc4random_uniform(256)/255.0 blue: arc4random_uniform(256)/255.0 alpha:1 ];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
