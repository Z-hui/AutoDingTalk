//
//  DNetTool.h
//  AutoDingTalk
//
//  Created by HSEDU on 2017/10/13.
//  Copyright © 2017年 Zhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNetTool : NSObject
+(void)Get:(NSString *)url param:(NSDictionary *)param
   success:( void (^)( NSDictionary * responseObject))successBlock
   failure:( void (^)( NSError *  error))failureBlock;

+(void)Post:(NSString *)url param:(NSDictionary *)param
   success:( void (^)( NSDictionary * responseObject))successBlock
   failure:( void (^)( NSError *  error))failureBlock;
@end
