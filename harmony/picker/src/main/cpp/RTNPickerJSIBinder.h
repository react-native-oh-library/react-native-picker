#include "RNOHCorePackage/ComponentBinders/ViewComponentJSIBinder.h"

namespace rnoh {

class RTNPickerJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "isLoop", "boolean");
        object.setProperty(rt, "pickerTextEllipsisLen", "number");
        object.setProperty(rt, "pickerConfirmBtnText", "string");
        object.setProperty(rt, "pickerCancelBtnText", "string");
        object.setProperty(rt, "pickerTitleText", "string");
        object.setProperty(rt, "pickerConfirmBtnColor", "Array<number>");
        object.setProperty(rt, "pickerCancelBtnColor", "Array<number>");
        object.setProperty(rt, "pickerTitleColor", "Array<number>");
        object.setProperty(rt, "pickerToolBarBg", "Array<number>");
        object.setProperty(rt, "pickerBg", "Array<number>");
        object.setProperty(rt, "pickerToolBarFontSize", "number");
        object.setProperty(rt, "wheelFlex", "Array<number>");
        object.setProperty(rt, "pickerFontSize", "number");
        object.setProperty(rt, "pickerFontColor", "Array<number>");
        object.setProperty(rt, "pickerFontFamily", "string");
        object.setProperty(rt, "pickerRowHeight", "number");
        object.setProperty(rt, "pickerData", "Array<any>");
        object.setProperty(rt, "selectedValue", "Array<number>");
        return object;
    }
    
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override
        {
           // LOG(INFO) << "RNOH　datetimepicker:createBubblingEventTypes";
            facebook::jsi::Object events(rt);
            events.setProperty(rt,"topPickerConfirm",createBubblingCapturedEvent(rt,"onPickerConfirm"));
            events.setProperty(rt,"topPickerCancel",createBubblingCapturedEvent(rt,"onPickerCancel"));
            events.setProperty(rt,"topPickerSelect",createBubblingCapturedEvent(rt,"onPickerSelect"));
            return events;
        }
    };
} // namespace rnoh