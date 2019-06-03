//
//  Account.h
//  RuntimeBasicKnowledgeProject
//
//  Created by zhifu360 on 2019/6/3.
//  Copyright © 2019 ZZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AccountDelegate <NSObject>

- (void)buy;

@end

NS_ASSUME_NONNULL_BEGIN

@interface Account : NSObject<AccountDelegate>

@property (nonatomic, copy) NSString *passwordToken;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;

@property (nonatomic, weak) id<AccountDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
