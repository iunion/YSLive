//
//  YSSetTableViewVC.m
//  YSAll
//
//  Created by jiang deng on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSetTableViewVC.h"
#import <BMKit/NSString+BMRegEx.h>

@interface YSSetTableViewVC ()

@property (nonatomic, strong) BMTableViewManager *tableManager;

@end

@implementation YSSetTableViewVC
@synthesize freshViewType = _freshViewType;

- (BMFreshViewType)getFreshViewType
{
    return BMFreshViewType_NONE;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _freshViewType = BMFreshViewType_NONE;
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil freshViewType:(BMFreshViewType)freshViewType
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil freshViewType:BMFreshViewType_NONE];
}

- (void)viewDidLoad
{
    _freshViewType = [self getFreshViewType];
    
    self.tableViewStyle = UITableViewStyleGrouped;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView.bounces = NO;

    s_IsNoMorePage = YES;

//    if (IS_IPHONE6P || IS_IPHONEXP)
//    {
//        self.m_TableView.bm_left = 20.0f;
//        self.m_TableView.bm_width = UI_SCREEN_WIDTH-40.0f;
//    }
//    else if (IS_IPHONE6 || IS_IPHONEX)
//    {
//        self.m_TableView.bm_left = 15.0f;
//        self.m_TableView.bm_width = UI_SCREEN_WIDTH-30.0f;
//    }
//    else
//    {
//        self.m_TableView.bm_left = 10.0f;
//        self.m_TableView.bm_width = UI_SCREEN_WIDTH-20.0f;
//    }
    
    self.showEmptyView = NO;
    self.allowEmptyJson = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)needKeyboardEvent
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self needKeyboardEvent])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        // 监听输入法状态
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeInputMode:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self needKeyboardEvent])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    }
}


#pragma mark -
#pragma mark keyboardEvent

- (void)keyboardWillShow:(NSNotification *)notification
{
    UIView *view = [self.tableView bm_firstResponder];
    BMTableViewCell *cell = (BMTableViewCell *)[view bm_superViewWithClass:[BMTableViewCell class]];
    CGPoint relativePoint = [cell convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow];
//    CGPoint testPoint = [cell convertPoint:CGPointZero toView:self.m_TableView];
//    NSLog(@"testPoint = %@",NSStringFromCGPoint(testPoint));
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat actualHeight = CGRectGetHeight(cell.frame) + relativePoint.y + keyboardHeight;
    CGFloat overstep = actualHeight - CGRectGetHeight([UIScreen mainScreen].bounds);// + 5;
    if (overstep > 1)
    {
        CGFloat now = self.tableView.contentOffset.y;
        CGFloat new = now + overstep;
        [self.tableView setContentOffset:CGPointMake(0, new) animated:YES];
//        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//        CGRect frame = [UIScreen mainScreen].bounds;
//        frame.origin.y -= overstep;
//        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations: ^{
//            [UIApplication sharedApplication].keyWindow.frame = frame;
//        } completion:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations: ^{
        [UIApplication sharedApplication].keyWindow.frame = frame;
    } completion:nil];
}

//// 切换输入法
//- (void)keyboardChangeInputMode:(NSNotification *)notification
//{
//    //UITextInputMode *currentInputMode = [UITextInputMode currentInputMode];
//    UITextInputMode *currentInputMode = [notification object];
//
//    NSString *inputMethod = currentInputMode.primaryLanguage;
//    NSLog(@"inputMethod = %@", inputMethod);
//}

- (void)interfaceSettings
{
    self.tableManager = [[BMTableViewManager alloc] initWithTableView:self.tableView];
    self.tableManager.delegate = self;
}

- (void)freshViews
{
    
}


#pragma mark -
#pragma mark 输入校验

// 手机号
- (BOOL)verifyPhoneNum:(NSString *)phoneNum
{
    return [self verifyPhoneNum:phoneNum showMessage:YES];
}

- (BOOL)verifyPhoneNum:(NSString *)phoneNum showMessage:(BOOL)showMessage
{
    if (![phoneNum bm_isNotEmpty])
    {
        if (showMessage)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:@"请输入手机号码" delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        return NO;
    }
    else if (![phoneNum bm_isValidChinesePhoneNumber])
    {
        if (showMessage)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:@"请输入正确的手机号码" delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        return NO;
    }
    
    return YES;
}

// 密码
- (BOOL)verifyPassword:(NSString *)password
{
    return [self verifyPassword:password showMessage:YES];
}

- (BOOL)verifyPassword:(NSString *)password showMessage:(BOOL)showMessage
{
    if (![password bm_isNotEmpty])
    {
        if (showMessage)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:@"请输入账户密码(8~16位)" delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        return NO;
    }
    else if (![password bm_isValidPassword])
    {
        if (showMessage)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"请输入%@-%@位字母+数字，字母区分大小写", @(YSPASSWORD_MINLENGTH), @(YSPASSWORD_MAXLENGTH)] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        return NO;
    }
    
    return YES;
}

// 身份证号
- (BOOL)verifyId:(NSString *)idNum
{
    return [self verifyId:idNum showMessage:YES];
}

- (BOOL)verifyId:(NSString *)idNum showMessage:(BOOL)showMessage
{
    if (![idNum bm_isNotEmpty])
    {
        if (showMessage)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:@"请输入身份证号码" delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        return NO;
    }
    else if (![idNum bm_isValidChineseIDNumberString])
    {
        if (showMessage)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:@"请输入正确的身份证号码" delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        return NO;
    }
    
    return YES;
}

@end
