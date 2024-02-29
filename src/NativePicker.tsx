import type { TurboModule } from "react-native/Libraries/TurboModule/RCTExport";
import { TurboModuleRegistry } from 'react-native';
export type Options = {
  isLoop?:boolean;
    pickerData?:Array<any>;
}

export interface Spec extends TurboModule {
  init:(options: Options) => Promise<void>;
  toggle: () => Promise<void>;
  show: () => Promise<void>;
  hide: () => Promise<void>;
  select: (array:Array<any>) => Promise<void>;
  isPickerShow: (callback:(status:boolean)=>void) => Promise<void>;
}

export default TurboModuleRegistry.get<Spec>("RNCPickerView") as Spec | null;

