//
//  ViewController.m
//  qrcode
//
//  Created by Maolin Ge on 2017/4/18.
//  Copyright © 2017年 Maolin Ge. All rights reserved.
//定义屏幕宽高的宏
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

#warning TODO:使用时，请将ViewController改成你的控制器名，把本文件拷到你的工程,需要在真机上运行，获取摄像头授权，模拟器上会崩溃

#import "ViewController.h"//使用时，请将ViewController改成你的控制器名，把本文件拷到你的工程
#import <AVFoundation/AVFoundation.h>//包含需要的头文件

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>//捕获元数据输出对象代理

@property(nonatomic)AVCaptureDevice* device;//捕获设备
@property(nonatomic)AVCaptureDeviceInput *input;//输入
@property(nonatomic)AVCaptureMetadataOutput *output;//输出
@property(nonatomic)AVCaptureSession *session;//会话
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;//预览层

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描二维码";//通过导航控制器压栈形式来显示扫描二维码
    [self createCaptureDevice];//创建捕获设备
    [self addImageView];//设置扫描区域
    //设置导航条返回按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    leftButton = nil;
}

-(void)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
//设置扫描框区域位置，仅供参考
-(void)addImageView{
    CGFloat imageWidth = 210;
    CGFloat y = (SCREEN_HEIGHT - 128 - imageWidth) / 2;
    CGFloat margin = (SCREEN_WIDTH - imageWidth) / 2;
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(margin, y, imageWidth, imageWidth)];
    imgView.backgroundColor = [UIColor clearColor];
    [imgView setImage:[UIImage imageNamed:@"capture_frame"]];
    [self.view addSubview:imgView];
    UIColor *bgColor = [UIColor colorWithRed:22 / 255.0 green:22 / 255.0 blue:22 / 255.0 alpha:0.4];
    UIView *bgTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, y)];
    bgTop.backgroundColor = bgColor;
    [self.view addSubview:bgTop];
    UIView *bgBottom = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(imgView.frame))];
    bgBottom.backgroundColor = bgColor;
    [self.view addSubview:bgBottom];
    UIView *bgLeft = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(imgView.frame), margin, imageWidth)];
    bgLeft.backgroundColor = bgColor;
    [self.view addSubview:bgLeft];
    UIView *bgRight = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame), CGRectGetMinY(imgView.frame), margin, imageWidth)];
    bgRight.backgroundColor = bgColor;
    [self.view addSubview:bgRight];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(imgView.frame) - 46, SCREEN_WIDTH, 50)];
    titleLabel.text = @"请在Xcode控制台打印输出里查看扫描信息\n扫描二维码";
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:titleLabel];
}
#pragma mark - 创建捕获设备
-(void)createCaptureDevice{
    //设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    //输出
    self.output = [[AVCaptureMetadataOutput alloc]init];
    //设置输出代理为控制器
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //会话
    self.session = [[AVCaptureSession alloc]init];
    
    if ([self.session canAddInput:self.input])
        [self.session addInput:self.input];
    
    if ([self.session canAddOutput:self.output])
        [self.session addOutput:self.output];
    //设置条码类型
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    //预览层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    //启动会话
    [self.session startRunning];
}
#pragma mark-扫描二维码的代理方法
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self.session stopRunning];//停止运行会话
    //对扫描的数据进行解析
    if ([metadataObjects count] >= 1) {
        AVMetadataMachineReadableCodeObject *qrObject = [metadataObjects lastObject];
        NSLog(@"%@",qrObject.stringValue);//打印二维码内容
        NSData *data = [qrObject.stringValue dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //对解析的json数据进行判断，
    /*    if ([json isKindOfClass:[NSDictionary class]] && [json objectForKey:@"i"] && [json objectForKey:@"t"] && [json objectForKey:@"s"] && [json objectForKey:@"_Uc_"] && [json objectForKey:@"_Uv_"]) {
            if (([[json objectForKey:@"_Uc_"] intValue] == 4) && ([[json objectForKey:@"_Uv_"] intValue] == 1)) {
                NSString *ssid = [json objectForKey:@"s"];
                if (ssid.length > 0) {
     
                    //do something。 解析到正确数据后的逻辑功能处理，比如给感兴趣的对象发二维码扫描成功的通知，同时把json数据传过去
     
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_QR_CONNECT  object:nil userInfo:json];
                    [self.session stopRunning];//成功，停止会话
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
            }
        }
        */
        //如果没有解析到有效数据，弹出提示框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无效的二维码" message:@"请在Xcode控制台打印输出查看扫描的二维码内容" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {//点击确认后，重启会话，继续扫描
            [self.session stopRunning];
            [self.session startRunning];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        alert = nil;
        ok = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.session stopRunning];//视图消失 停止会话
}

@end
