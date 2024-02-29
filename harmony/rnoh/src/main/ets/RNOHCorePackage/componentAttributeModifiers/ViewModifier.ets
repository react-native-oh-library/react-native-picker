import {
  BorderMetrics,
  convertColorSegmentsToString,
  convertColorValueToColorSegments,
  Descriptor,
  getTransformedVector,
  LayoutDirectionRN,
  OverflowMode,
  resolveBorderMetrics,
  RNOHContext,
  TransformMatrix
} from '../../RNOH';
import { ViewDescriptorWrapper } from '../components/RNViewBase/ViewDescriptorWrapper';
import matrix4 from '@ohos.matrix4';

export class ViewModifier implements AttributeModifier<StackAttribute> {
  private constructor() {}
  private static instance: ViewModifier;
  protected descriptorWrapper: ViewDescriptorWrapper | undefined = undefined
  protected tag: number = 0

  public static getInstance(): ViewModifier {
    if (!ViewModifier.instance) {
      ViewModifier.instance = new ViewModifier();
    }
    return ViewModifier.instance;
  }

  setDescriptor(descriptorWrapper: ViewDescriptorWrapper | undefined, tag: number): ViewModifier {
    this.descriptorWrapper = descriptorWrapper;
    this.tag = tag;
    return ViewModifier.instance;
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

  applyNormalAttribute(instance: StackAttribute): void {
    instance.width(this.descriptorWrapper?.width);
    instance.height(this.descriptorWrapper?.height);
    instance.position(this.descriptorWrapper?.positionRelativeToParent);
    instance.id(this.tag.toString())

    if (this.descriptorWrapper?.backgroundColor !== '#00000000') {
      instance.backgroundColor(this.descriptorWrapper?.backgroundColor)
    }
    if (JSON.stringify(this.descriptorWrapper?.borderWidth) !== '{}') {
      instance.borderWidth(this.descriptorWrapper?.borderWidth)
    }
    if (JSON.stringify(this.descriptorWrapper?.borderColor) !== '{"top":"#FF000000","left":"#FF000000","right":"#FF000000","bottom":"#FF000000"}') {
      instance.borderColor(this.descriptorWrapper?.borderColor)
    }
    if (JSON.stringify(this.descriptorWrapper?.borderRadius) !== '{}') {
      instance.borderRadius(this.descriptorWrapper?.borderRadius)
    }
    if (this.descriptorWrapper?.borderStyle === 'dashed' || this.descriptorWrapper?.borderStyle === 'dotted') {
      instance.borderStyle(this.getBorderStyle())
    }
    if (this.descriptorWrapper?.opacity !== 1) {
      instance.opacity(this.descriptorWrapper?.opacity)
    }
    if (this.descriptorWrapper?.transformStringify !== '[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]') {
      instance.transform(this.getTransform())
    }
    if (this.descriptorWrapper?.isClipping) {
      instance.clip(this.descriptorWrapper?.isClipping)
    }
    let hitTestBehavior: HitTestMode = this.getHitTestMode();
    if (hitTestBehavior !== HitTestMode.Default) {
      instance.hitTestBehavior(hitTestBehavior)
    }
    if (this.descriptorWrapper?.shadow) {
      instance.shadow(this.descriptorWrapper?.shadow)
    }
    if (JSON.stringify(this.descriptorWrapper?.accessibilityGroup) !== 'auto') {
      instance.accessibilityGroup(this.descriptorWrapper?.accessibilityGroup)
    }
    if (this.descriptorWrapper?.accessibilityText) {
      instance.accessibilityText(this.descriptorWrapper?.accessibilityText)
    }
    if (this.descriptorWrapper?.accessibilityLevel) {
      instance.accessibilityLevel(this.descriptorWrapper?.accessibilityLevel)
    }
    if (this.descriptorWrapper?.accessibilityDescription) {
      instance.accessibilityDescription(this.descriptorWrapper?.accessibilityDescription)
    }
  }
}
