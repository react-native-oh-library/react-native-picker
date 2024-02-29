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
  TransformMatrix,
  getTintColorMatrix
} from '../../RNOH';
import { ImageDescriptor, ImageDescriptorWrapper } from '../components/RNImage';
import matrix4 from '@ohos.matrix4';

export class ImageModifier implements AttributeModifier<ImageAttribute> {
  private constructor() {}
  private static instance: ImageModifier;
  protected descriptor: ImageDescriptor = Object() as ImageDescriptor
  protected descriptorWrapper: ImageDescriptorWrapper | undefined = undefined
  protected tag: number = 0
  defaultColorFilter: number[] = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]

  public static getInstance(): ImageModifier {
    if (!ImageModifier.instance) {
      ImageModifier.instance = new ImageModifier();
    }
    return ImageModifier.instance;
  }

  setDescriptor(descriptor: ImageDescriptor, descriptorWrapper: ImageDescriptorWrapper | undefined, tag: number): ImageModifier {
    this.descriptor = descriptor;
    this.descriptorWrapper = descriptorWrapper;
    this.tag = tag;
    return ImageModifier.instance;
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

  getResizeMode(resizeMode: number) {
    switch(resizeMode) {
      case 0:
        return ImageFit.Cover;
      case 1:
        return ImageFit.Contain;
      case 2:
        return ImageFit.Fill;
      case 3:
      case 4:
        return ImageFit.None;
      default:
        return ImageFit.Cover;
    }
  }

  getColorFilter(): number[] {
    if (!this.descriptor.props.tintColor || this.descriptor.props.tintColor.every((element) => element === 0)) {
      return this.defaultColorFilter;
    }

    return getTintColorMatrix(this.descriptor.props.tintColor)
  }

  applyNormalAttribute(instance: ImageAttribute): void {
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

    if (this.descriptor.rawProps.alt) {
      instance.accessibilityText(this.descriptor.rawProps.alt)
    }
    if (this.getResizeMode(this.descriptor.props.resizeMode) !== ImageFit.Cover) {
      instance.objectFit(this.getResizeMode(this.descriptor.props.resizeMode))
    }
    if (this.descriptor.props.resizeMode === 4) {
      instance.objectRepeat(ImageRepeat.XY)
    }
    if (this.descriptor.props.blurRadius) {
      instance.blur(this.descriptor.props.blurRadius)
    }
    if (this.descriptor.rawProps.resizeMethod === 'scale') {
      instance.autoResize(false)
    }
  }
}
