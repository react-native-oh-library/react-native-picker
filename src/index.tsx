import {View} from "react-native";
import type { PickerProps } from "./PickerNativeComponent";
import PickerView from "./PickerNativeComponent"
import { forwardRef, memo } from "react";
import React from "react";
import type { Options } from "./NativePicker";
import RNCPickerView from "./NativePicker";



function PickerBase({
  ...props
}: PickerProps & { forwardedRef: React.Ref<any> }) {
  return (
      <View>
          <PickerView
              {...props}
          />
      </View>
  )
}

const PickerMemo = memo(PickerBase)

const PickerComponent: React.ComponentType<PickerProps> = forwardRef(
  (props: PickerProps, ref: React.Ref<any>) => (
      <PickerMemo forwardedRef={ref} {...props} />
  ),
)

PickerComponent.displayName = 'Picker'

export interface PickerStaticProperties {
  init: (options: Options ) => Promise<void>;
  toggle: () => Promise<void>;
  show: () => Promise<void>;
  hide: () => Promise<void>;
  select: (array:Array<any>) => Promise<void>;
  isPickerShow: (callback:(status:boolean)=>void) => Promise<void>;
}

const Picker: React.ComponentType<PickerProps> &
PickerStaticProperties = PickerComponent as any

Picker.init = (options: Options) => RNCPickerView.init(options)
 Picker.toggle = () => RNCPickerView.toggle()
Picker.show = () => RNCPickerView.show()
Picker.hide = () => RNCPickerView.hide()
Picker.select = (array:Array<any>) => RNCPickerView.select(array)
Picker.isPickerShow = (callback:(status:boolean)=>void) => RNCPickerView.isPickerShow(callback)
export default Picker