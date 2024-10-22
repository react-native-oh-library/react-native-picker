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
      .onChange((value: string | string[]) => {
        changeSelect(value);
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
    pickerCtx.rnInstance.emitDeviceEvent(EVENT,
      { type: CANCEL, selectedValue: content.selectedValue });
    GlobalDialog.close();
    content.pickerData = undefined;
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] cancelClick failed ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

function confirmClick() {
  try {
    pickerCtx.rnInstance.emitDeviceEvent(EVENT,
      { type: CONFIRM, selectedValue: content.selectedValue });
    GlobalDialog.close();
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] confirmClick failed ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

function changeSelect(val: string | string[]) {
  try {
    pickerCtx.rnInstance.emitDeviceEvent(EVENT,
      { type: SELECT, selectedValue: val });
    content.selectedValue = val;
  } catch (error) {
    Logger.error(TAG,
      `[RNOH] changeSelect failed ErrorCode: ${error.code},  Message: ${error.message}`);
  }
}

let content: initOptions;
let pickerCtx: TurboModuleContext;
let uiContext: UIContext;
let showPicker: boolean = false;

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
          new Params(content.selectedValue ?? ''));
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
    content.selectedValue = array;
    GlobalDialog.contentNode.update(new Params(content.selectedValue));
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
      let data = content.pickerData as [];
      let defaultValue = content.selectedValue;
      if (data.every(item => Array.isArray(item))) {
        content.pickerData = data.map((item: string[] | number[]) => {
          return item.map((i: string | number) => {
            return i + '';
          });
        })
      } else {
        content.pickerData = this.processData(data);
      }
      if (!Array.isArray(defaultValue)) {
        content.selectedValue = defaultValue?.toString();
      } else {
        content.selectedValue = defaultValue.map(item => {
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