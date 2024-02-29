#include "RNOHCorePackage/ComponentBinders/ViewComponentNapiBinder.h"
#include "Props.h"

namespace rnoh {

class RTNPickerNapiBinder : public ViewComponentNapiBinder {
public:
    napi_value createProps(napi_env env, facebook::react::ShadowView const shadowView) override {
        napi_value napiViewProps = ViewComponentNapiBinder::createProps(env, shadowView);
        if (auto props = std::dynamic_pointer_cast<const facebook::react::RNCPickerViewProps>(shadowView.props)) {
            return ArkJS(env)
                .getObjectBuilder(napiViewProps)
                .addProperty("isLoop", props->isLoop)
                            .addProperty("pickerConfirmBtnText", props->pickerConfirmBtnText)
                .addProperty("pickerCancelBtnText", props->pickerCancelBtnText)
                .addProperty("pickerTitleText", props->pickerTitleText)
                            .addProperty("pickerFontFamily", props->pickerFontFamily)
                .addProperty("pickerRowHeight", props->pickerRowHeight)
                .addProperty("pickerTextEllipsisLen", props->pickerTextEllipsisLen)
                .addProperty("pickerToolBarFontSize", props->pickerToolBarFontSize)
                .addProperty("pickerFontSize", props->pickerFontSize)
                .addProperty("pickerConfirmBtnColor", props->pickerConfirmBtnColor)
                .addProperty("pickerCancelBtnColor", props->pickerCancelBtnColor)
                .addProperty("pickerTitleColor", props->pickerTitleColor)
                .addProperty("pickerToolBarBg", props->pickerToolBarBg)
                .addProperty("pickerBg", props->pickerBg)
                .addProperty("wheelFlex", props->wheelFlex)
                .addProperty("pickerFontColor", props->pickerFontColor)
                .addProperty("pickerData", props->pickerData)
                .addProperty("selectedValue", props->selectedValue)
            .build();
        }
        return napiViewProps;
    };
};
} //namespace rnoh