//
//  Conf.h
//  iLookForiPhone
//
//  Created by Yinghui Zhang on 6/6/12.
//  Copyright (c) 2012 LavaTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject
// App namespace
+ (BOOL) ns:(NSString *)ns;
+ (NSString *)ns;
@end
