//
//  ViewController.m
//  ASQRCode
//
//  Created by ashen on 16/7/15.
//  Copyright © 2016年 Ashen. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeManager.h"

@interface ViewController ()<QRCodeManagerDelegate>
@property (nonatomic, strong) QRCodeManager *qr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _qr = [[QRCodeManager alloc] init];
    _qr.delegate = self;
    [_qr configureManager:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)qrCodeResult:(NSString *)result {
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:result delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];
}

@end
