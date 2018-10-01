//
//  DIMEnvelope.h
//  iChat
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;

/**
 *  Envelope for message
 *
 *      data format: {
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123
 *      }
 */
@interface DIMEnvelope : DIMDictionary

@property (readonly, strong, nonatomic) const MKMID *sender;
@property (readonly, strong, nonatomic) const MKMID *receiver;

@property (readonly, strong, nonatomic) const NSDate *time;

- (instancetype)initWithSender:(const MKMID *)from
                      receiver:(const MKMID *)to;

- (instancetype)initWithSender:(const MKMID *)from
                      receiver:(const MKMID *)to
                          time:(const NSDate *)time
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END