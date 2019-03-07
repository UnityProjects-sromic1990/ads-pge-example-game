#import "UnityAppController.h"
#import "Unity/UnityInterface.h"

#import "UnityPge/UnityPge.h"
#import "UnityPge/UPGEMetaData.h"

#include <string>
#include <vector>
#include <map>
#include <memory>

struct PGEAlternative
{
    std::string name;
    std::vector<std::pair<std::string, std::string>> attributes;

    explicit PGEAlternative(const char *_name): name(_name) {}
};


struct PGEAnswer
{
    std::string identifier;
    std::string name;
    std::string type;
    PGEAlternative chosenAlternative;

    PGEAnswer(const char *_identifier, const char *_name, const char *_type, PGEAlternative _chosenAlternative): identifier(_identifier), name(_name), type(_type), chosenAlternative(_chosenAlternative) {};
};

struct PGEQuestion
{
    std::string name;
    std::string answerType;
    std::vector<PGEAlternative> alternatives;

    PGEQuestion(const char *_name, const char *_answerType): name(_name), answerType(_answerType) {};
};

struct PGEQuestionRequest
{
    std::vector<PGEQuestion> questions;
};

struct PGEReward
{
    std::string name;
    std::vector<std::pair<std::string, std::string>> attributes;

    explicit PGEReward(const char *_name): name(_name) {}
};

extern "C" {

    const char *UnityPgeCopyString(const char *string) {
        char *copy = (char *)malloc(strlen(string) + 1);
        strcpy(copy, string);
        return copy;
    }

    typedef void (*UnityPgeAnswerCallback)(const char *identifier, const char *name, const char *treatmentGroup, const char *signature, const char *alternativeName);

    static UnityPgeAnswerCallback answerCallback = NULL;

    static NSMutableDictionary *_questions;
}

extern "C" {

    PGEReward *UnityPgeMakeReward(const char *name)
    {
        return new PGEReward(name);
    }

    void UnityPgeDeleteReward(PGEReward *reward)
    {
        delete reward;
    }

    void UnityPgeAddAttributeToReward(PGEReward *reward, const char *name, const char *value)
    {
        reward->attributes.push_back(std::make_pair(name, value));
    }

    void UnityPgeSendRewardEvent(PGEReward *reward)
    {
        NSMutableDictionary *rewardEventAttributes = [[NSMutableDictionary alloc] init];

        for (const auto& rawAttribute: reward->attributes)
        {
            const char *attributeName = rawAttribute.first.c_str();
            const char *attributeValue = rawAttribute.second.c_str();
            [rewardEventAttributes setObject:[NSString stringWithUTF8String:attributeValue] forKey:[NSString stringWithUTF8String:attributeName]];
        }

        [UnityPge rewardEvent:[NSString stringWithUTF8String:reward->name.c_str()] withAttributes:rewardEventAttributes];
    }

    PGEQuestionRequest *UnityPgeMakeQuestionRequest()
    {
        return new PGEQuestionRequest();
    }

    void UnityPgeDeleteQuestionRequest(PGEQuestionRequest *qRequest)
    {
        delete qRequest;
    }

    void UnityPgeAddQuestion(PGEQuestionRequest *qRequest, const char *name, const char *answerType)
    {
        qRequest->questions.push_back(PGEQuestion(name, answerType));
    }

    void UnityPgeAddAlternativeToLastQuestion(PGEQuestionRequest *qRequest, const char *name)
    {
        qRequest->questions.back().alternatives.push_back(PGEAlternative(name));
    }

    void UnityPgeAddAttributesToLastAlternative(PGEQuestionRequest *qRequest, const char *name, const char *value)
    {
        qRequest->questions.back().alternatives.back().attributes.push_back(std::make_pair(name, value));
    }

    void UnityPgeInitialize(const char *projectId, const char *userId, const char *gdprConsent, int timeout, bool testMode) {
        NSString *consent = [NSString stringWithUTF8String:gdprConsent];
        NSString *externalUserId = [NSString stringWithUTF8String:userId];
        UPGEInitializeOptions *options = [[UPGEInitializeOptions alloc] init];

        if (![consent isEqualToString:@"none"]) {
            [options setGdprConsent:[consent isEqualToString:@"given"]];
        }

        [options setUserId:externalUserId];
        [options setAskQuestionsTimeout:timeout];
        [options setTestMode:testMode];

        [UnityPge initialize:[NSString stringWithUTF8String:projectId] withOptions:options];

    }

    bool UnityPgeGetDebugMode() {
        return [UnityPge getDebugMode];
    }

    void UnityPgeSetDebugMode(bool debugMode) {
        [UnityPge setDebugMode:debugMode];
    }

    bool UnityPgeIsSupported() {
        return [UnityPge isSupported];
    }

    bool UnityPgeIsReady() {
        return [UnityPge isReady];
    }

    const char * UnityPgeGetVersion() {
        return UnityPgeCopyString([[UnityPge getVersion] UTF8String]);
    }

    bool UnityPgeIsInitialized() {
        return [UnityPge isInitialized];
    }

    void UnityPgeSetMetaData(const char *category, const char * data) {
        if(category != NULL && data != NULL) {
            UPGEMetaData *metaData = [[UPGEMetaData alloc] initWithCategory:[NSString stringWithUTF8String:category]];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithUTF8String:data] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            for(id key in json) {
                [metaData set:key value:[json objectForKey:key]];
            }
            [metaData commit];
        }
    }

    void UnityPgeSetAnswerCallback(UnityPgeAnswerCallback callback) {
        answerCallback = callback;
    }

    void UnityPgeAskQuestions(PGEQuestionRequest *request) {
        size_t requestSize = request->questions.size();
        NSMutableArray *questionsArray = [[NSMutableArray alloc] initWithCapacity:requestSize];

        for (const auto& rawQuestion: request->questions)
        {
            const char *questionName = rawQuestion.name.c_str();
            const char *answerType = rawQuestion.answerType.c_str();
            size_t alternativesSize = rawQuestion.alternatives.size();
            NSMutableArray *alternativesArray = [[NSMutableArray alloc] initWithCapacity:alternativesSize];

            for (const auto& rawAlternative: rawQuestion.alternatives)
            {
                const char *rawAlternativeName = rawAlternative.name.c_str();
                UPGEAlternative *alternative = [[UPGEAlternative alloc] initWithName:[NSString stringWithUTF8String:rawAlternativeName]];

                for (const auto& rawAttributePair: rawAlternative.attributes)
                {
                    const char *rawAttributeName = rawAttributePair.first.c_str();
                    const char *rawAttributeValue = rawAttributePair.second.c_str();
                    [alternative addAttribute:[NSString stringWithUTF8String:rawAttributeValue] forKey:[NSString stringWithUTF8String:rawAttributeName]];
                }

                [alternativesArray addObject:alternative];
            }

            UnityPgeAnswerType type;
            type = kUnityPgeAnswerTypeNewUntilUsed;
            if (strcmp(answerType, "ALWAYS_NEW") == 0) {
                type = kUnityPgeAnswerTypeAlwaysNew;
            }

            UPGEQuestion *question = [UnityPge createQuestion:[NSString stringWithUTF8String:questionName] alternatives:alternativesArray answerType:type handler:^(UPGEAnswer *answer) {
                const char *answerId = [answer.identifier UTF8String];
                const char *answerName = [answer.name UTF8String];
                const char *treatmentGroup = [answer.treatmentGroup UTF8String];
                const char *signature = [answer.signature UTF8String];
                const char *alternativeName = [answer.chosenAlternative.name UTF8String];
                answerCallback(answerId, answerName, treatmentGroup, signature, alternativeName);
            }];

            [questionsArray addObject:question];
        }

        [UnityPge askQuestionsWithArray:questionsArray];
    }

    void UnityPgeUse(const char *answerId, const char *questionName, const char *chosenAlternativeName) {
        if (strlen(answerId) == 0) {
            // create dummy question to send Use event
            UPGEQuestion *dummyQuestion = [UnityPge createQuestion:[NSString stringWithUTF8String:questionName] alternatives:@[@"dummy1", @"dummy2"] handler:^(UPGEAnswer *answer) {}];
            [dummyQuestion use:[NSString stringWithUTF8String:chosenAlternativeName]];
            return;
        }

        UPGEAlternative *chosenAlternative = [[UPGEAlternative alloc] initWithName:[NSString stringWithUTF8String:chosenAlternativeName]];
        UPGEAnswer *answer = [[UPGEAnswer alloc] initWithIdentifier:[NSString stringWithUTF8String:answerId] name:[NSString stringWithUTF8String:questionName] group:@"" chosenAlternative:chosenAlternative signature:@""];
        [answer use];
    }

    void UnityPgeSetUserAttribute(const char *name, const char *value) {
        [UnityPge setUserAttribute:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:name]];
    }

    void UnityPgeSetGdprConsent(bool consent) {
        [UnityPge setGdprConsent:consent? YES: NO];
    }
}
