//
//  ViewController.m
//  RuntimeBasicKnowledgeProject
//
//  Created by zhifu360 on 2019/6/3.
//  Copyright © 2019 ZZJ. All rights reserved.
//

#import "ViewController.h"
#import "Account.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Runtime基础知识";
//    [self classGetOperation];
//    [self copyIvarListOperation];
//    [self copyMethodListOperation];
//    [self copyPropertyListOperation];
//    [self copyProtocolListOperation];
    
//    [self addIvarOperation];
//    [self addMethodOperation];
//    [self addPropertyOperation];
//    [self addProtocolOperation];
    
    [self addClassOperation];
}

///获取super class, name, version, instance size
- (void)classGetOperation {
    NSLog(@"name = %s",class_getName([Account class]));
    NSLog(@"version = %d",class_getVersion([Account class]));
    NSLog(@"size = %zu",class_getInstanceSize([Account class]));
    NSLog(@"super class = %@",class_getSuperclass([Account class]));
}

#pragma mark 获取ivarList,methodList,propertyList,prorocolList
///ivarList
- (void)copyIvarListOperation {
    unsigned int count = 0;
    Ivar *list = class_copyIvarList([Account class], &count);
    for (unsigned int index = 0; index < count; index ++) {
        Ivar ivar = list[index];
        const char *ivarName = ivar_getName(ivar);
        NSLog(@"ivar: %s",ivarName);
    }
    free(list);
}

///methodList
- (void)copyMethodListOperation {
    unsigned int count = 0;
    Method *list = class_copyMethodList([Account class], &count);
    for (unsigned int index = 0; index < count; index ++) {
        Method method = list[index];
        const char *selName = sel_getName(method_getName(method));
        const char *methodEncoding = method_getTypeEncoding(method);
        NSLog(@"selName: %s, typeEncoding: %s",selName,methodEncoding);
    }
    free(list);
}

///propertyList
- (void)copyPropertyListOperation {
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList([Account class], &count);
    for (unsigned int index = 0; index < count; index ++) {
        objc_property_t property = list[index];
        const char *propertyName = property_getName(property);
        NSLog(@"property name: %s",propertyName);
    }
    free(list);
}

///prorocolList
- (void)copyProtocolListOperation {
    unsigned int count = 0;
    Protocol * __unsafe_unretained *list = class_copyProtocolList([Account class], &count);
    for (unsigned int index = 0; index < count; index ++) {
        Protocol *protocol = list[index];
        const char *protocolName = protocol_getName(protocol);
        NSLog(@"protocol name: %s",protocolName);
    }
    free(list);
}

#pragma mark 添加ivar,method,property,protocol

///ivar
- (void)addIvarOperation {
    BOOL result = class_addIvar([Account class], "_email", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    if (result) {
        [self copyIvarListOperation];
    } else {
        NSLog(@"添加成员变量失败");
    }
}

///method
- (void)addMethodOperation {
    IMP imp = imp_implementationWithBlock(^{
        NSLog(@"implementation block");
    });
    BOOL result = class_addMethod([Account class], @selector(newMethodOperation), imp, nil);
    if (result) {
        [self copyMethodListOperation];
        Account *account = [[Account alloc] init];
        [account performSelector:@selector(newMethodOperation) withObject:nil];
    } else {
        NSLog(@"添加方法失败");
    }
    imp_removeBlock(imp);
}

///property
- (void)addPropertyOperation {
    objc_property_attribute_t attribute[] = {{"T","NSString"},{"R",""}};
    BOOL result = class_addProperty([Account class], "newPropertyName", attribute, 2);
    if (result) {
        [self copyPropertyListOperation];
    } else {
        NSLog(@"添加属性失败");
    }
}

- (void)addProtocolOperation {
    Protocol *protocol = objc_allocateProtocol("Swifty5Indexable");
    BOOL result = class_addProtocol([Account class], protocol);
    if (result) {
        [self copyProtocolListOperation];
    } else {
        NSLog(@"添加协议失败");
    }
}

#pragma mark 添加class

- (void)addClassOperation {
    Class userInfoClass = objc_allocateClassPair([NSObject class], "UserInfo", 0);
    class_addIvar(userInfoClass, "_email", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    //注册printLoginInfo方法
    SEL sel = sel_registerName("printLoginInfo");
    IMP imp = imp_implementationWithBlock(^(id self, SEL _cmd, id info) {
        NSLog(@"账号是：%@ %@",[self valueForKey:@"email"],info);
    });
    class_addMethod(userInfoClass, sel, imp, "v@:@");
    //注册UserInfo类
    objc_registerClassPair(userInfoClass);
    id userInfoObject = [[userInfoClass alloc] init];
    //使用KVO设置变量值
    [userInfoObject setValue:@"xxx@icloud.com" forKey:@"email"];
    void (^block)(id self, SEL _cmd, id info) = imp_getBlock(imp);
    block(userInfoObject, sel, @"欢迎学习Runtime基础知识");
    [userInfoObject performSelector:@selector(printLoginInfo) withObject:@"再次欢迎"];
    //销毁实例对象
    userInfoObject = nil;
    //销毁类对象
    objc_disposeClassPair(userInfoClass);
    
}

@end

