#import "UPGEAlternative.h"

@interface UPGEAnswer : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *treatmentGroup;
@property (nonatomic, strong, readonly) UPGEAlternative *chosenAlternative;
@property (nonatomic, strong, readonly) NSString *signature;

- (UPGEAnswer *)initWithIdentifier:(NSString *)identifier name:(NSString *)name group:(NSString *)treatmentGroup chosenAlternative:(UPGEAlternative *)chosenAlternative signature:(NSString *)signature;

- (void)use;

@end
