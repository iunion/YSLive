//
//  YSChatView.m
//  YSLive
//
//  Created by 马迪 on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSChatView.h"
#import "YSEmotionView.h"
#import "YSNewTipMessageCell.h"
#import "YSNewPictureCell.h"
#import "YSTextMessageCell.h"
#import "BMAlertView+YSDefaultAlert.h"
#import <BMKit/BMProgressHUD.h>

//输入框高度
#define ToolHeight (BMIS_IPHONEXANDP?(56+10):56)
//键盘的基础高度
#define BasicToolH 56
//iphoneX的时候键盘多出的高度
#define BottomH 20
//自定义表情键盘高度
#define EmotionBtnH (BMIS_IPHONEXANDP?(150+10):150)


@interface YSChatView()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, assign) CGFloat keyboardHeight;
///自定义表情键盘
@property (nonatomic, strong) YSEmotionView *emotionView;
///聊天输入工具条中的表情按钮（只用于键盘伸缩时使用）
@property (nonatomic, strong) UIButton *emotionBtn;
///小红花(动画)
@property (nonatomic, strong) UIButton *flowerAnimationBtn;

@end
@implementation YSChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        self.layer.cornerRadius = 12;
//        self.layer.masksToBounds = YES;
        self.backgroundColor = YSSkinDefineColor(@"liveDefaultBgColor");
        
        self.messageList = [NSMutableArray array];
        self.anchorMessageList = [NSMutableArray array];
        self.mainMessageList = [NSMutableArray array];
        
        //创建聊天部分的tableView
        [self creatChatTableView];
        
        //创建通知，包括键盘通知
        [self loadNotification];
    }
    return self;
}


- (void)setMessageList:(NSMutableArray<YSChatMessageModel *> *)messageList
{
    _messageList = messageList;
    if (messageList.count) {
        for (YSChatMessageModel * model in messageList) {
            if (model.sendUser.role == YSUserType_Teacher)
            {
                [self.anchorMessageList addObject:model];
            }
            else if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
            {
                [self.mainMessageList addObject:model];
            }
        }
    }
}


#pragma mark -
#pragma mark 添加聊天tabView、输入框

- (void)creatChatTableView
{
    self.chatTableView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.bm_height-ToolHeight);
    [self addSubview:self.chatTableView];
    BMWeakSelf
    //表情view
    self.emotionView = [[YSEmotionView alloc]initWithFrame:CGRectMake(0, self.bm_height, BMUI_SCREEN_WIDTH, 150)];
    //把表情添加到输入框
    self.emotionView.addEmotionToTextView = ^(NSString * _Nonnull emotionName) {
        [weakSelf.chatToolView.inputView insertText:[NSString stringWithFormat:@"[%@]",emotionName]];
        // 滚动到可视区域
        [weakSelf.chatToolView.inputView scrollRectToVisible:CGRectMake(0, 0,weakSelf.chatToolView.inputView.contentSize.width , weakSelf.chatToolView.inputView.contentSize.height) animated:YES];
    };
    
    //删除输入框中的表情
    self.emotionView.deleteEmotionBtnClick = ^{
        [weakSelf.chatToolView.inputView deleteBackward];
        
    };
    
    [self addSubview:self.emotionView];
    
    //键盘
    [self addSubview:self.chatToolView];
    
    self.chatToolView.clickEmotionBtn = ^(UIButton * _Nonnull emotionBtn) {
        weakSelf.emotionBtn = emotionBtn;
        if (emotionBtn.selected)
        {
            // 2.动画
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                weakSelf.chatToolView.bm_originY= weakSelf.bm_height - EmotionBtnH - BasicToolH;
                weakSelf.chatTableView.bm_originY = -EmotionBtnH+BottomH;
                weakSelf.emotionView.bm_originY = weakSelf.bm_height - EmotionBtnH;
            }];
        }
    };
    self.chatToolView.sendMessageToHidKayBoard = ^{
        [weakSelf toHiddenKeyBoard];
    };
}


#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showType == YSMessageShowTypeAll)
    {
        return self.messageList.count;
    }
    else if (self.showType == YSMessageShowTypeAnchor)
    {
        return self.anchorMessageList.count;
    }
    else
    {
        return self.mainMessageList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSChatMessageModel *model;
    
    if (self.showType == YSMessageShowTypeAll)
    {
        model = self.messageList[indexPath.row];
    }
    else if (self.showType == YSMessageShowTypeAnchor)
    {
        model = self.anchorMessageList[indexPath.row];
    }
    else
    {
        model = self.mainMessageList[indexPath.row];
    }
    
    BMWeakSelf
    switch (model.chatMessageType)
    {
        case YSChatMessageType_ImageTips:
        case YSChatMessageType_Tips:
        {
            YSNewTipMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(YSNewTipMessageCell.class) forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            cell.model = model;
            return cell;
            break;
        }
        case YSChatMessageType_Text:
        {
            YSTextMessageCell * cell =[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(YSTextMessageCell.class) forIndexPath:indexPath];
            cell.model = model;
            cell.nickNameBtnClick = ^{
                weakSelf.chatToolView.memberModel = model.sendUser;
                
                if (weakSelf.addChatMember)
                {
                    weakSelf.addChatMember(model.sendUser);
                }
            };
            return cell;
            break;
        }
        case YSChatMessageType_OnlyImage:
        {
            YSNewPictureCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YSNewPictureCell class]) forIndexPath:indexPath];
            cell.model = model;
            cell.nickNameBtnClick = ^{
                weakSelf.chatToolView.memberModel = model.sendUser;
                
                if (weakSelf.addChatMember)
                {
                    weakSelf.addChatMember(model.sendUser);
                }
            };
            return cell;
            break;
        }
        default:
        {
            UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSChatMessageModel *model;
    
    if (self.showType == YSMessageShowTypeAll)
    {
        model = self.messageList[indexPath.row];
    }
    else if (self.showType == YSMessageShowTypeAnchor)
    {
        model = self.anchorMessageList[indexPath.row];
    }
    else
    {
        model = self.mainMessageList[indexPath.row];
    }
    
    switch (model.chatMessageType)
    {
        case YSChatMessageType_Text:
        {
            if (model.cellHeight)
            {
                return model.cellHeight;
            }
            else
            {
                CGSize size = [model.message bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_15];
                CGFloat height = kBMScale_H(12)+kBMScale_H(12)+size.height+kBMScale_H(20) + kBMScale_H(18);
                model.cellHeight = height;
                return height;
            }
            break;
        }
        case YSChatMessageType_OnlyImage:
        {
            return kBMScale_H(12)+kBMScale_H(12)+kBMScale_H(88)+ kBMScale_H(18);
            break;
        }
        case YSChatMessageType_Tips:
        {
            return kBMScale_H(10)+kBMScale_H(25)+ kBMScale_H(10);
            break;
        }
        default:
        {
            return kBMScale_H(20)+ kBMScale_H(18);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH, 10.0)];
    view.backgroundColor = YSSkinDefineColor(@"liveDefaultBgColor");
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //隐藏键盘
    [self toHiddenKeyBoard];
}

//刷新tableView
- (void)reloadTableView
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if (self.showType == YSMessageShowTypeAll)
    {
        if (self.messageList.count)
        {
            indexPath = [NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0];
        }
    }
    else if (self.showType == YSMessageShowTypeAnchor)
    {
        if (self.anchorMessageList.count)
        {
            indexPath = [NSIndexPath indexPathForRow:self.anchorMessageList.count-1 inSection:0];
        }
    }
    else
    {
        if (self.mainMessageList.count)
        {
            indexPath = [NSIndexPath indexPathForRow:self.mainMessageList.count-1 inSection:0];
        }
    }
    [self.chatTableView reloadData];
    if (indexPath.row) {
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

//接收到送花消息
- (void)receiveFlowrsWithSenderId:(NSString *)senderId senderName:(NSString *)senderName
{
    YSChatMessageModel * model = [[YSChatMessageModel alloc]init];
    YSRoomUser * userModel = [[YSRoomUser alloc]initWithPeerId:senderId];
    userModel.nickName =  senderName;
    model.timeInterval = [self systemTimeInfo];
    model.sendUser = userModel;
    model.chatMessageType = YSChatMessageType_ImageTips;
    [self.messageList addObject:model];
    
    [self reloadTableView];
    
    if ([senderId isEqualToString:YSCurrentUser.peerID])
    {
        self.flowerAnimationBtn.hidden = NO;
        [self animationGroup];
    }
}

#pragma mark - 送花的动画
- (void)animationGroup
{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, kBMScale_W(28), self.bm_height- kBMScale_H(42));//起始位置
    CGPathAddQuadCurveToPoint(curvedPath, NULL,kBMScale_W(83) , self.bm_height- kBMScale_H(79), kBMScale_W(83), self.bm_height- kBMScale_H(79));
    animation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CABasicAnimation * rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.toValue = @(M_PI*2);
    rotation.duration = 1.0;
    rotation.autoreverses = NO;
    rotation.repeatCount = HUGE_VALF;
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc]init];
    group.animations = @[animation,rotation];
    group.duration = 1.0;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [self.flowerAnimationBtn.layer addAnimation:group forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0 animations:^{
            self.flowerAnimationBtn.alpha = 0.0;
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.flowerAnimationBtn.frame = CGRectMake(kBMScale_W(13), kBMScale_H(360), kBMScale_W(28), kBMScale_W(28));
        self.flowerAnimationBtn.alpha = 1;
        self.flowerAnimationBtn.hidden = YES;
        [self.flowerAnimationBtn.layer removeAllAnimations];
    });
}

#pragma mark - 创建通知
- (void)loadNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark 键盘通知方法
- (void)keyboardWillShow:(NSNotification*)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = keyboardF.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        self.chatToolView.bm_originY = self.bm_height-keyboardF.size.height-BasicToolH;
        self.chatTableView.bm_originY = -keyboardF.size.height+BottomH;
        self.emotionView.bm_originY = self.bm_height;
    }];
    [self bringSubviewToFront:self.chatToolView];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    double duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        
        if (self.emotionBtn.selected)
        {
            self.chatToolView.bm_originY= self.bm_height - EmotionBtnH - BasicToolH;
            self.chatTableView.bm_originY = -EmotionBtnH+BottomH;
            self.emotionView.bm_originY = self.bm_height - EmotionBtnH;
        }else
        {
            self.chatToolView.bm_originY= self.bm_height - ToolHeight;
            self.chatTableView.bm_originY = 0;
            self.emotionView.bm_originY = self.bm_height;
        }
    }];
}

#pragma mark -
#pragma mark 聊天的tableView

- (UITableView *)chatTableView
{
    if (!_chatTableView)
    {
        self.chatTableView = [[UITableView alloc]initWithFrame:CGRectZero style: UITableViewStyleGrouped];
        
        self.chatTableView.delegate   = self;
        self.chatTableView.dataSource = self;
        self.chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        self.chatTableView.backgroundColor = [UIColor clearColor];
        self.chatTableView.separatorColor  = [UIColor clearColor];
        self.chatTableView.showsHorizontalScrollIndicator = NO;
        self.chatTableView.showsVerticalScrollIndicator = NO;
        
        self.chatTableView.estimatedRowHeight = 0;
        self.chatTableView.estimatedSectionHeaderHeight = 0;
        self.chatTableView.estimatedSectionFooterHeight = 0;
        
        [self.chatTableView registerClass:[YSTextMessageCell class] forCellReuseIdentifier:NSStringFromClass([YSTextMessageCell class])];
        [self.chatTableView registerClass:[YSNewTipMessageCell class] forCellReuseIdentifier:NSStringFromClass(YSNewTipMessageCell.class)];
        [self.chatTableView registerClass:[YSNewPictureCell class] forCellReuseIdentifier:NSStringFromClass(YSNewPictureCell.class)];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toHiddenKeyBoard)];
        [self.chatTableView addGestureRecognizer:tap];
    }
    return _chatTableView;
}


#pragma mark -
#pragma mark 键盘输入框

- (YSChatToolView *)chatToolView
{
    if (!_chatToolView)
    {
        self.chatToolView = [[YSChatToolView alloc] initWithFrame:CGRectMake(0, self.bm_height-ToolHeight, BMUI_SCREEN_WIDTH, ToolHeight)];
    }
    return _chatToolView;
}

- (UIButton *)flowerAnimationBtn
{
    if (!_flowerAnimationBtn)
    {
        self.flowerAnimationBtn = [[UIButton alloc]initWithFrame:CGRectMake(kBMScale_W(13), self.bm_height-kBMScale_H(42), kBMScale_W(28), kBMScale_W(28))];
        [self.flowerAnimationBtn setImage:[UIImage imageNamed:@"flower"] forState:UIControlStateNormal];
        self.flowerAnimationBtn.hidden = YES;
        self.flowerAnimationBtn.userInteractionEnabled = NO;
        [self addSubview:self.flowerAnimationBtn];
    }
    [self bringSubviewToFront:_flowerAnimationBtn];
    
    return _flowerAnimationBtn;
}

#pragma mark - 滚动或点击空白时，键盘回归原位
- (void)toHiddenKeyBoard
{
    if (self.chatToolView.bm_originY<self.bm_height-ToolHeight)
    {
        [_chatToolView.inputView resignFirstResponder];
        if (self.emotionView.bm_originY < self.bm_height)
        {
            [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
                self.chatToolView.bm_originY= self.bm_height - ToolHeight;
                self.chatTableView.bm_originY = 0;
                self.emotionView.bm_originY = self.bm_height;
            }];
        }
    }
}

//当前显示消息的类型
- (void)setShowType:(YSMessageShowType)showType
{
    _showType = showType;
    [self reloadTableView];
}

//获取当前时间：
- (NSTimeInterval)systemTimeInfo
{
    return [[NSDate date] timeIntervalSince1970];
}

@end


