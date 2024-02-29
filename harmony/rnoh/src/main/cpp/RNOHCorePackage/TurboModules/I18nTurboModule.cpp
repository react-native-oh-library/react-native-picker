// NOTE: This entire file should be codegen'ed.

#include "I18nTurboModule.h"

using namespace rnoh;
using namespace facebook;

static jsi::Value __hostFunction_I18nTurboModule_allowRTL(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "allowRTL", args, count);
}

static jsi::Value __hostFunction_I18nTurboModule_forceRTL(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "forceRTL", args, count);
}

static jsi::Value __hostFunction_I18nTurboModule_swapLeftAndRightRTL(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "swapLeftAndRightRTL", args, count);
}

static jsi::Value __hostFunction_I18nTurboModule_getConstants(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "getConstants", args, count);
}

I18nTurboModule::I18nTurboModule(const ArkTSTurboModule::Context ctx, const std::string name)
    : ArkTSTurboModule(ctx, name) {
    methodMap_["allowRTL"] = MethodMetadata{0, __hostFunction_I18nTurboModule_allowRTL};
    methodMap_["forceRTL"] = MethodMetadata{0, __hostFunction_I18nTurboModule_forceRTL};
    methodMap_["swapLeftAndRightRTL"] = MethodMetadata{0, __hostFunction_I18nTurboModule_swapLeftAndRightRTL};
    methodMap_["getConstants"] = MethodMetadata{0, __hostFunction_I18nTurboModule_getConstants};
}