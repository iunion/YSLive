//
//  SCTTopPopverViewController.m
//  YSLive
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTTopPopverViewController.h"

#define TopBarButtonWidth 70
#define TopBarButtonHeight 64

@interface SCTTopPopverViewController ()

@property(nonatomic, assign) SCTeacherTopBarType type;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, assign)BOOL isMeeting;

@end

@implementation SCTTopPopverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bm_colorWithHex:0x336CC7];
    self.backView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backView.backgroundColor = [UIColor clearColor];
    self.backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backView];
}

- (void)viewWillLayoutSubviews
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
    {
        CGRect layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame;
        self.backView.frame = layoutFrame;
    } else {
        self.backView.frame = self.view.frame;
    }
}

- (void)freshUIWithType:(SCTeacherTopBarType)type isMeeting:(BOOL)isMeeting
{
    self.type = type;
    self.isMeeting = isMeeting;
    if (type == SCTeacherTopBarTypeToolBox)
    {
        [self setupToolBoxUI];
    }
    else if (type == SCTeacherTopBarTypeAllControll)
    {
        [self setupAllControllUI];
    }
}

- (void)setupToolBoxUI
{
    [self.backView bm_removeAllSubviews];

    if (self.isMeeting)
    {
        // 会议
        CGFloat viewWidth = TopBarButtonWidth * 2;
        self.view.frame = CGRectMake(0, 0, viewWidth, TopBarButtonHeight);
        self.preferredContentSize = CGSizeMake(viewWidth, TopBarButtonHeight);
        for (int i = 0; i<2; i++)
        {
            UIButton * button = [[UIButton alloc] init];
            CGFloat width = TopBarButtonWidth;
            button.frame = CGRectMake(i*width, 0, width, self.view.bm_height);
            button.tag = i + 1;
            [button addTarget:self action:@selector(toolBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
            button.titleLabel.font = UI_FONT_10;

            if(i == 0)
            {
                [button setTitle:YSLocalized(@"UploadPhoto.TakePhoto") forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Photo"] forState:UIControlStateNormal];
            }
            else if(i == 1)
            {
                [button setTitle:YSLocalized(@"UploadPhoto.FromGallery") forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Album"] forState:UIControlStateNormal];
            }
            
            [self moveButtonTitleAndImageWithButton:button];

            [self.backView addSubview:button];
        }
        return;
    }
    
    CGFloat viewWidth = TopBarButtonWidth * 3;
    self.view.frame = CGRectMake(0, 0, viewWidth, TopBarButtonHeight);
    self.preferredContentSize = CGSizeMake(viewWidth, TopBarButtonHeight);
    for (int i = 0; i<3; i++)
    {
        UIButton * button = [[UIButton alloc] init];
        CGFloat width = TopBarButtonWidth;
        button.frame = CGRectMake(i*width, 0, width, self.view.bm_height);
        button.tag = i;
        [button addTarget:self action:@selector(toolBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
        button.titleLabel.font = UI_FONT_10;
        if (i == 0)
        {
            [button setTitle:YSLocalized(@"tool.datiqiqi") forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Answer"] forState:UIControlStateNormal];
        }
        else if(i == 1)
        {
            [button setTitle:YSLocalized(@"UploadPhoto.TakePhoto") forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Photo"] forState:UIControlStateNormal];
        }
        else if(i == 2)
        {
            [button setTitle:YSLocalized(@"UploadPhoto.FromGallery") forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Album"] forState:UIControlStateNormal];
        }
        
        [self moveButtonTitleAndImageWithButton:button];

        [self.backView  addSubview:button];
    }
}

- (void)setupAllControllUI
{
    [self.backView bm_removeAllSubviews];
    
    if (self.isMeeting)
    {
        CGFloat viewWidth = TopBarButtonWidth * 3;
        self.view.frame = CGRectMake(0, 0, viewWidth, TopBarButtonHeight);
        self.preferredContentSize = CGSizeMake(viewWidth, TopBarButtonHeight);
        for (int i = 0; i<3; i++)
        {
            UIButton * button = [[UIButton alloc]init];

            CGFloat width = TopBarButtonWidth;
            button.frame = CGRectMake(i*width, 0, width, self.view.bm_height);

            
            [button addTarget:self action:@selector(toolBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
            button.titleLabel.font = UI_FONT_10;
            
            switch (i)
            {
                case 0:
                    button.tag = 0;
                    [button setTitle:YSLocalized(@"Button.MuteAudio") forState:UIControlStateNormal];
                    [button setTitle:YSLocalized(@"Button.MuteAll") forState:UIControlStateSelected];
                    [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_MuteAudio"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_MuteAll"] forState:UIControlStateSelected];
                    BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
//                    button.selected = !isEveryoneNoAudio;
                    button.selected = isEveryoneNoAudio;
                    break;
                case 1:
                    button.tag = 1;
                    [button setTitle:YSLocalized(@"Button.ShutUpAll") forState:UIControlStateNormal];
                    [button setTitle:YSLocalized(@"Button.CancelShutUpAll") forState:UIControlStateSelected];
                    [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_ShutUpAll"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_CancelShutUpAll"] forState:UIControlStateSelected];
                    BOOL isEveryoneBanChat = [YSLiveManager shareInstance].isEveryoneBanChat;
                    button.selected = isEveryoneBanChat;
                    break;
                case 2:
                    button.tag = 3;
                    [button setTitle:YSLocalized(@"Button.Reset") forState:UIControlStateNormal];

                    [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Reset"] forState:UIControlStateNormal];

                    break;
                default:
                    break;
            }
            
            [self moveButtonTitleAndImageWithButton:button];

            [self.backView  addSubview:button];
        }
        return;
    }
    
    CGFloat viewWidth = TopBarButtonWidth * 4;
    self.view.frame = CGRectMake(0, 0, viewWidth, TopBarButtonHeight);
    self.preferredContentSize = CGSizeMake(viewWidth, TopBarButtonHeight);
    for (int i = 0; i<4; i++)
    {
        UIButton * button = [[UIButton alloc]init];
        CGFloat width = TopBarButtonWidth;
        button.frame = CGRectMake(i*width, 0, width, self.view.bm_height);
        button.tag = i;
        [button addTarget:self action:@selector(toolBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
        button.titleLabel.font = UI_FONT_10;
        
        switch (i)
        {
            case 0:
                [button setTitle:YSLocalized(@"Button.MuteAudio") forState:UIControlStateNormal];
                [button setTitle:YSLocalized(@"Button.MuteAll") forState:UIControlStateSelected];
                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_MuteAudio"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_MuteAll"] forState:UIControlStateSelected];
                BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
//                button.selected = !isEveryoneNoAudio;
                button.selected = isEveryoneNoAudio;
                break;
            case 1:
                [button setTitle:YSLocalized(@"Button.ShutUpAll") forState:UIControlStateNormal];
                [button setTitle:YSLocalized(@"Button.CancelShutUpAll") forState:UIControlStateSelected];
                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_ShutUpAll"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_CancelShutUpAll"] forState:UIControlStateSelected];
                BOOL isEveryoneBanChat = [YSLiveManager shareInstance].isEveryoneBanChat;
                button.selected = isEveryoneBanChat;
                break;
            case 2:
                    
                [button setTitle:YSLocalized(@"Button.Reward") forState:UIControlStateNormal];

                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Reward"] forState:UIControlStateNormal];

                break;
            case 3:
                [button setTitle:YSLocalized(@"Button.Reset") forState:UIControlStateNormal];

                [button setImage:[UIImage imageNamed:@"scteacher_topbar_toolBox_Reset"] forState:UIControlStateNormal];

                break;
            default:
                break;
        }
        
        [self moveButtonTitleAndImageWithButton:button];

        [self.backView addSubview:button];
    }
}

- (void)toolBtnsClick:(UIButton *)sender
{
    if (self.type == SCTeacherTopBarTypeToolBox)
    {
        if ([self.delegate respondsToSelector:@selector(toolboxBtnsClick:)])
        {
            [self.delegate toolboxBtnsClick:sender];
        }
    }
    else if (self.type == SCTeacherTopBarTypeAllControll)
    {
        if ([self.delegate respondsToSelector:@selector(allControlBtnsClick:)])
        {
            [self.delegate allControlBtnsClick:sender];
        }
    }
}

/// 移动button上图片和文字的位置（图片在上，文字在下）
- (void)moveButtonTitleAndImageWithButton:(UIButton *)button
{
    // 使图片和文字水平居中显示
//    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    // 文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
//    [button setImageEdgeInsets:UIEdgeInsetsMake(-button.imageView.image.size.height, (button.bounds.size.width - button.imageView.image.size.width)*0.5f,0.0, 0.0)];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(button.imageView.frame.size.height + 2.0f ,-button.frame.size.width , 0.0,button.frame.size.width)];
    button.imageEdgeInsets = UIEdgeInsetsMake(0,18, button.titleLabel.bounds.size.height + 8.0f, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(button.currentImage.size.width + 8.0f, -(button.currentImage.size.width), 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}

@end
