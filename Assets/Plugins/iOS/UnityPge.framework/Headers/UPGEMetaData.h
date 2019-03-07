#import "UPGEJsonStorage.h"

@interface UPGEMetaData : UPGEJsonStorage

@property (nonatomic, strong) NSString *category;

- (instancetype)initWithCategory:(NSString *)category;
- (BOOL)setRaw:(NSString *)key value:(id)value;
- (void)commit;

@end
