#pragma once

#include <ReactCommon/TurboModule.h>
#include "RNOH/ArkTSTurboModule.h"

namespace rnoh {

class JSI_EXPORT RNCLogTurboModule : public ArkTSTurboModule {
  public:
    RNCLogTurboModule(const ArkTSTurboModule::Context ctx, const std::string name);
};

} // namespace rnoh
