import { RNOHContext, Tag, TransformMatrix } from '../../RNOH'
import { RNViewBase, ViewBaseDescriptor, ViewDescriptorWrapper } from './RNViewBase'
import { rnComponentFactoryBuilder , ComponentBuilderContext, RNComponentFactory } from './RNComponentFactory'
import { RNViewManager } from '..'
import { ViewModifier } from '../componentAttributeModifiers/ViewModifier'
import matrix4 from '@ohos.matrix4'

@Component
export struct RNView {
  ctx!: RNOHContext
  tag: number = 0
  @BuilderParam public buildCustomComponent: (ctx: ComponentBuilderContext) => void

  public componentManager!: RNViewManager;
  @State private descriptorWrapper: ViewDescriptorWrapper | undefined = undefined
  private unregisterDescriptorChangesListener?: () => void = undefined
  private unregisterComponentManager?: () => void = undefined
  private unregisterCommandCallback?: () => void = undefined

  @State private childrenTags: Tag[] = []
  private cleanupCallback?: () => void = undefined

  aboutToAppear() {
    this.initComponent();
    const descriptor = this.ctx.descriptorRegistry.getDescriptor<ViewBaseDescriptor>(this.tag)
    if (descriptor) {
      this.updateDescriptor(descriptor)
    }
    this.cleanupCallback = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(
      this.tag,
      (newDescriptor) => this.updateDescriptor(newDescriptor)
    )
  }

  updateDescriptor(descriptor: ViewBaseDescriptor) {
    this.childrenTags = descriptor.childrenTags;
  }

  aboutToDisappear() {
    this.cleanupCallback?.()

    this.unregisterDescriptorChangesListener?.()
    this.unregisterComponentManager?.()
    this.unregisterCommandCallback?.()
  }

  initComponent() {
    let descriptor = this.ctx.descriptorRegistry.getDescriptor<ViewBaseDescriptor>(this.tag)
    if (!this.componentManager) {
      this.componentManager = new RNViewManager(this.tag, this.ctx)
    }
    this.unregisterComponentManager = this.ctx.componentManagerRegistry.registerComponentManager(this.tag, this.componentManager)
    this.setDescriptor(descriptor)
    const parentTag = descriptor.parentTag;
    this.componentManager.setParentTag(parentTag);
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        this.setDescriptor(newDescriptor)
      }
    )
  }

  private setDescriptor(descriptor: ViewBaseDescriptor) {
    this.descriptorWrapper = new ViewDescriptorWrapper(descriptor)
  }

  getHitTestMode() {
    switch (this.descriptorWrapper?.pointerEvents) {
      case "none":
        return HitTestMode.None
      case "box-none":
        return HitTestMode.None
      case "box-only":
        return HitTestMode.Block
      default:
        return HitTestMode.Default
    }
  }

  getBorderStyle(): BorderStyle {
    switch (this.descriptorWrapper?.borderStyle) {
      case "dashed":
        return BorderStyle.Dashed
      case "dotted":
        return BorderStyle.Dotted
      default:
        return BorderStyle.Solid
    }
  }

  getTransform(): undefined | matrix4.Matrix4Transit {
    const descriptorWrapper = this.descriptorWrapper
    if (!descriptorWrapper) {
      return undefined
    }
    const rawTransformationMatrix = descriptorWrapper.rawTransformationMatrix.slice()
    rawTransformationMatrix[12] = vp2px(rawTransformationMatrix[12]);
    rawTransformationMatrix[13] = vp2px(rawTransformationMatrix[13]);
    rawTransformationMatrix[14] = vp2px(rawTransformationMatrix[14]);
    return matrix4.init(rawTransformationMatrix as TransformMatrix)
  }

  build() {
    Stack() {
      ForEach(this.childrenTags, (childrenTag: Tag) => {
        rnComponentFactoryBuilder(this.ctx, childrenTag, this.ctx.rnInstance.getComponentNameFromDescriptorType(this.ctx.descriptorRegistry.getDescriptor(childrenTag)?.type))
      }, (childrenTag: Tag) => childrenTag.toString())
    }
    .attributeModifier(ViewModifier.getInstance().setDescriptor(this.descriptorWrapper, this.tag))
    // .width(this.descriptorWrapper?.width)
    // .height(this.descriptorWrapper?.height)
    // .backgroundColor(this.descriptorWrapper?.backgroundColor)
    // .position(this.descriptorWrapper?.positionRelativeToParent)
    // .borderWidth(this.descriptorWrapper?.borderWidth)
    // .borderColor(this.descriptorWrapper?.borderColor)
    // .borderRadius(this.descriptorWrapper?.borderRadius)
    // .borderStyle(this.getBorderStyle())
    // .opacity(this.descriptorWrapper?.opacity)
    // .transform(this.getTransform())
    // .clip(this.descriptorWrapper?.isClipping)
    // .hitTestBehavior(this.getHitTestMode())
    // .shadow(this.descriptorWrapper?.shadow)
    // .id(this.tag.toString())
    // .accessibilityGroup(this.descriptorWrapper?.accessibilityGroup)
    // .accessibilityText(this.descriptorWrapper?.accessibilityText)
    // .accessibilityLevel(this.descriptorWrapper?.accessibilityLevel)
    // .accessibilityDescription(this.descriptorWrapper?.accessibilityDescription)
  }
}