#import <Foundation/Foundation.h>

#import "UPGEQuestion.h"
#import "UPGEAnswerType.h"
#import "UPGEInitializeOptions.h"

@interface UnityPge : NSObject

+ (bool)isReady;

/**
 *  Initializes UnityPge. UnityPge should be initialized when app starts.
 *
 *  @param projectId Unity Project ID (UPID), generated for a project on operate dashboard
 */
+ (void)initialize:(NSString *)projectId;

/**
 *  Initializes UnityPge. UnityPge should be initialized when app starts.
 *
 *  @param projectId Unity Project ID (UPID), generated for a project on operate dashboard.
 *  @param options Pass options which include gdpr consent and user id.
 */
+ (void)initialize:(NSString *)projectId
    withOptions:(UPGEInitializeOptions *)options;

/**
 *  Get the current debug status of `UnityPge`.
 *
 *  @return If `YES`, `UnityPge` will provide verbose logs.
 */
+ (BOOL)getDebugMode;

/**
 *  Set the logging verbosity of `UnityPge`. Debug mode indicates verbose logging.
 *  @param enableDebugMode `YES` for verbose logging.
 */
+ (void)setDebugMode:(BOOL)enableDebugMode;

/**
 *  Check to see if the current device supports using Unity PGE.
 *
 *  @return If `NO`, the current device cannot initialize `UnityPge`.
 */
+ (BOOL)isSupported;

/**
 *  Check the version of this `UnityPge` SDK
 *
 *  @return String representing the current version name.
 */
+ (NSString *)getVersion;

/**
 *  Check that `UnityPge` has been initialized. This might be useful for debugging initialization problems.
 *
 *  @return If `YES`, Unity Pge has been successfully initialized.
 */
+ (BOOL)isInitialized;

/**
 * Create question
 * @param name The name of the questions. Needs to be unique
 * @param alternatives An array of strings
 * @param handler The answer handler block
 *
 * @return Returns the created question or nil if invalid arguments given
 */
+ (UPGEQuestion *)createQuestion:(NSString *)name alternatives:(NSArray *)alternatives handler:(UPGEAnswerHandlerBlock)handler;

/**
 * Create question
 * @param name The name of the questions. Needs to be unique
 * @param alternatives An array of strings
 * @param answerType enum of type UnityPgeAnswerType
 * @param handler The answer handler block
 *
 * @return Returns the created question or nil if invalid arguments given
 */
+ (UPGEQuestion *)createQuestion:(NSString *)name alternatives:(NSArray *)alternatives answerType:(UnityPgeAnswerType)answerType handler:(UPGEAnswerHandlerBlock)handler;

/**
 * Ask questions which takes a variable amount of questions as arguments.
 */
+ (void)askQuestions:(UPGEQuestion *)question, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Ask questions which takes an array of questions as arguments.
 */
+ (void)askQuestionsWithArray:(NSArray *)questions;

+ (void)rewardEvent:(NSString *)eventName;

+ (void)rewardEvent:(NSString *)eventName withAttributes:(NSDictionary *)eventAttributes;

+ (void)setUserAttributes:(NSDictionary *)userAttributes;

+ (void)setUserAttribute:(id)value forKey:(NSString *)key;

+ (void)setGdprConsent:(BOOL)gdprConsent;

@end
