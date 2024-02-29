import { RNAbility, RNInstance } from "./RNOH"
import { RNSurface, SurfaceConfig2 } from "./RNSurface"
import { ComponentBuilderContext, CustomComponentBuilder } from './RNOHCorePackage';

@CustomDialog
export struct LogBoxDialog {
  public controller: CustomDialogController
  public rnInstance!: RNInstance
  public initialProps: Record<string, string> = {}
  public buildCustomComponent!: WrappedBuilder<[ctx: ComponentBuilderContext]>
  @StorageLink('RNAbility') private rnAbility: RNAbility = {} as RNAbility

  build() {
    RNSurface({
      ctx: this.rnAbility.createRNOHContext({ rnInstance: this.rnInstance }),
      surfaceConfig: {
        initialProps: this.initialProps ?? {},
        appKey: "LogBox",
      } as SurfaceConfig2,
      buildCustomComponent: this.buildCustomComponent,
    })
  }
}
