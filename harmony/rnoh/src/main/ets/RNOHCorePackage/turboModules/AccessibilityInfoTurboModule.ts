import { TurboModule, TurboModuleContext } from "../../RNOH/TurboModule";

export class AccessibilityInfoTurboModule extends TurboModule {
  public static readonly NAME = 'AccessibilityManager';

  constructor(protected ctx: TurboModuleContext) {
    super(ctx);
  }

  getCurrentBoldTextState(
    onSuccess: (isBoldTextEnabled: boolean) => void,
    onError: (error: Object) => void
  ) {
    console.log(`AccessibilityInfoTurboModule call getCurrentBoldTextState`);
  }

  getCurrentGrayscaleState(
    onSuccess: (isBoldTextEnabled: boolean) => void,
    onError: (error: Object) => void
  ) {
    console.log(`AccessibilityInfoTurboModule call getCurrentGrayscaleState`);
  }

  getCurrentInvertColorsState(
    onSuccess: (isBoldTextEnabled: boolean) => void,
    onError: (error: Object) => void
  ) {
    console.log(`AccessibilityInfoTurboModule call getCurrentInvertColorsState`);
  }

  getCurrentReduceMotionState(
    onSuccess: (isBoldTextEnabled: boolean) => void,
    onError: (error: Object) => void
  ) {
    console.log(`AccessibilityInfoTurboModule call getCurrentReduceMotionState`);
  }

  getCurrentPrefersCrossFadeTransitionsState(
    onSuccess: (isBoldTextEnabled: boolean) => void,
    onError: (error: Object) => void
  ) {
    console.log(`AccessibilityInfoTurboModule call getCurrentPrefersCrossFadeTransitionsState`);
  }

  getCurrentReduceTransparencyState(
    onSuccess: (isBoldTextEnabled: boolean) => void,
    onError: (error: Object) => void
  ) {
    console.log(`AccessibilityInfoTurboModule call getCurrentReduceTransparencyState`);
  }

  getCurrentVoiceOverState(
    onSuccess: (isBoldTextEnabled: boolean) => void,
    onError: (error: Object) => void
  ) {
    console.log(`AccessibilityInfoTurboModule call getCurrentVoiceOverState`);
  }

  setAccessibilityContentSizeMultipliers(JSMultipliers: {
    extraSmall?: number | null | void,
    small?: number | null | void,
    medium?: number | null | void,
    large?: number | null | void,
    extraLarge?: number | null | void,
    extraExtraLarge?: number | null | void,
    extraExtraExtraLarge?: number | null | void,
    accessibilityMedium?: number | null | void,
    accessibilityLarge?: number | null | void,
    accessibilityExtraLarge?: number | null | void,
    accessibilityExtraExtraLarge?: number | null | void,
    accessibilityExtraExtraExtraLarge?: number | null | void,
  }) {
    console.log(`AccessibilityInfoTurboModule call setAccessibilityContentSizeMultipliers`)
  }

  setAccessibilityFocus(reactTag: number) {
    console.log(`AccessibilityInfoTurboModule call setAccessibilityFocus`);
  }

  announceForAccessibility(announcement: string) {
    console.log(`AccessibilityInfoTurboModule call announceForAccessibility`);
  }

  announceForAccessibilityWithOptions(
    announcement: string,
    options: {queue?: boolean},
  ) {
    console.log(`AccessibilityInfoTurboModule call announceForAccessibilityWithOptions`);
  }
}
