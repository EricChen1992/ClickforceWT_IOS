#import <Foundation/Foundation.h>

@interface ParsJson : NSObject
{
    NSDictionary *jsonvalue;
}
- (id) initWithValue:(NSData *) json;
- (id)initWithNSDictionary:(NSDictionary *) dic;

- (int)status;
- (NSString *)msg;
- (int)userId;
- (NSString *)userName;
- (NSArray *)userEmail;
- (int)result;
- (NSString *)type;
- (NSString *)date;
- (NSString *)clockin;
- (NSString *)clockout;
- (NSArray *)item;
@end
