//
//  DNetTool.m
//  AutoDingTalk
//
//  Created by HSEDU on 2017/10/13.
//  Copyright © 2017年 Zhui. All rights reserved.
//

#import "DNetTool.h"

#define BASEURL @"http://101.200.41.79:8080/zhdk/public/index.php/index/"

@implementation DNetTool

+(void)Post:(NSString *)url param:(NSDictionary *)param success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock
{

    DNetTool *tool = [DNetTool new];
    [tool post:url param:param success:successBlock failure:failureBlock];
}
-(void)post:(NSString*)url param:(NSDictionary *)param
    success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock {
    
    NSString *surl = [NSString stringWithFormat:@"%@%@",BASEURL,url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",nil];
    NSMutableDictionary *postBody = [NSMutableDictionary dictionaryWithDictionary:param];
    [postBody setObject:[self getHSUUID] forKey:@"device_id"];
    
    NSLog(@"URL:%@\nBody:%@",surl,param);
    [manager POST:surl parameters:postBody progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
        NSLog(@"这里打印请求成功要做的事");
 
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
        NSLog(@"%@",error);  //这里打印错误信息
    }];
}
+(void)Get:(NSString*)url param:(NSDictionary *)param
       success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock{
    DNetTool*tool = [DNetTool new];
    [tool get:url param:param success:successBlock failure:failureBlock];
}
-(void)get:(NSString*)url param:(NSDictionary *)param
       success:(void (^)(NSDictionary *))successBlock
       failure:(void (^)(NSError *))failureBlock{
    
    NSString *surl = [NSString stringWithFormat:@"%@%@",BASEURL,url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",nil];
    
    [manager GET:surl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             successBlock(responseObject);
             NSLog(@"这里打印请求成功要做的事");
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
             failureBlock(error);
             NSLog(@"%@",error);  //这里打印错误信息
    }];

}
-(NSString *)getHSUUID{
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    uuid = [uuid lowercaseString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (uuid.length>32) {
        uuid = [uuid substringWithRange:(NSMakeRange(0, 32))];
    }
    return uuid;
}
@end
