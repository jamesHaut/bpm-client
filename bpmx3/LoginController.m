//
//  ViewController.m
//  bpmx3
//
//  Created by 郭进毫 on 15/1/24.
//  Copyright (c) 2015年 company. All rights reserved.
//

#import "LoginController.h"
#import "SVProgressHUD.h"
#import <CFNetwork/CFHTTPMessage.h>

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *serverUrl;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property UIAlertView *waittingAlert;


@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender NS_AVAILABLE_IOS(5_0){
    [self dismissWaitingAlert:_waittingAlert];
}

- (IBAction)login {
    id target = nil;
    if([_username.text length]<=0){
        target = _username;
    }else if([_password.text length]<=0){
        target = _password;
    }else if([_serverUrl.text length]<=0){
        target = _serverUrl;
    }else {
        [SVProgressHUD showWithStatus:@"加载中……" maskType:SVProgressHUDMaskTypeGradient];
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(performLogin) userInfo:nil repeats:NO];
    }
    if(target) [self showAlert:target];
}



- (void)performLogin{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/mobileLogin.ht?username=%@&password=%@", _serverUrl.text, _username.text, _password.text];
    NSURL *url = [NSURL URLWithString:requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        int statusCode = httpResponse.statusCode;
        UIAlertView *alert = [self getAlertView:nil message:@"" cancelButtonTitle:@"确定"];
        [SVProgressHUD dismiss];
        if (connectionError) {
            NSDictionary *userInfo = connectionError.userInfo;
            alert.message = userInfo[@"NSLocalizedDescription"];
            [alert show];
        }else if (statusCode!=200) {
            alert.title = [NSString stringWithFormat:@"请求错误：%d", statusCode];
            alert.message = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            [alert show];
        }else {
            NSError *error;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (result) {
                id success = result[@"success"];
                if ([@"1" isEqualToString:[NSString stringWithFormat:@"%@", success]]) {
                    NSDictionary *user = result[@"user"];
                    NSMutableDictionary *finalUser = [NSMutableDictionary dictionaryWithDictionary:user];
                    [user enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        if (obj == [NSNull null]) {
                            finalUser[key] = @"";
                        }
                    }];
                    [[NSUserDefaults standardUserDefaults] registerDefaults:finalUser];
                    [self performSegueWithIdentifier:@"loginSuccess" sender:nil];
                }else {
                    alert.title = @"登录失败";
                    alert.message = result[@"msg"];
                    [alert show];
                }
                
            }
        }
        
        
    }];
//    NSLog(@"url is %@ and request is %@ and conn is %@", url, request, conn);

//    NSString *postData = [NSString stringWithFormat:@"username=%@&password=%@", _username.text, _password.text];
//    const char *cfStr = [postData cStringUsingEncoding:NSUTF8StringEncoding];
//    CFStringRef bodyString = CFSTR("username=admin&password=1"); // Usually used for POST data
//    CFDataRef bodyData = CFStringCreateExternalRepresentation(kCFAllocatorDefault,
//                                                              bodyString, kCFStringEncodingUTF8, 0);
//    
//    CFStringRef headerFieldName = CFSTR("X-My-Favorite-Field");
//    CFStringRef headerFieldValue = CFSTR("Dreams");
//    
//    const char *cUrl = [_serverUrl.text cStringUsingEncoding:NSUTF8StringEncoding];
//    CFStringRef url = CFSTR("http://office.jee-soft.cn:10080/bpm3");
//    CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
//    
//    CFStringRef requestMethod = CFSTR("POST");
//    CFHTTPMessageRef myRequest =
//    CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL,
//                               kCFHTTPVersion1_1);
//    
//    CFDataRef bodyDataExt = CFStringCreateExternalRepresentation(kCFAllocatorDefault, bodyString, kCFStringEncodingUTF8, 0);
//    CFHTTPMessageSetBody(myRequest, bodyDataExt);
//    CFHTTPMessageSetHeaderFieldValue(myRequest, headerFieldName, headerFieldValue);
//    
//    CFReadStreamRef myReadStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, myRequest);
//    
//    CFReadStreamOpen(myReadStream);
//    CFHTTPMessageRef myResponse = (CFHTTPMessageRef)CFReadStreamCopyProperty(myReadStream, kCFStreamPropertyHTTPResponseHeader);
//    NSLog(@"%@", myResponse);
    
//    [self performSegueWithIdentifier:@"loginSuccess" sender:nil];
    
}

- (void)showAlert:(UITextField*)sender {
    NSString *tip = [sender placeholder];
    UIAlertView *alert = [self getAlertView:nil message:tip cancelButtonTitle:@"确定"];
    [alert show];
}

- (UIAlertView*)getAlertView:(NSString*) title message:(NSString*) message cancelButtonTitle:(NSString*) cancelButtonTitle{
    if(!title) title = @"提示";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil , nil];
    return alert;
}

- (UIAlertView*)showWaitingAlert{
    _waittingAlert = [self getAlertView:@"正在获取数据" message:@"请稍候..." cancelButtonTitle:nil];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
    [_waittingAlert addSubview:activityView];
    [activityView startAnimating];
    [_waittingAlert show];
    return _waittingAlert;
}
- (void)dismissWaitingAlert:(UIAlertView*) waittingAlert{
    if (waittingAlert) {
        [waittingAlert dismissWithClickedButtonIndex:0 animated:YES];
        waittingAlert =nil;
    }
}

@end
