//
//  NSString+BMRegEx.m
//  BMBasekit
//
//  Created by DennisDeng on 2017/4/28.
//  Copyright © 2017年 DennisDeng. All rights reserved.
//

#import "NSString+BMRegEx.h"

@implementation NSString (BMRegEx)

- (NSRegularExpression *)bm_toRx
{
    return [[NSRegularExpression alloc] initWithPattern:self];
}

- (NSRegularExpression *)bm_toRxIgnoreCase:(BOOL)ignoreCase
{
    return [NSRegularExpression bm_rx:self ignoreCase:ignoreCase];
}

- (NSRegularExpression *)bm_toRxWithOptions:(NSRegularExpressionOptions)options
{
    return [NSRegularExpression bm_rx:self options:options];
}

- (BOOL)bm_isMatch:(NSRegularExpression *)rx
{
    return [rx bm_isMatch:self];
}

- (NSInteger)bm_indexOf:(NSRegularExpression *)rx
{
    return [rx bm_indexOf:self];
}

- (NSArray <NSString *>*)bm_split:(NSRegularExpression *)rx
{
    return [rx bm_split:self];
}

- (NSString *)bm_replace:(NSRegularExpression *)rx with:(NSString *)replacement
{
    return [rx bm_replace:self with:replacement];
}

- (NSString *)bm_replace:(NSRegularExpression *)rx withBlock:(NSString * (^)(NSString *match))replacer
{
    return [rx bm_replace:self withBlock:replacer];
}

- (NSString *)bm_replace:(NSRegularExpression *)rx withDetailsBlock:(NSString * (^)(BMRxMatch *match))replacer
{
    return [rx bm_replace:self withDetailsBlock:replacer];
}

- (NSArray <NSString *>*)bm_matches:(NSRegularExpression *)rx
{
    return [rx bm_matches:self];
}

- (NSString *)bm_firstMatch:(NSRegularExpression *)rx
{
    return [rx bm_firstMatch:self];
}

- (NSArray <BMRxMatch *>*)bm_matchesWithDetails:(NSRegularExpression *)rx
{
    return [rx bm_matchesWithDetails:self];
}

- (BMRxMatch *)bm_firstMatchWithDetails:(NSRegularExpression *)rx
{
    return [rx bm_firstMatchWithDetails:self];
}

#pragma mark ori

- (BOOL)bm_isValidPhoneNumber
{
    if (!self.length)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMPHONE_PATTERN];
}

- (BOOL)bm_isValidPassword
{
    if (!self.length)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMPASSWORD_PATTERN];
}

- (BOOL)bm_isValidNickName
{
    if (!self.length || self.length > 8)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMNICKNAME_PATTERN];
}

- (BOOL)bm_isValidDomain
{
    if (!self.length)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMDOMAIN_PATTERN];
}

- (BOOL)bm_isValidChinesePhoneNumber
{
    if (self.length != 11)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMPHONE_PATTERN_CHINESE];
}

- (BOOL)bm_isValidEMailAddress
{
    if (!self.length)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMEMAIL_PATTERN];
}

- (BOOL)bm_isValidIPAddress
{
    if (self.length > 12 ||
        self.length < 7)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMIP_PATTERN];
}

- (BOOL)bm_isValidMD532String
{
    if (self.length != 32)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMMD5_32_PATTERN];
}

- (BOOL)bm_isValidChineseIDNumberString
{
    if (self.length < 15 ||
        self.length > 18)
    {
        return NO;
    }
    return [self bm_isMatchWithPattern:BMCHINESE_ID_NUMBER_PATTERN];
}

- (NSArray <NSString *>*)bm_matchesWithPattern:(NSString *)pattern
{
    return [self bm_matches:BMRX(pattern)];
}

- (NSString *)bm_firstMatchWithPattern:(NSString *)pattern
{
    return [self bm_firstMatch:BMRX(pattern)];
}

- (BOOL)bm_isMatchWithPattern:(NSString *)pattern
{
    return [self bm_isMatch:BMRX(pattern)];
}

- (NSRange)bm_rangOfFirstMatchWithPattern:(NSString *)pattern
{
    NSError *error;
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    NSRange range = [regEx rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return range;
}

- (NSInteger)bm_indexOfFirstMatchWithPattern:(NSString *)pattern
{
    NSRange range = [self bm_rangOfFirstMatchWithPattern:pattern];
    return range.location == NSNotFound ? -1 : (int)range.location;
}

- (NSString *)bm_stringByReplacingOccurrencesOfPattern:(NSString *)pattern withString:(NSString *)string
{
    return [self bm_replace:BMRX(pattern) with:string];
}

- (NSString *)bm_replaceWithPattern:(NSString *)pattern to:(NSString *)replacement
{
    return [self bm_replace:BMRX(pattern) with:replacement];
}

- (NSArray<NSString *> *)bm_splitWithPattern:(NSString *)pattern
{
    return [self bm_split:BMRX(pattern)];
}

@end
