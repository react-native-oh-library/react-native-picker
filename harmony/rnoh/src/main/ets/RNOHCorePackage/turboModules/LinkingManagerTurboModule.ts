import uri from '@ohos.uri';
import call from '@ohos.telephony.call';
import type { TurboModuleContext } from "../../RNOH/TurboModule";
import { TurboModule } from "../../RNOH/TurboModule";
import type { RNAbility } from '../../RNOH/RNAbility';
import bundleManager from '@ohos.bundle.bundleManager';
import type Want from '@ohos.app.ability.Want';

export class LinkingManagerTurboModule extends TurboModule {
  public static readonly NAME = 'LinkingManager' as const;

  private static readonly SUPPORTED_SCHEMES = ["tel", "sms", "http", "https"];

  private initialUrl: string | undefined;

  constructor(ctx: TurboModuleContext) {
    super(ctx);
    const rnAbility = AppStorage.get<RNAbility>("RNAbility");
    this.initialUrl = rnAbility.launchWant.uri;
  }

  async getInitialURL(): Promise<string | undefined> {
    return this.initialUrl;
  }

  async canOpenURL(urlString: string): Promise<boolean> {
    // TODO: check if there is an application which can handle the url.
    // This use case doesn't seem to be supported in OHOS yet?
    // You can `startAbility` to handle a `want`, but you can't
    // query if some ability _can_ handle it.
    const uriObject = new uri.URI(urlString);
    return LinkingManagerTurboModule.SUPPORTED_SCHEMES.includes(uriObject.scheme);
  }

  async openURL(urlString: string): Promise<void> {
    const uriObject = new uri.URI(urlString);
    switch (uriObject.scheme) {
      case "tel": {
        await call.makeCall(uriObject.ssp);
        return;
      }
      case "http":
      case "https": {
        const want = this.createBrowserWant(urlString);
        await this.ctx.uiAbilityContext.startAbility(want);
        return;
      }
      case "sms": {
        const want = this.createSMSWant(uriObject);
        await this.ctx.uiAbilityContext.startAbility(want);
        return;
      }
      default: {
        try {
          await this.ctx.uiAbilityContext.startAbility({ uri: urlString })
        } catch (e) {
          throw new Error(`URL scheme ${uriObject.scheme} is not supported`);
        }
      }
    }
  }

  openSettings(): Promise<void> {
    return this.ctx.uiAbilityContext.startAbility({
      "action": "action.settings.app.info",
      parameters: {
        settingsParamBundleName: this.ctx.uiAbilityContext.abilityInfo.bundleName
      }
    });
  }

  private createBrowserWant(urlString: string): Want {
    return {
      "action": "ohos.want.action.viewData",
      "entities": ["entity.system.browsable"],
      "uri": urlString,
    };
  }

  private createSMSWant(uri: uri.URI): Want {
    const telephone = uri.ssp;
    const parameters = telephone ? {
      contactObjects: JSON.stringify([{ telephone }]),
      pageFlag: 'conversation'
    } : undefined;
    // NOTE: the default sms app doesn't handle the `sendSms` action...
    // see https://gitee.com/openharmony/applications_mms/blob/master/entry/src/main/module.json5
    return {
      // "action": "ohos.want.action.sendSms",
      bundleName: "com.ohos.mms",
      abilityName: "com.ohos.mms.MainAbility",
      parameters
    }
  }
}
