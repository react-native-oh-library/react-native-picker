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
  DEFAULT_LINE_SPACING,
  TransformMatrix
} from '../../RNOH';
import { ViewDescriptorWrapper } from '../components/RNViewBase/ViewDescriptorWrapper';
import { TextDescriptor, AttributedFragment, EllipsizeMode} from '../components/RNText/types';
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
  capitalizeTextIfNecessary
} from '../components/RNText/conversions'
import matrix4 from '@ohos.matrix4';

function getAccessibilityLevel(descriptor: TextDescriptor) {
  if (
    descriptor.props["aria-hidden"] === true ||
      descriptor.props.accessibilityElementsHidden === true
  ) {
    return "no-hide-descendants";
  }

  return descriptor.props.importantForAccessibility ?? 'auto';
}

export class TextModifier implements AttributeModifier<TextAttribute> {
  private constructor() {}
  private static instance: TextModifier;
  protected descriptor: TextDescriptor = {} as TextDescriptor;
  protected descriptorWrapper: ViewDescriptorWrapper | undefined = undefined
  protected fragment: AttributedFragment | undefined = undefined;
  protected tag: number = 0

  public static getInstance(): TextModifier {
    if (!TextModifier.instance) {
      TextModifier.instance = new TextModifier();
    }
    return TextModifier.instance;
  }

  setDescriptor(descriptor: TextDescriptor, descriptorWrapper: ViewDescriptorWrapper | undefined = undefined, fragment: AttributedFragment | undefined, tag: number): TextModifier {
    this.descriptor = descriptor;
    this.descriptorWrapper = descriptorWrapper;
    this.fragment = fragment;
    this.tag = tag;
    return TextModifier.instance;
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

  applyNormalAttribute(instance: TextAttribute): void {
    instance.width(this.descriptorWrapper?.width);
    instance.height(this.descriptorWrapper?.height);
    instance.position(this.descriptorWrapper?.positionRelativeToParent);
    instance.id(this.tag.toString())

    if (JSON.stringify(this.fragment?.backgroundColor) !== '0,0,0,0') {
      instance.backgroundColor(convertColorSegmentsToString(this.fragment?.backgroundColor))
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
    if (this.descriptor.props.accessible) {
      instance.accessibilityGroup(this.descriptor.props.accessible)
    }
    instance.accessibilityText(this.descriptor.props["aria-label"] || this.descriptor.props.accessibilityLabel)
    instance.accessibilityLevel(getAccessibilityLevel(this.descriptor))
    if (this.descriptor.props.accessibilityHint) {
      instance.accessibilityDescription(this.descriptor.props.accessibilityHint)
    }

    if (JSON.stringify(this.fragment?.fontColor) !== '0,0,0,1') {
      instance.fontColor(convertColorSegmentsToString(this.fragment?.fontColor))
    }
    if (this.fragment?.fontFamily) {
      instance.fontFamily(this.fragment?.fontFamily)
    }
    if (this.fragment?.fontWeight !== FontWeight.Normal) {
      instance.fontWeight(this.fragment?.fontWeight)
    }
    if (this.fragment?.fontSize) {
      instance.fontSize(getFontSize(this.fragment?.fontSize, this.descriptor.rawProps))
    }
    if (this.fragment?.fontSize && this.descriptor.rawProps?.minimumFontScale && this.descriptor.rawProps?.adjustsFontSizeToFit) {
      instance.minFontSize(getMinFontSize(this.fragment?.fontSize, this.descriptor.rawProps))
      instance.maxFontSize(getFontSize(this.fragment?.fontSize, this.descriptor.rawProps))
    }
    if (this.descriptor.rawProps?.adjustsFontSizeToFit) {
      instance.heightAdaptivePolicy(TextHeightAdaptivePolicy.LAYOUT_CONSTRAINT_FIRST)
    }
    if (stringToFontStyle(this.fragment?.fontStyle) !== FontStyle.Normal) {
      instance.fontStyle(stringToFontStyle(this.fragment?.fontStyle))
    }
    if (this.fragment?.textDecorationLine) {
      instance.decoration({
        type: getTextDecorationLine(this.fragment?.textDecorationLine),
        color: convertColorSegmentsToString(this.fragment?.textDecorationColor ?? this.fragment?.fontColor)
      })
    }
    if (this.descriptorWrapper?.backgroundColor !== '#00000000') {
      instance.backgroundColor(this.descriptorWrapper?.backgroundColor)
    }
    if (this.fragment?.letterSpacing) {
      instance.letterSpacing(getLetterSpacing(this.fragment?.letterSpacing))
    }
    if (stringToTextTransform(this.fragment?.textTransform) !== TextCase.Normal) {
      instance.textCase(stringToTextTransform(this.fragment?.textTransform))
    }
    if (this.descriptor.props.maximumNumberOfLines) {
      instance.maxLines(getMaxLines(this.descriptor.props.maximumNumberOfLines))
    }
    if (this.fragment?.textShadowProps) {
      instance.textShadow(getTextShadow(this.fragment?.textShadowProps))
    }
    if (ellipsizeModeToTextOverflow(this.descriptor.props.ellipsizeMode as EllipsizeMode) !== TextOverflow.Clip) {
      instance.textOverflow({ overflow: ellipsizeModeToTextOverflow(this.descriptor.props.ellipsizeMode as EllipsizeMode) })
    }
    if (stringToAlignment(this.descriptor.props.textAlign) !== TextAlign.Start) {
      instance.textAlign(stringToAlignment(this.descriptor.props.textAlign))
    }
    if (stringToStackAlignment(this.descriptor.props.textAlign, this.descriptor.props.textAlignVertical) !== Alignment.Center) {
    instance.align(stringToStackAlignment(this.descriptor.props.textAlign, this.descriptor.props.textAlignVertical))
    }
    if (this.descriptor.props.padding) {
      instance.padding(this.descriptor.props.padding)
    }
    if (this.descriptor.props.selectable) {
      instance.copyOption(CopyOptions.LocalDevice)
    }
    instance.lineHeight(this.fragment?.lineHeight || (this.fragment?.fontSize ?? 16) * (DEFAULT_LINE_SPACING + 1))
    instance.enabled(!this.descriptor.props.disabled)
  }
}
