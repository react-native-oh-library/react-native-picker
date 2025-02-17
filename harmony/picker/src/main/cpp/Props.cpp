
/**
 * This code was generated by [react-native-codegen](https://www.npmjs.com/package/react-native-codegen).
 *
 * Do not edit this file as changes may cause incorrect behavior and will be lost
 * once the code is regenerated.
 *
 * @generated by codegen project: GeneratePropsCpp.js
 */

#include "Props.h"
#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/core/propsConversions.h>

namespace facebook {
namespace react {

    RNCPickerViewProps::RNCPickerViewProps(const PropsParserContext &context, const RNCPickerViewProps &sourceProps,
                                           const RawProps &rawProps)
        : ViewProps(context, sourceProps, rawProps),

          isLoop(convertRawProp(context, rawProps, "isLoop", sourceProps.isLoop, {false})),

          pickerConfirmBtnText(
              convertRawProp(context, rawProps, "pickerConfirmBtnText", sourceProps.pickerConfirmBtnText, {})),
          pickerCancelBtnText(
              convertRawProp(context, rawProps, "pickerCancelBtnText", sourceProps.pickerCancelBtnText, {})),
          pickerTitleText(convertRawProp(context, rawProps, "pickerTitleText", sourceProps.pickerTitleText, {})),
          pickerFontFamily(convertRawProp(context, rawProps, "pickerFontFamily", sourceProps.pickerFontFamily, {})),
          pickerFontSize(convertRawProp(context, rawProps, "pickerFontSize", sourceProps.pickerFontSize, {0})),
          pickerTextEllipsisLen(
              convertRawProp(context, rawProps, "pickerTextEllipsisLen", sourceProps.pickerTextEllipsisLen, {0})),
              pickerToolBarFontSize(
                  convertRawProp(context, rawProps, "pickerToolBarFontSize", sourceProps.pickerToolBarFontSize,{0})),
                 pickerRowHeight(convertRawProp(context, rawProps, "pickerRowHeight", sourceProps.pickerRowHeight,{0})),
              pickerConfirmBtnColor(
                  convertRawProp(context, rawProps, "pickerConfirmBtnColor", sourceProps.pickerConfirmBtnColor, {})),
              pickerCancelBtnColor(
                  convertRawProp(context, rawProps, "pickerCancelBtnColor", sourceProps.pickerCancelBtnColor, {})),
              pickerTitleColor(convertRawProp(context, rawProps, "pickerTitleColor", sourceProps.pickerTitleColor,
              {})), pickerToolBarBg(convertRawProp(context, rawProps, "pickerToolBarBg", sourceProps.pickerToolBarBg,
              {})), pickerBg(convertRawProp(context, rawProps, "pickerBg", sourceProps.pickerBg, {})),
              wheelFlex(convertRawProp(context, rawProps, "wheelFlex", sourceProps.wheelFlex, {})),
              pickerFontColor(convertRawProp(context, rawProps, "pickerFontColor", sourceProps.pickerFontColor, {})),
                pickerData(convertRawProp(context, rawProps, "pickerData", sourceProps.pickerData, {})),
              selectedValue(convertRawProp(context, rawProps, "selectedValue", sourceProps.selectedValue, {}))
    {}

} // namespace react
} // namespace facebook
