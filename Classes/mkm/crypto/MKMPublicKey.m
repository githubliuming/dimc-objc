//
//  MKMPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPrivateKey.h"
#import "MKMRSAPublicKey.h"
#import "MKMECCPublicKey.h"

#import "MKMPublicKey.h"

@implementation MKMPublicKey

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    self = [self initWithAlgorithm:ACAlgorithmRSA];
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info {
    NSAssert([algorithm isEqualToString:[info objectForKey:@"algorithm"]], @"error");
    
    if ([self isMemberOfClass:[MKMPublicKey class]]) {
        // create instance with algorithm
        if ([algorithm isEqualToString:ACAlgorithmECC]) {
            self = [[MKMECCPublicKey alloc] initWithAlgorithm:algorithm keyInfo:info];
        } else if ([algorithm isEqualToString:ACAlgorithmRSA]) {
            self = [[MKMRSAPublicKey alloc] initWithAlgorithm:algorithm keyInfo:info];
        } else {
            self = nil;
            NSAssert(self, @"algorithm not support: %@", algorithm);
        }
    } else {
        NSAssert([[self class] isSubclassOfClass:[MKMPublicKey class]], @"error");
        // subclass
        self = [super initWithAlgorithm:algorithm keyInfo:info];
    }
    
    return self;
}

- (BOOL)isMatch:(const MKMPrivateKey *)SK {
    // 1. if the SK has the same public key, return YES
    if ([SK.publicKey isEqual:self]) {
        return YES;
    }
    // 2. try to verify the SK's signature
    NSString *promise = @"Moky loves May Lee forever!";
    NSData *data = [promise dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signature = [SK sign:data];
    return [self verify:data signature:signature];
}

- (NSData *)encrypt:(const NSData *)plaintext {
    // implements in subclass
    return nil;
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    // implements in subclass
    return NO;
}

@end

@implementation MKMPublicKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMPublicKey *PK = nil;
    
    // try ECC public key
    PK = [MKMECCPublicKey loadKeyWithIdentifier:identifier];
    if (PK) {
        return PK;
    }
    
    // try RSA public key
    PK = [MKMRSAPublicKey loadKeyWithIdentifier:identifier];
    if (PK) {
        return PK;
    }
    
    // key not found
    return PK;
}

@end
