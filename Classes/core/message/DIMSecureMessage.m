//
//  DIMSecureMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMEnvelope.h"
#import "DIMInstantMessage.h"

#import "DIMSecureMessage.h"

@implementation DIMEncryptedKeyMap

- (void) setObject:(id)anObject forKey:(const NSString *)aKey {
    NSAssert(false, @"DON'T call me");
    //[super setObject:anObject forKey:aKey];
}

- (NSData *)encryptedKeyForID:(const MKMID *)ID {
    NSString *encode = [_storeDictionary objectForKey:ID.address];
    return [encode base64Decode];
}

- (void)setEncryptedKey:(NSData *)key forID:(const MKMID *)ID {
    NSString *encode = [key base64Encode];
    [_storeDictionary setObject:encode forKey:ID.address];
}

@end

#pragma mark -

@interface DIMSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic) NSData *encryptedKey;
@property (strong, nonatomic) DIMEncryptedKeyMap *encryptedKeys;

@end

@implementation DIMSecureMessage

- (instancetype)initWithEnvelope:(const DIMEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *data = nil;
    NSData *key = nil;
    self = [self initWithData:data encryptedKey:key envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
                encryptedKey:(const NSData *)key
                    envelope:(const DIMEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // content data
        _data = [content copy];
        [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        
        // encrypted key
        if (key) {
            _encryptedKey = [key copy];
            [_storeDictionary setObject:[key base64Encode] forKey:@"key"];
        }
        
        _encryptedKeys = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
               encryptedKeys:(const DIMEncryptedKeyMap *)keys
                    envelope:(const DIMEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // content data
        _data = [content copy];
        [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        
        _encryptedKey = nil;
        
        // encrypted keys
        if (keys.count > 0) {
            _encryptedKeys = [keys copy];
            [_storeDictionary setObject:_encryptedKeys forKey:@"keys"];
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _data = nil;
        _encryptedKey = nil;
        _encryptedKeys = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMSecureMessage *sMsg = [super copyWithZone:zone];
    if (sMsg) {
        sMsg.data = _data;
        sMsg.encryptedKey = _encryptedKey;
        sMsg.encryptedKeys = _encryptedKeys;
    }
    return sMsg;
}

- (NSData *)data {
    if (!_data) {
        NSString *content = [_storeDictionary objectForKey:@"data"];
        NSAssert(content, @"content data cannot be empty");
        _data = [content base64Decode];
    }
    return _data;
}

- (NSData *)encryptedKey {
    if (!_encryptedKey) {
        NSString *key = [_storeDictionary objectForKey:@"key"];
        if (key) {
            _encryptedKey = [key base64Decode];
        } else {
            MKMID *ID = self.envelope.receiver;
            NSAssert(MKMNetwork_IsPerson(ID.type), @"error");
            // get from the key map
            DIMEncryptedKeyMap *keyMap = self.encryptedKeys;
            return [keyMap encryptedKeyForID:ID];
        }
    }
    return _encryptedKey;
}

- (DIMEncryptedKeyMap *)encryptedKeys {
    if (!_encryptedKeys) {
        NSDictionary *keys = [_storeDictionary objectForKey:@"keys"];
        DIMEncryptedKeyMap *map;
        map = [[DIMEncryptedKeyMap alloc] initWithDictionary:keys];
        _encryptedKeys = map;
    }
    return _encryptedKeys;
}

@end
