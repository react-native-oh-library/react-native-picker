import { TurboModule, TurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { GlobalDialog } from './PickerBaseOperate';
import { initOptions } from './Magic';

export class RNCPickerTurboModule extends TurboModule {
  private pickerBaseOperate: GlobalDialog | null = null

  constructor(ctx: TurboModuleContext) {
    super(ctx);
    this.pickerBaseOperate = new GlobalDialog(ctx);
  }

  init(options: initOptions) {
    this.pickerBaseOperate?.init(options);
  }

  show() {
    if (this.pickerBaseOperate?.getContent()) {
      GlobalDialog.show();
    }
  }

  select(array: Array<string>) {
  }

  hide() {
    if (this.pickerBaseOperate?.getContent()) {
      GlobalDialog.close();
    }
  }

  isPickerShow() {
    let result = this.pickerBaseOperate?.getShowPicker();
    return result;
  }
}

