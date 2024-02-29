import { TurboModule, TurboModuleContext } from "../../RNOH/TurboModule";

export class BlobTurboModule extends TurboModule {
  public static readonly NAME = 'BlobModule';

  constructor(protected ctx: TurboModuleContext) {
    super(ctx);
  }

  addNetworkingHandler() {
    console.log('BlobTurboModule call addNetworkingHandler');
  }
}
