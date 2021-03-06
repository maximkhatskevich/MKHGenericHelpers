//
//  NSObject+MKHGenericHelpers.m
//  MKHGenericHelpers
//
//  Created by Maxim Khatskevich on 22/01/15.
//  Copyright (c) 2015 Maxim Khatskevich. All rights reserved.
//

#import "NSObject+MKHGenericHelpers.h"

#import "MKHMacros.h"
#import <objc/runtime.h>

@implementation NSObject (MKHGenericHelpers)

#pragma mark - Property accessors

- (NSArray *)allPropertyNames
{
    // http://stackoverflow.com/a/11774276
    
    //===
    
    NSMutableArray *result = [NSMutableArray array];
    
    //===
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [result addObject:name];
    }
    
    free(properties);
    
    //===
    
    return result;
}

#pragma mark - Custom

+ (instancetype)objectWithProperties:(NSDictionary *)properties
{
    id result = nil;
    
    //=== create entity:
    
    result = [[self class] new];
    
    //=== populate properties in instance:
    
    if (result && properties)
    {
        [result setValuesForKeysWithDictionary:properties];
    }
    
    //===
    
    return result;
}

- (void)configureWithProperties:(NSDictionary *)properties
{
    if (properties)
    {
        [self setValuesForKeysWithDictionary:properties];
    }
}

+ (instancetype)newWithObject:(id)object
{
    id result = [[self class] new];
    
    //===
    
    [result configureWithObject:object];
    
    //===
    
    return result;
}

- (void)configureWithObject:(id)object
{
    // any kind of initial configuration should be done here
}

- (void)applyItem:(id)item
{
    // any item selection events should be processed here
}

- (NSString *)stringValueForKey:(NSString *)key
{
    NSString *result = @"N/A";
    
    //===
    
    if (MKH_isObjectForKeySupported(self))
    {
        id obj = [(id)self objectForKey:key];
        
        if ([obj isKindOfClass:[NSString class]]) // not nil & string
        {
            result = (NSString *)obj;
        }
    }
    
    //===
    
    return result;
}

- (NSDictionary *)dictFromJSONForKey:(NSString *)key
{
    return (NSDictionary *)[self objectFromJSONForKey:key];
}

- (NSArray *)arrayFromJSONForKey:(NSString *)key
{
    return (NSArray *)[self objectFromJSONForKey:key];
}

- (id)objectFromJSONForKey:(NSString *)key
{
    id result = nil;
    
    //==
    
    if (MKH_isObjectForKeySupported(self))
    {
        NSError *jsonError;
        
        NSString *definitionStr = [(id)self objectForKey:key];
        
        if ([definitionStr isKindOfClass:[NSString class]])
        {
            result =
            [NSJSONSerialization
             JSONObjectWithData:[definitionStr dataUsingEncoding:NSUTF8StringEncoding]
             options:NSJSONReadingAllowFragments error:&jsonError];
        }
    }
    
    //===
    
    return result;
}

- (NSString *)stringFromDateForKey:(NSString *)dateKey withFormat:(NSString *)format
{
    NSString *result = nil;
    
    //===
    
    if (MKH_isObjectForKeySupported(self))
    {
        NSDate *val = [(id)self objectForKey:dateKey];
        
        if (val)
        {
            static NSDateFormatter *dateFormatter = nil;
            static dispatch_once_t onceToken;
            
            dispatch_once(&onceToken, ^{
                
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
            });
            
            //===
            
            [dateFormatter setDateFormat:format];
            result = [dateFormatter stringFromDate:val];
        }
    }
    
    //===
    
    return result;
}

+ (BOOL)isClassOfObject:(id)objectToCheck
{
    return MKH_isClassOfObject([self class], objectToCheck);
}

@end
