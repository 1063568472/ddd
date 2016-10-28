//
//  ViewController.m
//  支付练习
//
//  Created by 孙玮超 on 16/10/17.
//  Copyright © 2016年 GZ_lanou. All rights reserved.
//

#import "ViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    NSString *partner = @"2088011610671335";
    NSString *seller = @"luckyaoyaocom@163.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMhwKChlA3X8hctlbcjVma8HRwBR6bSnAewpoHna1w8RGJZRjGOPXfjlW0cwFulc10BbHb/wk1A9NhSFoq7mR2M23SI6uodOtmDZ8Huhb122JdLsalZ190sx4AKq7dEOOyQxFuv0dMP0zBIjc5ICjgQz7M8jw8pJ+8zQQYyA8Y+tAgMBAAECgYA03tjI5vRFwAluwF94FVfHgmzpGbJC07a/G6/X1LDbqY/JvtMARAXurFkqavXwMmwY7q/nPEcvaCYGvcVOyzFS831ddIdlpL7DOI6u5Ve04JCh0jIEEA8iSvnW5VX9JvJMUR2u7s56+9gyN9TW8oR9vNZx438HJFcZZLfCaftL5QJBAPTZx9yoRhKzbjo/Ztp8X9u5ZlnU4xyq8jTCsARowJqd7vIT6WVSfPYoSWaw9U/wWiR3kCjuOrD1wIA+BCKOEqsCQQDRkKjXSJ2M674qji9UN2PpW6tse63ub1Xr8vyBRv5IO37aySLshugFXD3nf2IjbEXrFbfo0/O+i6wHQX2mpScHAkEA3cP6b3LBtOJrLbqLD8yijcJIX4igAzEZmovTHMs7107AQuWh+TFTGSi4Api4NyT8oBbirQ/IfMq5Be4llJ6VbQJAffjKNZcV9dbj2ircMnCVY3pSQoTaGeDdMlc/B+sIAZ2Z9KRBlRLHOCmpoJXHBWoZYWYNxixacaj+AOKSSHEwUwJAWLhKW1jbUAztKyOu0g/SuqUgOkt9D39OtHxqrmz/euMBstb4WFfhpCzImjpSzTY2m85Ikir7GrUaS7SgJfdhqg==";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 || [seller length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
#pragma mark 这是订单号,订单号不可重复
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定
#pragma mark 下面的是商品描述
    order.productName = @""; //商品标题
    order.productDescription = @""; //商品描述
    order.amount = [NSString stringWithFormat:@"100"]; //商品价格
#pragma mark URL是回到你的程序的url
    order.notifyURL =  @"http://api.luckyaoyao.com//order/respond/code/appalipay.html"; //回调URL
#pragma mark 下面这些不用动
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alisdkdemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
    
}

#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
