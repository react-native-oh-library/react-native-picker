import { ComponentContent, window } from '@kit.ArkUI';
import { TurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import {
  initOptions,
  PickerTextStyle,
  SELECTED,
  GlobalDialogParam,
  ResultItem,
  SIXTEEN,
  TWO,
  FIVE_PERCENT,
  HUNDRED_PERCENT,
  TWENTY_PERCENT,
  THIRTY_PERCENT,
  EVENT,
  CONFIRM,
  CANCEL,
  SELECT,
  FALSE,
  TRUE
} from './Magic';

import Logger from './Logger';

export const TAG = "Picker";

@Builder
function buildGlobalDialogComponent(params: Params) {
  Column() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text(content.pickerCancelBtnText)
        .fontSize(content.pickerToolBarFontSize)
        .fontColor(GlobalDialog.rgbArrayToHex(content.pickerCancelBtnColor))
        .width(TWENTY_PERCENT)
        .textAlign(TextAlign.End)
        .onClick(() => {
          cancelClick();
        })
      Text(content.pickerTitleText)
        .fontSize(content.pickerToolBarFontSize)
        .fontColor(GlobalDialog.rgbArrayToHex(content.pickerTitleColor))
        .width(TWENTY_PERCENT)
        .textAlign(TextAlign.Center)
      Text(content.pickerConfirmBtnText)
        .fontSize(content.pickerToolBarFontSize)
        .fontColor(GlobalDialog.rgbArrayToHex(content.pickerConfirmBtnColor))
        .width(TWENTY_PERCENT)
        .textAlign(TextAlign.Start)
        .onClick(() => {
          confirmClick();
        })
    }
    .backgroundColor(GlobalDialog.rgbArrayToHex(content.pickerToolBarBg))
    .height(FIVE_PERCENT)
    .width(HUNDRED_PERCENT)

    TextPicker({ range: content.pickerData, value: params.selected })
      .onChange((value: string | string[], index: number | number[]) => {
        changeSelect(value, index);
      })
      .canLoop(content.isLoop)
      .height(THIRTY_PERCENT)
      .width(HUNDRED_PERCENT)
      .disappearTextStyle(GlobalDialog.getTextStyle(FALSE))
      .textStyle(GlobalDialog.getTextStyle(FALSE))
      .selectedTextStyle(GlobalDialog.getTextStyle(TRUE))
      .defaultPickerItemHeight(content.pickerRowHeight)
      .backgroundColor(GlobalDialog.rgbArrayToHex(content.pickerBg))
  }
}

function cancelClick() {
  try {
    InitializeIndex();
    const valArr =  JSON.stringify(Array.isArray(defaultValue)? defaultValue : [defaultValue]);
    const indexArr = JSON.stringify(Array.isArray(selectIndex)? selectIndex:[selectIndex]);
    pickerCtx.rnInstance.emitDeviceEvent(EVENT, { type: CANCEL, selectedValue: valArr, selectedIndex: indexArr });
    GlobalDialog.close();
    content.pickerData = undefined;
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] cancelClick failed ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

function confirmClick() {
  try {
    InitializeIndex();
    const valArr =  JSON.stringify(Array.isArray(defaultValue)? defaultValue : [defaultValue]);
    const indexArr = JSON.stringify(Array.isArray(selectIndex)? selectIndex:[selectIndex]);
    pickerCtx.rnInstance.emitDeviceEvent(EVENT, { type: CONFIRM, selectedValue: valArr, selectedIndex: indexArr });
    GlobalDialog.close();
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] confirmClick failed ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

function changeSelect(val: string | string[], index: number | number[]) {
  try {
    const valArr = Array.isArray(val)? JSON.stringify(val) : JSON.stringify([val]);
    const indexArr = Array.isArray(val)? JSON.stringify(index) : JSON.stringify([index]);
    pickerCtx.rnInstance.emitDeviceEvent(EVENT, { type: SELECT, selectedValue: valArr, selectedIndex: indexArr });
    defaultValue = val;
    selectIndex = index as number[];
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] changeSelect failed ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

function InitializeIndex() {
  if(defaultValue) {
    if(!selectIndex[0]) {
      selectIndex = [];
      if (resource.every(item => Array.isArray(item))) {
        resource.forEach((item: string[] | number[], index: number) => {
          item.forEach((item: string | number, i: number) => {
            if(defaultValue !== undefined && defaultValue[index] == item) {
              selectIndex.push(i);
            }
          })
        })
      } else {
        haveSelectedValue(resource);
        counter = 0;
      }
    }
  } else {
    if(!selectIndex[0]) {
      selectIndex = [];
      resultArr = [];
      if (resource.every(item => Array.isArray(item))) {
        resource.forEach((item: string[] | number[]) => {
          selectIndex.push(0);
          resultArr.push(item[0] + '');
        })
      } else {
        find(resource);
      }
    }
    defaultValue = resultArr;
  }
}


function haveSelectedValue(data: object[]) {
  try {
    data.map((item: object, i: number) => {
      if (typeof item !== 'object') {
        if(defaultValue !== undefined && defaultValue[counter] == item) {
          selectIndex.push(i);
        }
      } else {
        if (!Array.isArray(item)) {
          let keys: string[] = Object.keys(item);
          if(defaultValue !== undefined && defaultValue[counter] == keys[0]) {
            selectIndex.push(i);
            counter++;
            let values: Array<object> = item[keys[0]];
            if (Array.isArray(values)) {
              haveSelectedValue(values);
            }
          }
        }
      }
    });
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] find ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

function find(data: object[]) {
  try {
    data.map((item: object, i: number) => {
      if (typeof item !== 'object') {
        if(i === 0) {
          resultArr.push(item + '');
          selectIndex.push(0);
        }
      } else {
        if (!Array.isArray(item) && i === 0) {
          let keys: string[] = Object.keys(item);
          resultArr.push(keys[0] + '');
          selectIndex.push(0);
          let values: Array<object> = item[keys[0]];
          if (Array.isArray(values)) {
            find(values);
          }
        }
      }
    });
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] find ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

let content: initOptions;
let pickerCtx: TurboModuleContext;
let uiContext: UIContext;
let showPicker: boolean = false;
let selectIndex: number[];
let resultArr: string[];
let resource: [];
let counter: number = 0;
let defaultValue: string | string[] | undefined;

class Params {
  selected: string | string[] = '';

  constructor(selected: string | string[]) {
    this.selected = selected;
  }
}

export class GlobalDialog {
  static contentNode: ComponentContent<GlobalDialogParam>;
  protected ctx: TurboModuleContext;

  constructor(ctx: TurboModuleContext) {
    this.ctx = ctx;
    pickerCtx = ctx;
    window.getLastWindow(this.ctx.uiAbilityContext)
      .then((value) => {
        uiContext = value.getUIContext();
      })
  }

  static show() {
    try {
      GlobalDialog.contentNode =
        new ComponentContent(uiContext, wrapBuilder(buildGlobalDialogComponent),
          new Params(defaultValue ?? ''));
      const promptAction = uiContext.getPromptAction();
      promptAction.openCustomDialog(GlobalDialog.contentNode, {
        alignment: DialogAlignment.Bottom,
        autoCancel: false,
      });
      showPicker = true;
    } catch (error) {
      Logger.error(TAG,
        `[RNOH] GlobalDialog show ErrorCode: ${error.code},  Message: ${error.message}`);
    }
  }

  static close() {
    try {
      const promptAction = uiContext.getPromptAction();
      promptAction.closeCustomDialog(GlobalDialog.contentNode);
      showPicker = false;
    } catch (error) {
      Logger.error(TAG,
        `[RNOH] GlobalDialog close ErrorCode: ${error.code},  Message: ${error.message}`);
    }
  }

  init(options: initOptions) {
    content = options;
    this.processSelectedValue();
  }

  getShowPicker(): boolean {
    return showPicker;
  }

  getContent(): initOptions {
    return content;
  }

  update(array: Array<string>) {
    defaultValue = array;
    GlobalDialog.contentNode.update(new Params(defaultValue));
  }

  processData(data: object[]): ResultItem[] {
    try {
      const result = data.map((item: object) => {
        let resultItem: ResultItem = {
          text: '',
          children: []
        };
        if (typeof item !== 'object') {
          resultItem = {
            text: item + '',
            children: []
          }
        } else {
          if (!Array.isArray(item)) {
            let keys: string[] = Object.keys(item);
            resultItem = {
              text: keys[0] + '',
              children: [],
            };
            let values: Array<object> = item[keys[0]];
            if (Array.isArray(values)) {
              resultItem.children = this.processData(values);
            }
          }
        }
        return resultItem;
      });
      return result;
    } catch (error) {
      Logger.error(TAG,
        `[RNOH] GlobalDialog processData ErrorCode: ${error.code},  Message: ${error.message}`);
      return error.message;
    }
  }

  processSelectedValue() {
    try {
      resource = content.pickerData as [];
      selectIndex = [];
      let data = content.pickerData as [];
      if (data.every(item => Array.isArray(item))) {
        content.pickerData = data.map((item: string[] | number[]) => {
          return item.map((i: string | number) => {
            return i + '';
          });
        })
      } else {
        content.pickerData = this.processData(data);
      }
      if (!Array.isArray(content.selectedValue)) {
        defaultValue = content.selectedValue?.toString();
      } else {
        defaultValue = content.selectedValue.map(item => {
          return item.toString();
        })
      }
    } catch (error) {
      Logger.error(TAG,
        `[RNOH] GlobalDialog processSelectedValue ErrorCode: ${error.code},  Message: ${error.message}`);
    }
  }

  static getTextStyle(isSelected: boolean): PickerTextStyle {
    return {
      color: GlobalDialog.rgbArrayToHex(content.pickerFontColor),
      font: {
        size: isSelected ? content.pickerFontSize * SELECTED : content.pickerFontSize
      },
    }
  }

  static rgbArrayToHex(rgb: number[]): string {
    try {
      if (rgb.length > 3) {
        rgb.pop();
      }
      const hexColor = rgb.map((channel: number) => {
        const hexChannel = channel.toString(SIXTEEN).toUpperCase().padStart(TWO, '0');
        return hexChannel;
      }).join('');
      return `#${hexColor}`;
    } catch (error) {
      Logger.error(TAG, `[RNOH] rgbArrayToHex Errorcode: ${error.code}`);
      return error.code
    }
  }
}