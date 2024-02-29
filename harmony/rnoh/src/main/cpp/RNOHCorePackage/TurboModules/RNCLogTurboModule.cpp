// NOTE: This entire file should be codegen'ed.

#include "RNCLogTurboModule.h"
#include <react/renderer/uimanager/primitives.h>
#include <glog/logging.h>

using namespace rnoh;
using namespace facebook;

static jsi::Value __hostFunction_RNCLogTurboModule_Log(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count) {
    std::string logInfo = facebook::react::stringFromValue(rt, args[0]);
    LOG(INFO) << "LogTurboModule: " << logInfo;
    return jsi::Value::undefined();
}

RNCLogTurboModule::RNCLogTurboModule(const ArkTSTurboModule::Context ctx, const std::string name)
    : ArkTSTurboModule(ctx, name) {
    methodMap_["Log"] = MethodMetadata{1, __hostFunction_RNCLogTurboModule_Log};
}
