#pragma once

#include <ReactCommon/TurboModule.h>
#include "RNOH/ArkTSTurboModule.h"

namespace rnoh {

class JSI_EXPORT FrameRateLoggerTurboModule : public ArkTSTurboModule {
  public:
    FrameRateLoggerTurboModule(const ArkTSTurboModule::Context ctx, const std::string name);
};

} // namespace rnoh