import { TurboModule, TurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { ComponentContent, window } from '@kit.ArkUI';

interface initOptions {
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

interface PickerTextStyle {
  color: string,
  font: FontStyle
}

interface FontStyle {
  size: number,
  family: string
}

interface GlobalDialogParam {
  content: string;
}

interface ResultItem {
  text: string;
  children: ResultItem[];
}

function processData(data: object[]): ResultItem[] {
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
          resultItem.children = processData(values);
        }
      }
    }
    return resultItem;
  });
  return result;
}

function processSelectedValue() {
  let data = content.pickerData as [];
  let defaultValue = content.selectedValue;
  if (data.every(item => Array.isArray(item))) {
    content.pickerData = data.map((item: string[] | number[]) => {
      return item.map((i: string | number) => {
        return i + '';
      });
    })
  } else {
    content.pickerData = processData(data);
  }
  if (!Array.isArray(defaultValue)) {
    content.selectedValue = defaultValue?.toString();
  } else {
    content.selectedValue = defaultValue.map(item => {
      return item.toString();
    })
  }
}

function getTextStyle(isSelected: boolean): PickerTextStyle {
  return {
    color: rgbArrayToHex(content.pickerFontColor),
    font: {
      size: isSelected ? content.pickerFontSize * 1.1 : content.pickerFontSize,
      family: content.pickerFontFamily
    },
  }
}

function rgbArrayToHex(rgb: number[]): string {
  if (rgb.length > 3) {
    rgb.pop();
  }
  const hexColor = rgb.map((channel: number) => {
    const hexChannel = channel.toString(16).toUpperCase().padStart(2, '0');
    return hexChannel;
  }).join('');
  return `#${hexColor}`;
}

@Builder
function buildGlobalDialogComponent() {
  Column() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text(content.pickerCancelBtnText)
        .fontSize(content.pickerToolBarFontSize)
        .fontColor(rgbArrayToHex(content.pickerCancelBtnColor))
        .width('20%')
        .textAlign(TextAlign.End)
        .onClick(() => {
          pickerCtx.rnInstance.emitDeviceEvent("pickerEvent",
            { type: 'cancel', selectedValue: content.selectedValue });
          GlobalDialog.close(uiContext);
          content.pickerData = undefined;
        })
      Text(content.pickerTitleText)
        .fontSize(content.pickerToolBarFontSize)
        .fontColor(rgbArrayToHex(content.pickerTitleColor))
        .width('20%')
        .textAlign(TextAlign.Center)
      Text(content.pickerConfirmBtnText)
        .fontSize(content.pickerToolBarFontSize)
        .fontColor(rgbArrayToHex(content.pickerConfirmBtnColor))
        .width('20%')
        .textAlign(TextAlign.Start)
        .onClick(() => {
          pickerCtx.rnInstance.emitDeviceEvent("pickerEvent",
            { type: 'confirm', selectedValue: content.selectedValue });
          GlobalDialog.close(uiContext);
        })
    }
    .backgroundColor(rgbArrayToHex(content.pickerToolBarBg))
    .height('5%')
    .width('100%')

    TextPicker({ range: content.pickerData, value: content.selectedValue })
      .onChange((value: string | string[], index: number | number[]) => {
        pickerCtx.rnInstance.emitDeviceEvent("pickerEvent",
          { type: 'select', selectedValue: value });
        content.selectedValue = value;
      })
      .canLoop(content.isLoop)
      .height('30%')
      .width('100%')
      .textStyle(getTextStyle(false))
      .selectedTextStyle(getTextStyle(true))
      .defaultPickerItemHeight(content.pickerRowHeight)
      .backgroundColor(rgbArrayToHex(content.pickerBg))
  }
}

let content: initOptions;
let pickerCtx: TurboModuleContext;
let uiContext: UIContext;
let showPicker: boolean = false;

export class GlobalDialog {
  static contentNode: ComponentContent<GlobalDialogParam>;

  static show(context: UIContext) {
    GlobalDialog.contentNode = new ComponentContent(context, wrapBuilder(buildGlobalDialogComponent));
    const promptAction = context.getPromptAction();
    promptAction.openCustomDialog(GlobalDialog.contentNode, {
      alignment: DialogAlignment.Bottom,
      autoCancel: false,
    });
    showPicker = true;
  }

  static close(context: UIContext) {
    const promptAction = context.getPromptAction();
    promptAction.closeCustomDialog(GlobalDialog.contentNode);
    showPicker = false;
  }
}

export class RNCPickerTurboModule extends TurboModule {
  protected ctx: TurboModuleContext;

  constructor(ctx: TurboModuleContext) {
    super(ctx);
    this.ctx = ctx;
    pickerCtx = ctx;
  }

  async init(options: initOptions) {
    content = options;
    processSelectedValue();
    window.getLastWindow(this.ctx.uiAbilityContext)
      .then((value) => {
        uiContext = value.getUIContext();
      })
  }

  async show() {
    GlobalDialog.show(uiContext);
  }

  async hide() {
    GlobalDialog.close(uiContext);
  }

  async select(array: Array<string>) {
    content.selectedValue = array;
  }

  async isPickerShow() {
    return showPicker;
  }
}

