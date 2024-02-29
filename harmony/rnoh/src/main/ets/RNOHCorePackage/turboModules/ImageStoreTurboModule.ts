import { TurboModule, TurboModuleContext } from "../../RNOH/TurboModule";

export class ImageStoreTurboModule extends TurboModule {
  public static readonly NAME = 'ImageStoreManager';

  constructor(protected ctx: TurboModuleContext) {
    super(ctx);
  }

  getConstants(): void {
    console.log(`ImageStoreTurboModule call getConstants`);
  }

  getBase64ForTag(
    uri: string,
    successCallback: (base64ImageData: string) => void,
    errorCallback: (error: {message: string}) => void,
  ): void {
    console.log(`ImageStoreTurboModule call getBase64ForTag`);
  }

  hasImageForTag(
    uri: string, 
    callback: (hasImage: boolean) => void
  ): void {
    console.log(`ImageStoreTurboModule call hasImageForTag`);
  }

  removeImageForTag(uri: string): void {
    console.log(`ImageStoreTurboModule call removeImageForTag`);
  }

  addImageFromBase64(
    base64ImageData: string,
    successCallback: (uri: string) => void,
    errorCallback: (error: {message: string}) => void,
  ): void {
    console.log(`ImageStoreTurboModule call addImageFromBase64`);
  }
}