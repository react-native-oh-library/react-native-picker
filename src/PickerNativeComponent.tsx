import type { ViewProps } from "react-native/Libraries/Components/View/ViewPropTypes";
import type { HostComponent} from "react-native";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";
import type {BubblingEventHandler,Int32} from "react-native/Libraries/Types/CodegenTypes";

export type OnPickerEventData = Readonly<{
    value: string,
    index: Int32
}>;

export interface PickerProps extends ViewProps {
isLoop?:boolean;
pickerConfirmBtnText?:string
pickerCancelBtnText?:string
pickerTitleText?:string
pickerFontFamily?: string
pickerTextEllipsisLen?:Int32
pickerToolBarFontSize?:Int32
pickerFontSize?:Int32
pickerRowHeight?:Int32
pickerConfirmBtnColor?:Int32[]
pickerCancelBtnColor?:Int32[]
pickerTitleColor?:Int32[]
pickerToolBarBg?:Int32[]
pickerBg?:Array<Int32>
wheelFlex?:Array<Int32>
pickerFontColor?:Int32[]
pickerData?:Array<any>
selectedValue?:Int32[]
onPickerConfirm?: BubblingEventHandler<OnPickerEventData>;
onPickerCancel?: BubblingEventHandler<OnPickerEventData>;
onPickerSelect?: BubblingEventHandler<OnPickerEventData>;
}

export default codegenNativeComponent<PickerProps>(
    'RNCPickerView',
) as HostComponent<PickerProps>; //必须要输出 HostComponent 对象