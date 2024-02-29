#include "RNOHCorePackage/TurboModules/FrameRateLoggerTurboModule.h"

using namespace rnoh;
using namespace facebook;

static jsi::Value __hostFunction_FrameRateLoggerTurboModule_beginScroll(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "beginScroll", args, count);
}

static jsi::Value __hostFunction_FrameRateLoggerTurboModule_endScroll(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "endScroll", args, count);
}

static jsi::Value __hostFunction_FrameRateLoggerTurboModule_setContext(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "setContext", args, count);
}

static jsi::Value __hostFunction_FrameRateLoggerTurboModule_setGlobalOptions(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "setGlobalOptions", args, count);
}


FrameRateLoggerTurboModule::FrameRateLoggerTurboModule(const ArkTSTurboModule::Context ctx, 
                const std::string name) : ArkTSTurboModule(ctx, name) {
    methodMap_ = {
        {"beginScroll", {0, __hostFunction_FrameRateLoggerTurboModule_beginScroll}},
        {"endScroll", {0, __hostFunction_FrameRateLoggerTurboModule_endScroll}},
        {"setContext", {1, __hostFunction_FrameRateLoggerTurboModule_setContext}},
        {"setGlobalOptions", {1, __hostFunction_FrameRateLoggerTurboModule_setGlobalOptions}},
    };
}