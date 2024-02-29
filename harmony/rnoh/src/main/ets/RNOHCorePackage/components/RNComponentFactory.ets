import { Tag, RNOHContext, RNComponentContext, DescriptorWrapper } from "../../RNOH"
import { RNView } from "./RNView"
import { RNImage } from "./RNImage"
import { RNTextInput } from "./RNTextInput"
import { RNText } from "./RNText"
import { RNScrollView } from "./RNScrollView"
import { Descriptor } from "../../RNOH/DescriptorBase";
import { RNModalHostView } from './RNModalHostView'
import { RNSwitch } from './RNSwitch'
import { RNActivityIndicator } from './RNActivityIndicator'
import { BuilderProxy } from '../../RNSurface'

export interface ComponentBuilderContext {
  /**
   * @deprecated Use `rnComponentContext` instead.
   */
  rnohContext: RNOHContext
  /**
   * @deprecated: Use tag and componentName instead
   */
  descriptor: DescriptorEssence
  tag: Tag
  componentName: string
  /**
   * rnComponentContext will replace rnohContext in the future
   */
  rnComponentContext: RNComponentContext
}

interface DescriptorEssence {
  tag: Tag,
  type: string
}

export type CustomComponentBuilder = (ctx: ComponentBuilderContext) => void

class ComponentBuilderContextImpl implements ComponentBuilderContext {
  public rnComponentContext: RNComponentContext
  public rnohContext: RNOHContext
  public tag: Tag
  public componentName: string
  public descriptor: DescriptorEssence

  constructor(rnComponentContext: RNComponentContext, rnohContext: RNOHContext, tag: Tag, componentName: string, descriptor: DescriptorEssence) {
    this.rnComponentContext = rnComponentContext
    this.rnohContext = rnohContext
    this.tag = tag
    this.componentName = componentName
    this.descriptor = descriptor
  }
}

@Builder
function buildCustomComponent(ctx: ComponentBuilderContext) {
  /**
   * If you want to improve the performance, you can tell RNOH to use buildRNComponent instead of RNComponentFactory.
   * However, there's no official way to inject your custom components into that builder, therefore you need to specify
   * those component here and enable feature flag 'USE_BUILD_RN_COMPONENT' by calling `RNInstance::enableFeatureFlag`.
   */
}

@Builder
export function rnComponentFactoryBuilder (ctx: RNOHContext, tag:Tag, componentName: string) {
  if (componentName === "View" || componentName === "RootView") {
    RNView({
      ctx: ctx,
      tag: tag,
      buildCustomComponent: buildCustomComponent
    })
  } else if (componentName === "Image") {
    RNImage({ ctx: ctx, tag: tag })
  } else if (componentName === "TextInput") {
    RNTextInput({ ctx: ctx, tag: tag })
  } else if (componentName === "Paragraph") {
    RNText({ ctx: ctx, tag: tag, buildCustomComponent: buildCustomComponent })
  } else if (componentName === "PullToRefreshView") {
    /**
     * RNScrollView displays Refresh component if PullToRefreshView is its direct parent.
     * Native Refresh component works correctly, only when a native Scroll is its direct child.
     */
    rnComponentFactoryBuilder(
      ctx,
      ctx.descriptorRegistry.getDescriptor(tag)?.childrenTags[0],
      ctx.rnInstance.getComponentNameFromDescriptorType(
        ctx.descriptorRegistry.getDescriptor(ctx.descriptorRegistry.getDescriptor(tag)?.childrenTags[0])?.type))
  }
  else if (componentName === "ScrollView") {
    RNScrollView({
      ctx: ctx,
      tag: tag,
      buildCustomComponent: buildCustomComponent,
    })
  } else if (componentName === "Switch") {
    RNSwitch({
      ctx: ctx,
      tag: tag,
    })
  } else if (componentName === "ModalHostView") {
    RNModalHostView({
      ctx: ctx,
      tag: tag,
      buildCustomComponent: buildCustomComponent
    })
  } else if (componentName === "ActivityIndicatorView") {
    RNActivityIndicator({
      ctx: ctx,
      tag: tag,
    })
  } else if (componentName !== '') {
    BuilderProxy.customComponentBuilder?.builder((new ComponentBuilderContextImpl(
      ctx,
      ctx,
      tag,
      componentName,
      ctx.descriptorRegistry.getDescriptor<Descriptor>(tag) as DescriptorEssence,
    )))
  }
}


@Component
export struct RNComponentFactory {
  public ctx!: RNOHContext
  public tag: number = 0
  @BuilderParam public buildCustomComponent!: CustomComponentBuilder
  @State private componentName: string = ''
  @State private childrenTags: Tag[] = []
  private cleanupCallback?: () => void = undefined

  aboutToAppear() {
    const descriptor = this.ctx.descriptorRegistry.getDescriptor<Descriptor>(this.tag)
    if (descriptor) {
      this.setDescriptor(descriptor)
    }
    this.cleanupCallback = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(
      this.tag,
      (newDescriptor) => this.setDescriptor(newDescriptor)
    )
  }

  aboutToDisappear() {
    this.cleanupCallback?.()
  }

  setDescriptor(newDescriptor: Descriptor) {
    this.componentName = this.ctx.rnInstance.getComponentNameFromDescriptorType(newDescriptor.type)
    this.childrenTags = newDescriptor.childrenTags
  }

  build() {
    if (this.componentName === "View" || this.componentName === "RootView") {
      RNView({
        ctx: this.ctx,
        tag: this.tag,
        buildCustomComponent: this.buildCustomComponent
      })
    } else if (this.componentName === "Image") {
      RNImage({ ctx: this.ctx, tag: this.tag })
    } else if (this.componentName === "TextInput") {
      RNTextInput({ ctx: this.ctx, tag: this.tag })
    } else if (this.componentName === "Paragraph") {
      RNText({ ctx: this.ctx, tag: this.tag, buildCustomComponent: this.buildCustomComponent })
    } else if (this.componentName === "PullToRefreshView") {
      /**
       * RNScrollView displays Refresh component if PullToRefreshView is its direct parent.
       * Native Refresh component works correctly, only when a native Scroll is its direct child.
       */
      RNComponentFactory({
        ctx: this.ctx,
        tag: this.childrenTags[0],
        buildCustomComponent: this.buildCustomComponent
      })
    }
    else if (this.componentName === "ScrollView") {
      RNScrollView({
        ctx: this.ctx,
        tag: this.tag,
        buildCustomComponent: this.buildCustomComponent
      })
    } else if (this.componentName === "Switch") {
      RNSwitch({
        ctx: this.ctx,
        tag: this.tag,
      })
    } else if (this.componentName === "ModalHostView") {
      RNModalHostView({
        ctx: this.ctx,
        tag: this.tag,
        buildCustomComponent: this.buildCustomComponent
      })
    } else if (this.componentName === "ActivityIndicatorView") {
      RNActivityIndicator({
        ctx: this.ctx,
        tag: this.tag,
      })
    } else if (this.componentName !== '') {
      this.buildCustomComponent({
        rnohContext: this.ctx,
        rnComponentContext: this.ctx,
        descriptor: this.ctx.descriptorRegistry.getDescriptor<Descriptor>(this.tag) as DescriptorEssence,
        tag: this.tag,
        componentName: this.componentName
      })
    }
  }
}
