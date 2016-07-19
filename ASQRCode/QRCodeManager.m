//
//  QRCodeManager.m
//  QRCodeReader
//
//  Created by ashen on 16/6/20.
//  Copyright © 2016年 Ashen. All rights reserved.
//

#import "QRCodeManager.h"


@interface QRCodeManager()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) UIView *scanLayer;
@property (strong, nonatomic) UIView *boxView;
@end

@implementation QRCodeManager


- (void)applicationDidEnterBackground {
    [_scanLayer removeFromSuperview];
}

- (void)applicationWillEnterForeground {
    [self addScanLine];
}

- (void)addScanLine {
    _scanLayer = [[UIView alloc] init];
    _scanLayer.frame = CGRectMake(10, 0, _boxView.bounds.size.width - 20, 1.5);
    _scanLayer.backgroundColor = [UIColor greenColor];
    [_boxView addSubview:_scanLayer];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
    [UIView setAnimationRepeatCount:10000];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:_scanLayer cache:YES];
    [UIView setAnimationRepeatAutoreverses:YES];
    CGRect frame = _scanLayer.frame;
    frame.origin.y = _boxView.frame.size.height - 5;
    _scanLayer.frame = frame;
    
    [UIView commitAnimations];
    
}

- (void)configureManager:(UIView *)viewPreview {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    
    _captureSession = [[AVCaptureSession alloc] init];
    if([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    [_captureSession addInput:input];
    
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("qrQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    
    [_videoPreviewLayer setFrame:viewPreview.layer.bounds];
    
    
    [viewPreview.layer addSublayer:_videoPreviewLayer];
    
    
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    CGRect boxFrame = CGRectMake(viewPreview.bounds.size.width * 0.2, viewPreview.bounds.size.height * 0.3,  viewPreview.bounds.size.width * 0.6, viewPreview.bounds.size.width * 0.6);
    _boxView = [[UIView alloc] initWithFrame:boxFrame];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    [viewPreview addSubview:_boxView];
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:viewPreview.bounds cornerRadius:0];
    
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRoundedRect:boxFrame cornerRadius:0];
    [path appendPath:framePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *_fillLayer = [CAShapeLayer layer];
    
    _fillLayer.path = path.CGPath;
    
    _fillLayer.fillRule =kCAFillRuleEvenOdd;
    
    _fillLayer.fillColor = [UIColor blackColor].CGColor;
    
    _fillLayer.opacity = 0.3;
    
    [viewPreview.layer addSublayer:_fillLayer];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_boxView.frame) + 25, viewPreview.frame.size.width, 30)];
    lbl.text = @"将二维码放到扫描框内";
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [viewPreview addSubview:lbl];
    [self addScanLine];
    [_captureSession startRunning];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopScan) withObject:nil waitUntilDone:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(qrCodeResult:)]) {
                    [_delegate qrCodeResult:[metadataObj stringValue]];
                }
            });
        
        }
    }
}

- (void)stopScan {
    [_captureSession stopRunning];
    [_scanLayer removeFromSuperview];
    [_boxView removeFromSuperview];
    [_videoPreviewLayer removeFromSuperlayer];
    _captureSession = nil;
}

@end
