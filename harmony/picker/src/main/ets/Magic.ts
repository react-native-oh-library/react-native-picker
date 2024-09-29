export interface initOptions {
  pickerData: string[] | string[][] | ResultItem[] | undefined,
  onPickerConfirm: (event: string) => string,
  onPickerCancel: () => void,
  onPickerSelect: () => void,
  selectedValue: string | string[] | undefined,
  pickerCancelBtnText: string,
  isLoop: boolean,
  pickerTextEllipsisLen: number,
  pickerConfirmBtnText: string,
  pickerConfirmBtnColor: Array<number>,
  pickerTitleText: string,
  pickerCancelBtnColor: Array<number>,
  pickerTitleColor: Array<number>,
  pickerToolBarBg: Array<number>,
  pickerBg: Array<number>,
  pickerToolBarFontSize: number,
  wheelFlex: Array<number>,
  pickerFontSize: number,
  pickerFontColor: Array<number>,
  pickerFontFamily: string,
  pickerRowHeight: number,
}

export interface PickerTextStyle {
  color: string,
  font: FontStyle
}

export interface FontStyle {
  size: number;
}

export interface GlobalDialogParam {
  val:string | string[] | undefined;
}

export interface ResultItem {
  text: string;
  children: ResultItem[];
}

export const SELECTED: number = 1.1;

export const SIXTEEN: number = 16;

export const TWO: number = 2;

export const FIVE_PERCENT: string = '5%';

export const HUNDRED_PERCENT: string = '100%';

export const TWENTY_PERCENT: string = '20%';

export const THIRTY_PERCENT: string = '30%';

export const EVENT: string = 'pickerEvent';

export const CONFIRM: string = 'confirm';

export const CANCEL: string = 'cancel';

export const SELECT: string = 'select';

export const FALSE: boolean = false;

export const TRUE: boolean = true;
