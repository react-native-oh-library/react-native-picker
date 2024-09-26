#include "RTNPickerTurboModule.h"
#include "RNOH/ArkTSTurboModule.h"

using namespace rnoh;
using namespace facebook;

static jsi::Value __hostFunction_RTNPickerTurboModule_init(jsi::Runtime &rt, react::TurboModule &turboModule, const jsi::Value *args, size_t count) {
  return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "init", args, count);
}
static jsi::Value __hostFunction_RTNPickerTurboModule_toggle(jsi::Runtime &rt, react::TurboModule &turboModule, const jsi::Value *args, size_t count) {
  return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "toggle", args, count);
}
static jsi::Value __hostFunction_RTNPickerTurboModule_show(jsi::Runtime &rt, react::TurboModule &turboModule, const jsi::Value *args, size_t count) {
  return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "show", args, count);
}
static jsi::Value __hostFunction_RTNPickerTurboModule_hide(jsi::Runtime &rt, react::TurboModule &turboModule, const jsi::Value *args, size_t count) {
  return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "hide", args, count);
}
static jsi::Value __hostFunction_RTNPickerTurboModule_select(jsi::Runtime &rt, react::TurboModule &turboModule, const jsi::Value *args, size_t count) {
  return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "select", args, count);
}
static jsi::Value __hostFunction_RTNPickerTurboModule_isPickerShow(jsi::Runtime &rt, react::TurboModule &turboModule, const jsi::Value *args, size_t count) {
  return static_cast<ArkTSTurboModule &>(turboModule).call(rt, "isPickerShow", args, count);
}

RTNPickerTurboModule::RTNPickerTurboModule(const ArkTSTurboModule::Context ctx, const std::string name): ArkTSTurboModule(ctx, name) {
    methodMap_["init"] = MethodMetadata{1, __hostFunction_RTNPickerTurboModule_init};
    methodMap_["toggle"] = MethodMetadata{0, __hostFunction_RTNPickerTurboModule_toggle};
    methodMap_["show"] = MethodMetadata{0, __hostFunction_RTNPickerTurboModule_show};
    methodMap_["hide"] = MethodMetadata{0, __hostFunction_RTNPickerTurboModule_hide};
    methodMap_["select"] = MethodMetadata{1, __hostFunction_RTNPickerTurboModule_select};
    methodMap_["isPickerShow"] = MethodMetadata{1, __hostFunction_RTNPickerTurboModule_isPickerShow};
}






