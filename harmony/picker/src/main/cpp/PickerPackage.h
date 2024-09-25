#include "RNOH/Package.h"
#include "ComponentDescriptors.h"
#include "RTNPickerJSIBinder.h"
#include "RTNPickerNapiBinder.h"
#include "RTNPickerTurboModule.h"
#include "PickerEventEmitRequestHandler.h"

using namespace rnoh;
using namespace facebook;
class NativeRTNPickerFactoryDelegate : public TurboModuleFactoryDelegate {
  public:
    SharedTurboModule createTurboModule(Context ctx, const std::string &name) const override {
      if (name == "RNCPickerView") {
        return std::make_shared<RTNPickerTurboModule>(ctx, name);
      }
      return nullptr;
    }
};

namespace rnoh {
    class PickerPackage : public Package {
    public:
        PickerPackage(Package::Context ctx) : Package(ctx) {}
    
      std::unique_ptr<TurboModuleFactoryDelegate> createTurboModuleFactoryDelegate() override {
        return std::make_unique<NativeRTNPickerFactoryDelegate>();
      }
    
        std::vector<facebook::react::ComponentDescriptorProvider> createComponentDescriptorProviders() override {
            return {facebook::react::concreteComponentDescriptorProvider<
                facebook::react::RNCPickerViewComponentDescriptor>()};
        }

        ComponentNapiBinderByString createComponentNapiBinderByName() override {
            return {{"RNCPickerView", std::make_shared<RTNPickerNapiBinder>()}};
        }

        ComponentJSIBinderByString createComponentJSIBinderByName() override {
            return {{"RNCPickerView", std::make_shared<RTNPickerJSIBinder>()}};
        }
        EventEmitRequestHandlers createEventEmitRequestHandlers() override
    {
        return {std::make_shared<PickerEventEmitRequestHandler>()};
    }
    };
} // namespace rnoh
