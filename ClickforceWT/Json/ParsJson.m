#import "ParsJson.h"
@implementation ParsJson

//- (id)initWithValue:(NSDictionary *)json{
//    if (self = [super init]) {
//        jsonvalue = json;
//        if (jsonvalue == nil) {
//            return nil;
//        }
//    }
//
//    return self;
//}
- (id)initWithValue:(NSData *) value{
    if (self = [super init]) {
        NSError *error = nil;
        jsonvalue = [NSJSONSerialization JSONObjectWithData:value options:kNilOptions error:&error];
        if (jsonvalue == nil) {
            return nil;
        }
    }
    
    return self;
}

- (id)initWithNSDictionary:(NSDictionary *) dic{
    if (self = [super init]) {
        jsonvalue = dic;
        if (jsonvalue == nil) {
            return nil;
        }
    }
    
    return self;
}

//- (id)initWithValue:()

- (int)status{
    return [[jsonvalue objectForKey:@"status"] intValue];
}

- (NSString *)msg{
    return [jsonvalue objectForKey:@"msg"];
}

- (int)userId{
    return [[jsonvalue objectForKey:@"id"] intValue];
}

- (NSString *)userName{
    return [jsonvalue objectForKey:@"name"];
}

-(NSArray *)userEmail{
    return [jsonvalue objectForKey:@"email"];
}

- (int)result{
    return [[jsonvalue objectForKey:@"result"] intValue];
}

- (NSString *)type{
    return [jsonvalue objectForKey:@"type"];
}

- (NSString *)date{
    return [jsonvalue objectForKey:@"date"];
}

- (NSString *)clockin{
    return [jsonvalue objectForKey:@"time_clock_in"];
}

- (NSString *)clockout{
    return [jsonvalue objectForKey:@"time_clock_out"];
}

- (NSArray *)item{
    return [jsonvalue objectForKey:@"item"];
}
@end
