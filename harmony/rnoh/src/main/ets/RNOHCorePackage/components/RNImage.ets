import { RNViewManager } from '..';
import matrix4 from '@ohos.matrix4';
import { RemoteImageLoaderError } from '../../RemoteImageLoader/RemoteImageLoaderError';
import { ColorSegments, Descriptor, getTintColorMatrix, RNOHContext, TransformMatrix } from '../../RNOH';
import { ImageLoaderTurboModule } from '../turboModules/ImageLoaderTurboModule';
import { RNViewBase, ViewBaseDescriptor, ViewBaseProps,
  ViewDescriptorWrapper,
  ViewDescriptorWrapperBase, ViewRawProps } from './RNViewBase';
import { ImageModifier } from '../componentAttributeModifiers/ImageModifier'
export interface ImageProps extends ViewBaseProps {
  uri: string,
  resizeMode: number,
  tintColor?: ColorSegments,
  blurRadius: number
}

interface ImageRawProps extends ViewRawProps {
  alt: string
  resizeMethod: string
}

interface ImageOnCompleteEvent {
  width: number;
  height: number;
  componentWidth: number;
  componentHeight: number;
  loadingStatus: number;
  contentWidth: number;
  contentHeight: number;
  contentOffsetX: number;
  contentOffsetY: number;
}

interface ImageOnErrorEvent {
  componentWidth: number;
  componentHeight: number;
  message?: string;
}

export interface ImageState {}


export type ImageDescriptor = Descriptor<"Image", ImageProps, ImageState, ImageRawProps>;
export class ImageDescriptorWrapper extends ViewDescriptorWrapperBase<"Image", ImageProps, ImageState, ImageRawProps> {
}

class ImageSourceHolder {
  public source: string | Resource | PixelMap

  constructor(source: string | Resource | PixelMap) {
    this.source = source
  }
}

@Component
export struct RNImage {
  ctx!: RNOHContext
  tag: number = 0
  @State descriptor: ImageDescriptor = Object() as ImageDescriptor
  @State descriptorWrapper: ImageDescriptorWrapper | undefined = undefined
  // workaround: `@State` fields cannot be unions of primitive (`string`) and object (`Resource`, `PixelMap`) types
  @State imageSource: ImageSourceHolder | undefined = undefined
  defaultColorFilter: number[] = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]
  private unregisterDescriptorChangesListener?: () => void = undefined

  public componentManager!: RNViewManager;
  @State private viewDescriptorWrapper: ViewDescriptorWrapper | undefined = undefined
  private unregisterComponentManager?: () => void = undefined
  private unregisterCommandCallback?: () => void = undefined

  aboutToAppear() {
    this.initComponent();
    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<ImageDescriptor>(this.tag)
    this.descriptorWrapper = new ImageDescriptorWrapper(this.descriptor)
    this.onLoadStart();
    this.updateImageSource();
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        const newImageDescriptor = (newDescriptor as ImageDescriptor);
        const uriChanged = newImageDescriptor.props.uri !== this.descriptor.props.uri;
        this.descriptor = newImageDescriptor;
        this.descriptorWrapper = new ImageDescriptorWrapper(this.descriptor);
        if (uriChanged) {
          this.onLoadStart();
          this.updateImageSource();
        }
      }
    )
  }

  aboutToDisappear() {
    this.unregisterDescriptorChangesListener?.()

    this.unregisterComponentManager?.()
    this.unregisterCommandCallback?.()
  }

  updateImageSource() {
    const uri = this.descriptor.props.uri;
    if (uri.startsWith("asset://")) {
      this.imageSource = new ImageSourceHolder($rawfile(uri.replace("asset://", "assets/")));
      return;
    }
    if (uri.startsWith("data:")) {
      this.imageSource = new ImageSourceHolder(uri);
      return;
    }
    const imageLoader = this.ctx.rnInstance.getTurboModule<ImageLoaderTurboModule>("ImageLoader");
    this.imageSource = undefined;
    imageLoader.getRemoteImageSource(uri).then(async (remoteImage) => {
      try {
        const imageSource = remoteImage.getImageSource();
        const frameCounter = await imageSource.getFrameCount();
        if (frameCounter === 1) {
          // use the downloaded or cached image source
          this.imageSource = new ImageSourceHolder(await imageLoader.getPixelMap(uri));
        } else {
          // an animated GIF
          this.imageSource = new ImageSourceHolder(remoteImage.getLocation())
        }
      } catch (error) {
        this.dispatchOnError(error.message);
      }
    }).catch((error: RemoteImageLoaderError) => {
        this.dispatchOnError(error.message)
    })
  }

  /*
  * enum class ImageResizeMode {
  *   Cover,
  *   Contain,
  *   Stretch,
  *   Center,
  *   Repeat
  * }
   */
  getResizeMode(resizeMode: number) {
    switch (resizeMode) {
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

  onLoadStart() {
    this.ctx.rnInstanceManager.emitComponentEvent(
      this.descriptor.tag,
      "loadStart",
      null
    )
  }

  onLoad(event?: ImageOnCompleteEvent) {
    if (this.imageSource !== undefined && event) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, "load", {
        width: event.width,
        height: event.height,
        uri: this.descriptor.props.uri,
      })
    }
  }

  dispatchOnError(message?: string) {
    const errorMessage = message ? message : "Failed to load the image";
    this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, "error", errorMessage)
  }

  getColorFilter(): number[] {
    if (!this.descriptor.props.tintColor || this.descriptor.props.tintColor.every((element) => element === 0)) {
      return this.defaultColorFilter;
    }

    return getTintColorMatrix(this.descriptor.props.tintColor)
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
    this.viewDescriptorWrapper = new ViewDescriptorWrapper(descriptor)
  }

  getHitTestMode() {
    switch (this.viewDescriptorWrapper?.pointerEvents) {
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
    switch (this.viewDescriptorWrapper?.borderStyle) {
      case "dashed":
        return BorderStyle.Dashed
      case "dotted":
        return BorderStyle.Dotted
      default:
        return BorderStyle.Solid
    }
  }

  getTransform(): undefined | matrix4.Matrix4Transit {
    const descriptorWrapper = this.viewDescriptorWrapper
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
    // NOTE: this ensures we switch the image source, even if the new source is bad.
    // ArkUI keeps displaying the last "good" image when the passed source parameter changes
    if (this.imageSource?.source !== undefined) {
      Image(this.imageSource.source)
        .attributeModifier(ImageModifier.getInstance().setDescriptor(this.descriptor, this.descriptorWrapper, this.tag))
        .interpolation(ImageInterpolation.High)
        .colorFilter(this.getColorFilter())
        .focusable(this.descriptorWrapper?.focusable ?? false)
        .onComplete(event => this.onLoad(event))
        .onError((event: ImageOnErrorEvent) => {
          if (this.imageSource !== undefined) {
            this.dispatchOnError(event.message)
          }
          this.imageSource = undefined;
        })
    }
  }
}