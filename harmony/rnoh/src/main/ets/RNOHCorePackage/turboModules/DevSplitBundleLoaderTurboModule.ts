import { TurboModule, TurboModuleContext } from "../../RNOH/TurboModule";

export class DevSplitBundleLoaderTurboModule extends TurboModule {
  public static readonly NAME = 'DevSplitBundleLoader';

  constructor(protected ctx: TurboModuleContext) {
    super(ctx);
  }

  loadBundle(bundlePath: string): Promise<void> {
    console.log(`DevSplitBundleLoaderTurboModule call loadBundle`);
    return null;
  }
}