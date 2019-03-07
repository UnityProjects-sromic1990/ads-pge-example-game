#import "UPGEAnswer.h"
#import "UPGEAnswerType.h"

typedef void (^UPGEAnswerHandlerBlock)(UPGEAnswer *answer);

@interface UPGEQuestion : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSMutableArray *alternatives;
@property (nonatomic) UnityPgeAnswerType answerType;
@property (copy, readonly) UPGEAnswerHandlerBlock handler;

- (NSDictionary *)getJSON;

- (UPGEAnswer *)getDefaultAnswer;

- (void)use:(NSString *)chosenAlternative;

@end
