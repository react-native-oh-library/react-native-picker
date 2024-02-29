import { ComponentBuilderContext, RNOHContext, ViewBaseProps, Descriptor, } from 'rnoh';

export type Options1 = {
  pickerData: Array<any>
  isLoop: boolean
  selectedValue?: Array<string>
  pickerConfirmBtnText?: string
  pickerCancelBtnText?: string
  pickerTitleText?: string
  pickerConfirmBtnColor?: Array<number>
  pickerCancelBtnColor?: Array<number>
  pickerTitleColor?: Array<number>
  pickerToolBarBg?: Array<number>
  pickerBg?: Array<number>
  pickerToolBarFontSize?: number
  pickerFontSize: number
  pickerFontColor: Array<number>
  pickerFontFamily: string
  wheelFlex?: Array<number>
  pickerRowHeight?: number
}
export const PICKER_TYPE = "RNCPickerView" as const

export type PickerViewProps = ViewBaseProps & {
  isLoop: boolean
}

export type PickerViewDescriptor = Descriptor<typeof PICKER_TYPE, PickerViewProps>

@Component
export struct RNPicker{
  ctx: RNOHContext
  tag: number = 0
  @BuilderParam buildCustomComponent: (componentBuilderContext: ComponentBuilderContext) => void
  @State descriptor: PickerViewDescriptor = {} as PickerViewDescriptor
  private unregisterDescriptorChangesListener?: () => void = undefined
  private PARALLE_SELECTOR_TYPE = 1
  private CASCADE_SELECTOR_TYPE = 2
  private selectorRoller = 1
  private selectorType = 0
  private isLoop = false
  private pickerConfirmBtnText = 'confirm'
  private pickerCancelBtnText = 'cancel'
  private pickerTitleText = 'pls select'
  private pickerConfirmBtnColor = [1, 186, 245, 1]
  private pickerCancelBtnColor = [1, 186, 245, 1]
  private pickerTitleColor = [20, 20, 20, 1]
  private pickerToolBarBg = [232, 232, 232, 1]
  private pickerBg = [196, 199, 206, 1]
  private wheelFlex: number[] = [1, 1, 1]
  private wheelFlexSum = 3
  private pickerToolBarFontSize = 16
  private pickerFontSize = 16
  private pickerFontColor = [31, 31, 31, 1]
  private pickerFontFamily = 'Arial'
  private pickerRowHeight = 40
  private rawData: any[] = []
  private backUpData: any[] = []
  private pickerData: any[] = []
  private isError: boolean = false
  @State isShow: boolean = true
  @State selectedValue: number[] = []
  private arrayData: any[][] = [
    [1000, 2333, 3222, 4444],
    [5, 6, 7, 8],
    [5, 9, 7, 8],
    [5, 9, 7, 8],
    [5, 6, 7, 8],
    [5, 6, 7, 8]
  ];

  aboutToAppear() {
    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<PickerViewDescriptor>(this.tag)
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        this.descriptor = (newDescriptor as PickerViewDescriptor)
      }
    )

  }

  aboutToDisappear() {
    this.unregisterDescriptorChangesListener?.()
  }

  onPickerConfirm(value?: string, index?: number) {
    console.log('RNPicker onPickerConfirm')
    this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, PICKER_TYPE, {
      type: "pickerConfirm",
      value: value,
      index: index
    });
  }

  onPickerCancel(value?: string, index?: number) {
    console.log('RNPicker onPickerCancel')
    this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, PICKER_TYPE, {
      type: "pickerCancel",
      value: value,
      index: index
    });
  }

  onPickerSelect(value: string, index: number) {
    console.log('RNPicker onPickerSelect value:', value, "  index:", index)
    this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, PICKER_TYPE, {
      type: "pickerSelect",
      value: value,
      index: index
    })
  }

  init(options: Options1) {
    if (options) {
      if (options.pickerData && options.pickerData.length < 1) {
        this.rawData = options.pickerData
      }else{
        this.isError = true
        return
      }
      if (options.selectedValue) {
        this.selectValues(options.selectedValue)
      }
      if (options.isLoop) {
        this.isLoop = options.isLoop
      }
      if (options.pickerConfirmBtnText) {
        this.pickerConfirmBtnText = options.pickerConfirmBtnText
      }
      if (options.pickerCancelBtnText) {
        this.pickerCancelBtnText = options.pickerCancelBtnText
      }
      if (options.pickerTitleText) {
        this.pickerTitleText = options.pickerTitleText
      }
      if (options.pickerConfirmBtnColor) {
        this.pickerConfirmBtnColor = options.pickerConfirmBtnColor
      }
      if (options.pickerCancelBtnColor) {
        this.pickerCancelBtnColor = options.pickerCancelBtnColor
      }
      if (options.pickerTitleColor) {
        this.pickerTitleColor = options.pickerTitleColor
      }
      if (options.pickerToolBarBg) {
        this.pickerToolBarBg = options.pickerToolBarBg
      }
      if (options.pickerBg) {
        this.pickerBg = options.pickerBg
      }
      if (options.pickerFontSize) {
        this.pickerFontSize = options.pickerFontSize
      }
      if (options.pickerFontColor) {
        this.pickerFontColor = options.pickerFontColor
      }
      if (options.pickerFontFamily) {
        this.pickerFontFamily = options.pickerFontFamily
      }
      if (options.pickerToolBarFontSize) {
        this.pickerToolBarFontSize = options.pickerToolBarFontSize
      }
      if (options.wheelFlex) {
        this.wheelFlex = options.wheelFlex
      }
      if (options.pickerRowHeight) {
        this.pickerRowHeight = options.pickerRowHeight
      }
    }

    if (this.selectedValue && this.selectedValue.length < 1) {
      this.selectedValue = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    this.backUpData = this.rawData
    this.parseData(this.rawData)
    this.correctedWheelFlex(this.wheelFlex)
    this.wheelFlexSum = this.wheelFlex.reduce((accumulator, currentValue) => accumulator + currentValue, 0)
  }

  toggle() {
    this.isShow = !this.isShow
  }

  show() {
    this.isShow = true
  }

  hide() {
    this.isShow = false
  }

  selectValues(values: any[]) {
    if (values.length > this.selectorRoller + 1) {
      values.splice(this.selectorRoller + 1, values.length - this.selectorRoller + 1);
    } else if (values.length < this.selectorRoller + 1) {
      let len = this.selectorRoller + 1 - values.length
      for (let i = 0; i < len; i++) {
        values.push('')
      }
    }

    for (let k = 0; k < this.pickerData.length; k++) {
      for (let i = 0; i < this.pickerData[k].length; i++) {
        if (values[k].toString() === '') {
          return
        }
        if (this.pickerData[k][i] === values[k].toString()) {
          this.refreshSelectorData(k, i)
        }
      }
    }
  }

  isPickerShow(): boolean {
    return this.isShow && this.isError
  }

  parseData(arr: any[], level?: number) {
    if (!level || level < 0) {
      level = 1;
    }
    if (arr && arr.length > 0) {
      if (Array.isArray(arr[0])) {
        this.selectorType = this.PARALLE_SELECTOR_TYPE
        this.selectorRoller = arr.length
        this.pickerData = arr.map((innerArray) => {
          return innerArray.map((item) => item.toString());
        });
      } else if (typeof arr[0] === 'object' && arr[0] !== null) {
        if (!this.selectorType) {
          this.selectorType = this.CASCADE_SELECTOR_TYPE
        }
        let keys:string[] = []
        for (let i = 0; i < arr.length; i++) {
          const propertyNames = Object.keys(arr[i]);
          keys.push(propertyNames[0])
        }
        keys = keys.map((item) => item.toString());
        this.pickerData.push(keys)
        let values: any[] = Object.values(arr[0]);
        level = level + 1;
        this.parseData(values[0], level);
      } else {
        this.selectorRoller = level
        arr = arr.map((item) => item.toString());
        this.pickerData.push(arr)
      }
    } else {
      this.selectorRoller = level
    }
  }

  rgbArrayToHex(rgb: number[]): string {
    if (rgb.length > 3) {
      rgb.pop()
    }
    const hexColor = rgb.map((channel: number) => {
      const hexChannel = channel.toString(16).toUpperCase().padStart(2, '0');
      return hexChannel;
    }).join('');
    return `#${hexColor}`;
  }

  refreshSelectorData(roller, changeIndex) {
    this.selectedValue[roller] = changeIndex;
    if (this.selectorType === this.PARALLE_SELECTOR_TYPE || roller === this.selectorRoller - 1) {
      return
    }
    let keys:any[]
    for (let i = 0; i < this.selectorRoller; i++) {
      if (roller < i) {
        keys = []
        if (typeof this.backUpData[0] === 'object' && this.backUpData[0] !== null) {
          for (let j = 0; j < this.backUpData.length; j++) {
            const propertyNames = Object.keys(this.backUpData[j]);
            keys.push(propertyNames[0])
          }
          keys = keys.map((item) => item.toString());
        } else {
          keys = this.backUpData.map((item) => item.toString());
        }

        this.pickerData[i] = keys
      }

      if (typeof this.backUpData[this.selectedValue[i]] === 'object' && this.backUpData[this.selectedValue[i]] !== null) {
        let values: any[] = Object.values(this.backUpData[this.selectedValue[i]]);
        this.backUpData = values[0]
      } else {
        this.backUpData = this.rawData
        return
      }
    }
  }

  getTextStyle(isSelected: boolean): PickerTextStyle {
    return {
      color: this.rgbArrayToHex(this.pickerFontColor),
      font: {
        size: isSelected ? this.pickerFontSize * 1.1 : this.pickerFontSize,
        family: this.pickerFontFamily
      },
    }
  }

  correctedWheelFlex(values: number[]) {
    if (values.length > this.selectorRoller) {
      values.splice(this.selectorRoller, values.length - this.selectorRoller);
    } else if (values.length < this.selectorRoller) {
      let len = this.selectorRoller - values.length
      for (let i = 0; i < len; i++) {
        values.push(1)
      }
    }

    this.wheelFlex = values
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.pickerCancelBtnText)
          .fontSize(this.pickerToolBarFontSize)
          .fontColor(this.rgbArrayToHex(this.pickerCancelBtnColor))
          .width('20%')
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.onPickerCancel('ysp2',2)
          })
        Text(this.pickerTitleText)
          .fontSize(this.pickerToolBarFontSize)
          .fontColor(this.rgbArrayToHex(this.pickerTitleColor))
          .width('20%')
          .textAlign(TextAlign.Center)
        Text(this.pickerConfirmBtnText)
          .fontSize(this.pickerToolBarFontSize)
          .fontColor(this.rgbArrayToHex(this.pickerConfirmBtnColor))
          .width('20%')
          .textAlign(TextAlign.Start)
          .onClick(() => {
            this.onPickerConfirm('ysp1',1)
          })
      }.backgroundColor(this.rgbArrayToHex(this.pickerToolBarBg))
      .height('5%')
      .width('100%')

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceEvenly }) { // 子组件在容器主轴上行布局
        ForEach(this.pickerData, (item: any[], roller: number) => {
          TextPicker({ range: item, selected: this.selectedValue[roller] })
            .onChange((value: string, index: number) => {
              this.onPickerSelect(value, index)
              this.refreshSelectorData(roller, index)
            })
            .canLoop(this.isLoop)
            .defaultPickerItemHeight(this.pickerRowHeight)
            .textStyle(this.getTextStyle(false))
            .selectedTextStyle(this.getTextStyle(true))
            .height('100%')
            .width(`${this.wheelFlex[roller] * 100 / this.wheelFlexSum}%`)
            .backgroundColor(this.rgbArrayToHex(this.pickerBg))
        }, item => item)
      }
      .height('30%')
      .width('100%')
    }.position({ x: 0, y: '65%' }).visibility(this.isShow && !this.isError ? Visibility.Visible : Visibility.None)
  }
}
