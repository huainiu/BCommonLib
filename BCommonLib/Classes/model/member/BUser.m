//
//  BUser.m
//  iShow
//
//  Created by baboy on 13-6-3.
//  Copyright (c) 2013年 baboy. All rights reserved.
//

#import "BUser.h"
#import "BCommonLibContext.h"
#import "BCommonLibDao.h"
#import "BCommonLibCategories.h"

static id _current_user = nil;
@interface BUser()
@property (nonatomic, retain) NSMutableDictionary *dict;
@property (nonatomic, assign) BOOL isLogin;
@end
@implementation BUser
- (void)dealloc{
    ////
    //[super dealloc];
}
- (id)initWithDictionary:(NSDictionary *)dict{
    if ( self = [super initWithDictionary:dict] ) {
        _dict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        if (!self.desc) {
            [self setDesc:nullToNil([dict valueForKey:@"description"])];
        }
    }
    return self;
}
#pragma username
- (void)setUsername:(NSString *)username{
    [self setValue:username forKey:@"username"];
}
- (NSString *)username{
    return [self get:@"username"];
}
#pragma ukey
- (void)setUkey:(NSString *)ukey{
    [self setValue:ukey forKey:@"ukey"];
}
- (NSString *)ukey{
    return [self get:@"ukey"];
}
#pragma nickname
- (void)setNickname:(NSString *)nickname{
    [self setValue:nickname forKey:@"nickname"];
}
- (NSString *)nickname{
    return [self get:@"nickname"];
}
#pragma name
- (void)setName:(NSString *)name{
    [self setValue:name forKey:@"name"];
}
- (NSString *)name{
    return [self get:@"name"];
}
#pragma email
- (void)setEmail:(NSString *)email{
    [self setValue:email forKey:@"email"];

}
- (NSString *)email{
    return [self get:@"email"];
}
#pragma uid
- (void)setUid:(NSString *)uid{
    [self setValue:uid forKey:@"uid"];
}
- (NSString *)uid{
    return [self get:@"uid"];
}
#pragma password
- (void)setPassword:(NSString *)password{
    [self setValue:password forKey:@"password"];
}
- (NSString *)password{
    return [self get:@"password"];
}
#pragma avatar
- (void)setAvatar:(NSString *)avatar{
    [self setValue:avatar forKey:@"avatar"];
}
- (NSString *)avatar{
    return [self get:@"avatar"];
}
- (void)setAvatarThumbnail:(NSString *)avatar{
    [self setValue:avatar forKey:@"avatar_thumbnail"];
}
- (NSString *)avatarThumbnail{
    NSString *thumbnail = [self get:@"avatar_thumbnail"];
    return thumbnail ?: [self avatar];
}
#pragma metadata
- (void)setMetadata:(NSDictionary *)metadata{
    [self setValue:metadata forKey:@"metadata"];
}
- (NSDictionary *)metadata{
    return [self get:@"metadata"];
}
#pragma mobile
- (void)setMobile:(NSString *)mobile{
    [self setValue:mobile forKey:@"mobile"];
}
- (NSString *)mobile{
    return [self get:@"mobile"];
}
#pragma education
- (void)setEducation:(NSString *)education{
    [self setValue:education forKey:@"education"];
}
- (NSString *)education{
    return [self get:@"education"];
}
#pragma school
- (void)setSchool:(NSString *)school{
    [self setValue:school forKey:@"school"];
}
- (NSString *)school{
    return [self get:@"school"];
}
#pragma desc
- (void)setDesc:(NSString *)desc{
    [self setValue:desc forKey:@"desc"];
}
- (NSString *)desc{
    return [self get:@"desc"];
}
#pragma signature
- (void)setSignature:(NSString *)signature{
    [self setValue:signature forKey:@"signature"];
}
- (NSString *)signature{
    return [self get:@"signature"];
}
#pragma birthday
- (void)setBirthday:(NSString *)birthday{
    [self setValue:birthday forKey:@"birthday"];
}
- (NSDate *)birthday{
    return [self get:@"birthday"];
}
#pragma set get
- (id)get:(NSString *)key{
    return nullToNil([self.dict valueForKey:key]);
}
- (void)setValue:(id)val forKey:(NSString *)key{
    if (!val) {
        [_dict removeObjectForKey:key];
        return;
    }
    id oldVal = [/*AUTORELEASE*/(/*RETAIN*/([self get:key])) description];
    [self.dict setValue:val forKey:key];
    if (self.isLogin && ![[val description] isEqualToString:oldVal]) {
        [BUser updateProfile:self];
    }
}
- (NSDictionary *)dict{
    if (!_dict) {
        _dict = [NSMutableDictionary dictionaryWithCapacity:3] ;
    }
    return _dict;
}
+ (BOOL)isLogin{
    return USER?YES:NO;
}
+ (id)user{
    @synchronized(self){
        if (!_current_user) {
            NSDictionary *json = [[DBCache valueForKey:@"USER"] json];
            if (json){
                NSString *uc = [DBCache valueForKey:@"USER_CLASS"];
                if (!uc)
                    uc = NSStringFromClass([self class]);
                Class userClass = NSClassFromString(uc);
                _current_user = [[userClass alloc] initWithDictionary:json];
                [_current_user setIsLogin:YES];
            }
        }
    }
    return _current_user;
}
+ (void)updateProfile:(BUser *)user{
    NSString *data = [[user dict] jsonString];
    DLOG(@"%@", data);
    if (data) {
        [DBCache setValue:data forKey:@"USER"];
        [DBCache setValue:NSStringFromClass([user class]) forKey:@"USER_CLASS"];
        ////
        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyUserProfileUpdated object:nil];
        return;
    }
}
+ (BOOL)loginWithUser:(BUser *)user{
    if (user) {
        if ([self user]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserWillChange object:nil];
        }
        NSString *data = [[user dict] jsonString];
        DLOG(@"%@", data);
        if (data) {
            [DBCache setValue:data forKey:@"USER"];
            [DBCache setValue:NSStringFromClass([user class]) forKey:@"USER_CLASS"];
            ////
            [[NSNotificationCenter defaultCenter] postNotificationName:NotifyLogin object:nil];
            return YES;
        }else{
            DLOG(@"error");
        }
    }
    return NO;
}
+ (void)logout{
    [DBCache removeForKey:@"USER"];
    if (_current_user) {
        ////
        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyLogout object:nil];
    }
}
+ (void)checkLoginWithCallback:(void (^)(BUser* user,NSError *error))callback{
}
+ (BHttpRequestOperation *)loginWithUserName:(NSString *)uname password:(NSString *)pwd success:(void (^)(BUser *, NSError *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *params = @{@"username":uname,@"password":pwd};
    
    return [[BHttpRequestManager defaultManager]
            jsonRequestOperationWithPostRequest:ApiLogin
            parameters:params
            success:^(BHttpRequestOperation *operation, id responseObject) {
                
            }
            failure:^(BHttpRequestOperation *operation, NSError *error) {
                DLOG(@"[BUser] loginWithUserName error:%@",error);
            }];
}
+ (BHttpRequestOperation *)registerWithUserName:(NSString *)uname email:(NSString *)email password:(NSString *)pwd success:(void (^)(BUser *, NSError *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *params = @{@"username":uname,@"password":pwd,@"email":email};
    return [[BHttpRequestManager defaultManager]
           jsonRequestOperationWithPostRequest:ApiRegister
           parameters:params
           success:^(BHttpRequestOperation *operation, id responseObject) {
               
           }
           failure:^(BHttpRequestOperation *operation, NSError *error) {
               DLOG(@"[BUser] registerWithUserName error:%@",error);
           }];
}
@end
