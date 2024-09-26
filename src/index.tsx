import { View, DeviceEventEmitter } from "react-native";
import RNCPickerView from "./NativePicker";

export default {

    init(options) {
        let opt = {
            isLoop: false,
            pickerConfirmBtnText: '确认',
            pickerCancelBtnText: '取消',
            pickerTitleText: '请选择',
            pickerTextEllipsisLen: 6,
            pickerToolBarFontSize: 16,
            pickerRowHeight: 24,
            pickerBg: [196, 199, 206, 1],
            wheelFlex: [1, 1, 1],
            pickerFontSize: 16,
            pickerToolBarBg: [232, 232, 232, 1],
            pickerTitleColor: [20, 20, 20, 1],
            pickerCancelBtnColor: [1, 186, 245, 1],
            pickerConfirmBtnColor: [1, 186, 245, 1],
            pickerFontColor: [31, 31, 31, 1],
            onPickerConfirm() { },
            onPickerCancel() { },
            onPickerSelect() { },
            ...options
        };
        let fnConf = {
            confirm: opt.onPickerConfirm,
            cancel: opt.onPickerCancel,
            select: opt.onPickerSelect
        };

        RNCPickerView.init(opt);
        //there are no `removeListener` for NativeAppEventEmitter & DeviceEventEmitter
        this.listener && this.listener.remove();
        this.listener = DeviceEventEmitter.addListener('pickerEvent', event => {
            fnConf[event['type']](event['selectedValue']);
        });
    },

    show() {
        RNCPickerView.show();
    },

    hide() {
        RNCPickerView.hide();
    },

    select(selected: any[]) {
        RNCPickerView.select(selected);
    },

    toggle() {
        this.isPickerShow(show => {
            if (show) {
                this.hide();
            }
            else {
                this.show();
            }
        });
    },

    isPickerShow(fn) {
        const status = RNCPickerView.isPickerShow();
            fn(status);
    }
};