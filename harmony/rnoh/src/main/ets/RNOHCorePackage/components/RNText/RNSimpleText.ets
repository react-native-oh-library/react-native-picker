import { RNParagraphManager } from './RNParagraphManager';
import { RNViewManager } from '../..';
import matrix4 from '@ohos.matrix4';
import { convertColorSegmentsToString, RNOHContext, DEFAULT_LINE_SPACING, TransformMatrix, } from '../../../RNOH'
import { RNViewBase, ViewBaseDescriptor, ViewDescriptorWrapper } from '../RNViewBase'
import {
  stringToFontStyle,
  getTextDecorationLine,
  stringToAlignment,
  stringToStackAlignment,
  stringToTextTransform,
  getLetterSpacing,
  getMaxLines,
  ellipsizeModeToTextOverflow,
  getTextShadow,
  getFontSize,
  getMinFontSize,
  capitalizeTextIfNecessary,
} from './conversions'
import { AttributedFragment } from './types';
import { TextDescriptor } from './types'
import { TextModifier } from '../../componentAttributeModifiers/TextModifier'

function getAccessibilityLevel(descriptor: TextDescriptor) {
  if (
    descriptor.props["aria-hidden"] === true ||
      descriptor.props.accessibilityElementsHidden === true
  ) {
    return "no-hide-descendants";
  }

  return descriptor.props.importantForAccessibility ?? 'auto';
}

@Component
export struct RNSimpleText {
  ctx!: RNOHContext
  tag: number = 0
  @State descriptor: TextDescriptor = {} as TextDescriptor
  @State fragment: AttributedFragment | undefined = undefined
  private unregisterDescriptorChangesListener?: () => void = undefined

  public componentManager!: RNViewManager;
  @State private descriptorWrapper: ViewDescriptorWrapper | undefined = undefined
  private unregisterComponentManager?: () => void = undefined
  private unregisterCommandCallback?: () => void = undefined

  aboutToAppear() {
    this.initComponent();
    const descriptor = this.ctx.descriptorRegistry.getDescriptor<TextDescriptor>(this.tag)
    this.updateDescriptor(descriptor);
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        this.updateDescriptor(newDescriptor as TextDescriptor)
        this.setDescriptor(newDescriptor)
      }
    )
  }

  updateDescriptor(newDescriptor: TextDescriptor) {
    this.descriptor = newDescriptor
    this.fragment = newDescriptor.props.fragments[0]
  }

  aboutToDisappear() {
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
    Text(this.fragment && capitalizeTextIfNecessary(this.fragment?.text, this.fragment?.textTransform))
      .attributeModifier(TextModifier.getInstance().setDescriptor(this.descriptor, this.descriptorWrapper, this.fragment, this.tag))
  }
}