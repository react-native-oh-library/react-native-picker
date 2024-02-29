import {TurboModule,TurboModuleContext, ReactModalHostView} from 'rnoh/ts';

export type Options = {
  isLoop?:boolean;
  pickerData?:Array<any>;
}

export class RNCPickerViewTurboModule extends TurboModule {

  // private imageKnife:ImageKnife;
  constructor(protected ctx: TurboModuleContext) {
    super(ctx);
    console.log('[RNOH]:RNCPickerViewTurboModule constructor');
  }

  init(options: Options) : Promise<void>{
    return new Promise<void>((resolve, reject) => {
      console.log('[RNOH]:RNCPickerViewTurboModule call preload', JSON.stringify(options));
      resolve()
    });
  }

  toggle(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      console.log('[RNOH]:RNCPickerViewTurboModule call toggle');
      resolve()
    });
  }
  show(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      console.log('[RNOH]:RNCPickerViewTurboModule call show');
      resolve()
    });
  }
  hide() : Promise<void>{
    return new Promise<void>((resolve, reject) => {
      console.log('[RNOH]:RNCPickerViewTurboModule call hide');
      resolve()
    });
  }
  select(array:Array<string>): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      console.log('[RNOH]:RNCPickerViewTurboModule call select',JSON.stringify(array));
      resolve()
    });
  }
  isPickerShow(callback:()=>{}): Promise<void>{
    return new Promise<void>((resolve, reject) => {

      console.log('[RNOH]:RNCPickerViewTurboModule call isPickerShow');
      resolve()
    });
  }
}