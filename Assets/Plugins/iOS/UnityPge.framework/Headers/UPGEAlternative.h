@interface UPGEAlternative : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *attributes;

- (UPGEAlternative *)initWithName:(NSString *)name;

- (UPGEAlternative *)initWithName:(NSString *)name andAttributes:(NSDictionary *)attributes;

- (NSDictionary *)getJSON;

- (void)addAttribute:(id)value forKey:(NSString *)key;

@end
