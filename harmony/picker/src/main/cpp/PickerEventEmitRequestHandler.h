/*
 * MIT License
 *
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#pragma once
#include <napi/native_api.h>
#include "RNOH/ArkJS.h"
#include "RNOH/EventEmitRequestHandler.h"
#include "EventEmitters.h"

using namespace facebook;
namespace rnoh {

enum PickerEventType {
    PICKER_CONFIRM = 0,
    PICKER_CANCEL= 1,
    PICKER_SELECT = 2
};

PickerEventType getPickerEventType(ArkJS &arkJs, napi_value eventObject)
{
    auto eventType = arkJs.getString(arkJs.getObjectProperty(eventObject, "type"));
    if (eventType == "onPickerConfirm") {
        return PickerEventType::PICKER_CONFIRM;
    } else if (eventType == "onPickerCancel") {
        return PickerEventType::PICKER_CANCEL;
    } else if (eventType == "onPickerSelect") {
        return PickerEventType::PICKER_SELECT;
    } else {
        throw std::runtime_error("Unknown Page event type");
    }
}

class PickerEventEmitRequestHandler : public EventEmitRequestHandler {
public:
void handleEvent(EventEmitRequestHandler::Context const &ctx) override
{
        if (ctx.eventName != "RNCPickerView") {
            return;
        }
        ArkJS arkJs(ctx.env);
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<react::RNCPickerViewEventEmitter>(ctx.tag);
        if (eventEmitter == nullptr) {
            return;
        }

        switch (getPickerEventType(arkJs, ctx.payload)) {
            case PickerEventType::PICKER_CONFIRM: {
            std::string value = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "value"));
            int index = (int)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "index"));

            react::RNCPickerViewEventEmitter::OnPicker event{value, index};
            eventEmitter->onPickerConfirm(event);
            break;
            }

            case PickerEventType::PICKER_CANCEL: {
            std::string value = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "value"));
            int index = (int)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "index"));

            react::RNCPickerViewEventEmitter::OnPicker event{value, index};
            eventEmitter->onPickerCancel(event);
            break;
            }
            case PickerEventType::PICKER_SELECT: {
            std::string value = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "value"));
            int index = (int)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "index"));

            react::RNCPickerViewEventEmitter::OnPicker event{value, index};
            eventEmitter->onPickerSelect(event);
            break;
            }
            default:
                break;
        }
};
};
} // namespace rnoh