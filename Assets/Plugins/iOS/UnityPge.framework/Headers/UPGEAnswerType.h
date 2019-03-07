typedef NS_ENUM (NSInteger, UnityPgeAnswerType) {
    kUnityPgeAnswerTypeAlwaysNew,
    kUnityPgeAnswerTypeNewUntilUsed
};

@interface UPGEAnswerType : NSObject

+ (NSString *)stringFromAnswerType:(UnityPgeAnswerType)answerType;

@end
