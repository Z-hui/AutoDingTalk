//
//  DNetTool.m
//  AutoDingTalk
//
//  Created by HSEDU on 2017/10/13.
//  Copyright © 2017年 Zhui. All rights reserved.
//

#import "DNetTool.h"

@implementation DNetTool

+(void)Post:(NSString *)url param:(NSDictionary *)param success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock
{

    DNetTool *tool = [DNetTool new];
    [tool post:url param:param success:successBlock failure:failureBlock];
}
-(void)post:(NSString*)url param:(NSDictionary *)param
    success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock {
    
    NSString *surl = [NSString stringWithFormat:@"%@%@",@"http://appdev.hskaoyan.com/v3/",url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",nil];
    
    [manager POST:surl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
    
    NSString *surl = [NSString stringWithFormat:@"%@%@",@"http://appdev.hskaoyan.com/v3/",url];
    
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
@end
