
/**
 * This code was generated by [react-native-codegen](https://www.npmjs.com/package/react-native-codegen).
 *
 * Do not edit this file as changes may cause incorrect behavior and will be lost
 * once the code is regenerated.
 *
 * @generated by codegen project: GenerateModuleJniCpp.js
 */

#include "DevSplitBundleLoaderTurboModule.h"

using namespace rnoh;
using namespace facebook;

static jsi::Value __hostFunction_DevSplitBundleLoaderTurboModule_loadBundle(jsi::Runtime& rt, react::TurboModule &turboModule, const jsi::Value* args, size_t count) {
  return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "loadBundle", args, count);
}

DevSplitBundleLoaderTurboModule::DevSplitBundleLoaderTurboModule(const ArkTSTurboModule::Context ctx, const std::string name)
  : ArkTSTurboModule(ctx, name) {
  methodMap_["loadBundle"] = MethodMetadata {1, __hostFunction_DevSplitBundleLoaderTurboModule_loadBundle};
}
