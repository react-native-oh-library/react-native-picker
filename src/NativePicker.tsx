import type { TurboModule } from "react-native/Libraries/TurboModule/RCTExport";
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {

  init:() => void;
  toggle: () => void;
  show: () => void;
  hide: () => void;
  select: (array:Array<any>) => void;
  isPickerShow: () => boolean;
}

export default TurboModuleRegistry.get<Spec>("RNCPickerView") as Spec;

