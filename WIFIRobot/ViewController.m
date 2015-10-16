//
//  ViewController.m
//  WIFIRobot
//
//  Created by mac on 10/6/15.
//  Copyright © 2015 mac. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()<UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIButton *connectButton;

@property (nonatomic, strong) UITextField *ipTextField;
@property (nonatomic, strong) UITextField *portTextField;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *settingPanelView;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgView.image = [UIImage imageNamed:@"setup_bg_1136x640"];
    [self.view insertSubview:bgView atIndex:0];
    
    _webView = ({
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.delegate = self;
        webView.backgroundColor = [UIColor whiteColor];
        webView.hidden = YES;
        [(UIScrollView *)[[webView subviews] objectAtIndex:0] setBounces:NO];
        [self.view addSubview:webView];
        webView;
    });
    
    _settingButton = ({
        UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectZero];
        settingButton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-80, 10, 70, 30);
        [settingButton setTitle:@"设置" forState:UIControlStateNormal];
        settingButton.backgroundColor = [UIColor colorWithRed:(31.0/255.0) green:(204.0/255.0) blue:(205.0/255.0) alpha:1.0];
        [settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [settingButton addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:settingButton];
        settingButton;
    });
    
    _connectButton = ({
        UIButton *connectButton = [[UIButton alloc] initWithFrame:CGRectZero];
        connectButton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-80, 50, 70, 30);
        [connectButton setTitle:@"连接" forState:UIControlStateNormal];
        connectButton.backgroundColor = [UIColor colorWithRed:(31.0/255.0) green:(204.0/255.0) blue:(205.0/255.0) alpha:1.0];
        [connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [connectButton addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:connectButton];
        connectButton;
    });
    
    _loadingView = ({
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.frame = CGRectMake(0, 0, 30, 30);
        loadingView.center = self.view.center;
        [self.view addSubview:loadingView];
        loadingView;
    });
}

- (void)requestWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}

- (void)connect {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ipaddr = [defaults objectForKey:@"ip_addr"];
    NSString *port = [defaults objectForKey:@"port"];
    if(!ipaddr || !port) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请设置连接参数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%@", ipaddr, port];
    [self requestWithURLString: urlString];
}

- (void)setting {
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    
    _settingPanelView = [[UIView alloc] initWithFrame:CGRectMake(-270, 0, 270, CGRectGetHeight(self.view.frame))];
    _settingPanelView.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ipaddr = [defaults objectForKey:@"ip_addr"];
    NSString *port = [defaults objectForKey:@"port"];
    
    _ipTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
    _ipTextField.center = CGPointMake(CGRectGetWidth(_settingPanelView.frame)/2, 100);
    _ipTextField.layer.borderColor = [UIColor colorWithRed:(214.0/255.0) green:(214.0/255.0) blue:(214.0/255.0) alpha:1.0].CGColor;
    _ipTextField.layer.borderWidth = 1.0f;
    //ipTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _ipTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _ipTextField.returnKeyType = UIReturnKeyNext;
    _ipTextField.placeholder = @"ip地址";
    
    CGRect frame = [_ipTextField frame];
    frame.size.width = 5.0f;
    _ipTextField.leftViewMode = UITextFieldViewModeAlways;
    _ipTextField.leftView = [[UIView alloc] initWithFrame:frame];
    if(ipaddr) {
        _ipTextField.text = ipaddr;
    }
    _ipTextField.delegate = self;
    [_settingPanelView addSubview:_ipTextField];
    
    _portTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
    _portTextField.center = CGPointMake(CGRectGetWidth(_settingPanelView.frame)/2, 150);
    _portTextField.layer.borderColor = [UIColor colorWithRed:(214.0/255.0) green:(214.0/255.0) blue:(214.0/255.0) alpha:1.0].CGColor;
    _portTextField.layer.borderWidth = 1.0f;
    //portTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _portTextField.returnKeyType = UIReturnKeyDone;
    _portTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _portTextField.placeholder = @"端口";
    _portTextField.leftViewMode = UITextFieldViewModeAlways;
    _portTextField.leftView = [[UIView alloc] initWithFrame:frame];
    if(port) {
        _portTextField.text = port;
    }
    _portTextField.delegate = self;
    [_settingPanelView addSubview:_portTextField];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(_portTextField.frame), CGRectGetMaxY(_portTextField.frame)+ 30, 70, 30)];
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor colorWithRed:(31.0/255.0) green:(204.0/255.0) blue:(205.0/255.0) alpha:1.0];
    [okButton addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    [_settingPanelView addSubview:okButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_portTextField.frame)-70, CGRectGetMaxY(_portTextField.frame)+ 30, 70, 30)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor colorWithRed:(31.0/255.0) green:(204.0/255.0) blue:(205.0/255.0) alpha:1.0];
    [cancelButton addTarget:self action:@selector(hideSettingPanelView) forControlEvents:UIControlEventTouchUpInside];
    [_settingPanelView addSubview:cancelButton];
    
    
    [_maskView addSubview:_settingPanelView];
    [[UIApplication sharedApplication].keyWindow addSubview:_maskView];
    [UIView animateWithDuration:0.2 animations:^{
        _settingPanelView.center = CGPointMake(135, CGRectGetMidY(self.view.frame));
    }];
}

- (void)saveSetting {
    if(_portTextField.text.length <=0 || _ipTextField.text.length <=0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"参数填写不完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_ipTextField.text forKey:@"ip_addr"];
    [defaults setObject:_portTextField.text forKey:@"port"];
    [defaults synchronize];
    
    [self hideSettingPanelView];
}

- (void)hideSettingPanelView {
    [UIView animateWithDuration:0.2 animations:^{
        _settingPanelView.center = CGPointMake(-135, CGRectGetMidY(self.view.frame));
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
    }];
}

- (void)tap {
    [_ipTextField resignFirstResponder];
    [_portTextField resignFirstResponder];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == _ipTextField) {
        [_ipTextField resignFirstResponder];
        [_portTextField becomeFirstResponder];
    }else {
        [_ipTextField resignFirstResponder];
        [_portTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_loadingView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    ctx[@"videoInitSuccess"] = ^(){
        _webView.hidden = NO;
        _settingButton.hidden = YES;
        _connectButton.hidden = YES;
        [_loadingView stopAnimating];
    };
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_loadingView stopAnimating];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
