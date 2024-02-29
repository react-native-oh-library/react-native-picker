import { TurboModule, TurboModuleContext } from "../../RNOH/TurboModule";

export class I18nTurboModule extends TurboModule {
  public static readonly NAME = 'I18nManager';

  constructor(protected ctx: TurboModuleContext) {
    super(ctx);
  }

  allowRTL() {
    console.log('I18nTurboModule call allowRTL');
  }

  forceRTL() {
    console.log('I18nTurboModule call forceRTL');
  }

  swapLeftAndRightRTL() {
    console.log('I18nTurboModule call swapLeftAndRightRTL');
  }

  getConstants() {
    console.log('I18nTurboModule call getConstants');
    return {
      isRTL: false,
      doLeftAndRightSwapInRTL: true
    };
  }
}
