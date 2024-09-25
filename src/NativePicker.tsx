import type { TurboModule } from "react-native/Libraries/TurboModule/RCTExport";
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {

  init:() => Promise<void>;
  toggle: () => Promise<void>;
  show: () => Promise<void>;
  hide: () => Promise<void>;
  select: (array:Array<any>) => Promise<void>;
  isPickerShow: () => Promise<void>;
}

export default TurboModuleRegistry.get<Spec>("RNCPickerView") as Spec;

