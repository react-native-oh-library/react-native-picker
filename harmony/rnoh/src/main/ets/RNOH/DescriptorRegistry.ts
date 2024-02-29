import { Descriptor, DescriptorWrapper, NativeId, Tag } from './DescriptorBase';
import { Mutation, MutationType } from './Mutation';
import type { RNInstanceImpl } from './RNInstance';
import type { RNOHLogger } from './RNOHLogger';

type RootDescriptor = Descriptor<"RootView", any>

type SubtreeListener = () => void;
type SetNativeStateFn = (componentName: string, tag: Tag, state: unknown) => void
export type DescriptorWrapperFactory = (ctx: {descriptor: Descriptor}) => DescriptorWrapper

export class DescriptorRegistry {
  static readonly ANIMATED_NON_RAW_PROP_KEYS = ['transform'];

  private descriptorByTag: Map<Tag, Descriptor> = new Map();
  private descriptorWrapperByTag: Map<Tag, DescriptorWrapper> = new Map();
  private descriptorTagById: Map<NativeId, Tag> = new Map();
  private descriptorListenersSetByTag: Map<Tag, Set<(descriptor: Descriptor) => void>> = new Map();
  private subtreeListenersSetByTag: Map<Tag, Set<SubtreeListener>> = new Map();
  private animatedRawPropsByTag: Map<Tag, Set<string>> = new Map();
  private updatedUnnotifiedTags = new Set<Tag>()
  private cleanUpCallbacks: (() => void)[] = []
  private logger: RNOHLogger

  constructor(
    descriptorByTag: Record<Tag, Descriptor>,
    private setNativeStateFn: SetNativeStateFn,
    private rnInstance: RNInstanceImpl,
    private descriptorWrapperFactoryByDescriptorType: Map<string, DescriptorWrapperFactory>,
  logger: RNOHLogger,
  ) {
    this.logger = logger.clone("DescriptorRegistry")
    const stopTracing = this.logger.clone("constructor").startTracing()
    for (const tag in descriptorByTag) {
      this.descriptorByTag.set(parseInt(tag), descriptorByTag[tag])
      this.descriptorWrapperByTag.set(parseInt(tag), new DescriptorWrapper(descriptorByTag[tag]))
    }
    this.cleanUpCallbacks.push(this.rnInstance.subscribeToLifecycleEvents("FOREGROUND", () => {
      this.callListeners(this.updatedUnnotifiedTags)
      this.updatedUnnotifiedTags.clear()
    }))
    stopTracing()
  }

  private saveDescriptor(descriptor: Descriptor) {
    this.descriptorByTag.set(descriptor.tag, descriptor)
    const createDescriptorWrapper = this.descriptorWrapperFactoryByDescriptorType.get(descriptor.type)
    let descriptorWrapper = new DescriptorWrapper(descriptor)
    if (createDescriptorWrapper) {
      descriptorWrapper = createDescriptorWrapper({ descriptor })
    }
    this.descriptorWrapperByTag.set(descriptor.tag, descriptorWrapper)
    const id = descriptorWrapper.id
    this.descriptorTagById.set(id, descriptor.tag)
    if (descriptorWrapper.hints.includes("debug")) {
      this.logger.clone(`id:${id}`).debug(JSON.stringify(descriptor, null, 2))
    }
  }

  private deleteDescriptor(tag: Tag) {
    const descriptorWrapper = this.descriptorWrapperByTag.get(tag)
    if (descriptorWrapper) {
      this.descriptorByTag.delete(descriptorWrapper.tag)
      if (descriptorWrapper.id) {
        this.descriptorTagById.delete(descriptorWrapper.id)
      }
    }
  }

  public onDestroy() {
    const stopTracing = this.logger.clone("destroy").startTracing()
    this.cleanUpCallbacks.forEach(cb => cb())
    stopTracing()
  }

  public getDescriptor<TDescriptor extends Descriptor>(tag: Tag): TDescriptor {
    return this.descriptorByTag.get(tag) as TDescriptor;
  }

  public findDescriptorWrapperByTag<TDescriptorWrapper extends DescriptorWrapper>(tag: Tag): TDescriptorWrapper | null {
    return this.descriptorWrapperByTag.get(tag) as TDescriptorWrapper | null
  }

  public findDescriptorById<TDescriptor extends Descriptor>(id: NativeId): TDescriptor | null {
    const tag = this.descriptorTagById.get(id)
    if (tag) {
      return this.descriptorByTag.get(tag) as (TDescriptor | null)
    }
    return null
  }

  /**
   * @returns [...ancestors, descriptor]
   * Tree of descriptors represent data we have received from RN. To get representation of current state of UI use getComponentManagerLineage.
   */
  public getDescriptorLineage(tag: Tag): Descriptor[] {
    const results: Descriptor[] = []
    let currentTag: Tag | undefined = tag
    do {
      let descriptor = this.getDescriptor(currentTag)
      currentTag = descriptor.parentTag
      results.push(descriptor)
    } while (currentTag !== undefined);
    return results.reverse();
  }

  private splitAnimatedProps(animatedProps: Object): [Object, Object] {
    const props = {};
    const rawProps = {};

    Object.entries(animatedProps).forEach(([key, value]) => {
      if (DescriptorRegistry.ANIMATED_NON_RAW_PROP_KEYS.includes(key)) {
        props[key] = value;
      } else {
        rawProps[key] = value;
      }
    })

    return [props, rawProps];
  }

  /**
   * Called by NativeAnimatedTurboModule. This method needs to be encapsulated.
   */
  public setAnimatedRawProps<TProps extends Object>(tag: Tag, newProps: TProps): void {
    this.logger.clone('setAnimatedRawProps').debug("")
    let descriptor = this.getDescriptor<Descriptor<string, TProps>>(tag);

    if (!descriptor) {
      return;
    }

    // update stored animated props
    const oldProps = this.animatedRawPropsByTag.get(tag);
    const mergedProps = { ...oldProps, ...newProps };
    this.animatedRawPropsByTag.set(tag, mergedProps);

    const [props, rawProps] = this.splitAnimatedProps(mergedProps);

    // set new props for the descriptor
    descriptor.props = { ...descriptor.props, ...props };
    descriptor.rawProps = { ...descriptor.rawProps, ...rawProps };
    const updatedDescriptor = { ...descriptor };
    this.saveDescriptor(updatedDescriptor)

    this.descriptorListenersSetByTag.get(tag)?.forEach(cb => cb(updatedDescriptor));
    this.callSubtreeListeners(new Set([tag]));
  }

  public setState<TState extends Object>(tag: Tag, state: TState): void {
    const stopTracing = this.logger.clone("setState").startTracing()
    let descriptor = this.getDescriptor<Descriptor<string, TState>>(tag);
    if (!descriptor) {
      return;
    }

    this.setNativeStateFn(descriptor.type, tag, state);
    stopTracing()
  }

  public applyMutations(mutations: Mutation[]) {
    this.logger.clone("applyMutations").debug()
    const updatedDescriptorTags = new Set(mutations.flatMap(mutation => {
      return this.applyMutation(mutation)
    }
    ));
    if (!this.rnInstance.shouldUIBeUpdated()) {
      updatedDescriptorTags.forEach(tag => this.updatedUnnotifiedTags.add(tag))
      return;
    }
    this.callListeners(updatedDescriptorTags)
  }

  private callListeners(tags: Set<Tag>): void {
    tags.forEach(tag => {
      const updatedDescriptor = this.getDescriptor(tag);
      if (!updatedDescriptor) return;
      this.descriptorListenersSetByTag.get(tag)?.forEach(cb => {
        cb(updatedDescriptor)
      });
    });
    this.callSubtreeListeners(tags);
  }

  private callSubtreeListeners(updatedDescriptorTags: Set<Tag>) {
    const setOfSubtreeListenersToCall = new Set<SubtreeListener>();
    for (const tag of updatedDescriptorTags) {
      let descriptor = this.descriptorByTag.get(tag);
      while (descriptor) {
        const listeners = this.subtreeListenersSetByTag.get(descriptor.tag);
        if (listeners) {
          for (const listener of listeners) {
            setOfSubtreeListenersToCall.add(listener);
          }
        }
        if (descriptor.parentTag) {
          descriptor = this.descriptorByTag.get(descriptor.parentTag);
        } else {
          break;
        }
      }
    }
    setOfSubtreeListenersToCall.forEach(listener => {
      listener();
    });
  }

  public subscribeToDescriptorChanges(
    tag: Tag,
    listener: (descriptor: Descriptor) => void,
  ) {
    if (!this.descriptorListenersSetByTag.has(tag)) {
      this.descriptorListenersSetByTag.set(tag, new Set());
    }
    this.descriptorListenersSetByTag.get(tag)!.add(listener);
    return () => {
      this.removeDescriptorChangesListener(tag, listener);
    };
  }

  private removeDescriptorChangesListener(
    tag: Tag,
    listener: (descriptor: Descriptor) => void,
  ) {
    const callbacksSet = this.descriptorListenersSetByTag.get(tag);
    callbacksSet?.delete(listener);
    if (callbacksSet?.size === 0) {
      this.descriptorListenersSetByTag.delete(tag);
    }
  }

  public subscribeToDescriptorSubtreeChanges(
    rootTag: Tag,
    listener: SubtreeListener,
  ) {
    if (!this.subtreeListenersSetByTag.has(rootTag)) {
      this.subtreeListenersSetByTag.set(rootTag, new Set());
    }
    this.subtreeListenersSetByTag.get(rootTag)!.add(listener);

    return () => {
      const callbacksSet = this.descriptorListenersSetByTag.get(rootTag);
      callbacksSet?.delete(listener);
      if (callbacksSet?.size === 0) {
        this.descriptorListenersSetByTag.delete(rootTag);
      }
    };
  }

  private applyMutation(mutation: Mutation): Tag[] {
    if (mutation.type === MutationType.CREATE) {
      this.saveDescriptor(this.maybeOverwriteProps(mutation.descriptor))
      return [];
    } else if (mutation.type === MutationType.INSERT) {
      const childDescriptor = this.descriptorByTag.get(mutation.childTag)!;
      childDescriptor.parentTag = mutation.parentTag;
      this.descriptorByTag.get(mutation.parentTag)?.childrenTags.splice(
        mutation.index,
        0,
        mutation.childTag,
      );
      return [mutation.childTag, mutation.parentTag];
    } else if (mutation.type === MutationType.UPDATE) {
      const currentDescriptor = this.descriptorByTag.get(mutation.descriptor.tag);
      const children = currentDescriptor!.childrenTags;
      const mutationDescriptor = this.maybeOverwriteProps(mutation.descriptor)
      const animatedProps = this.animatedRawPropsByTag.get(mutation.descriptor.tag);

      const newDescriptor = {
        ...currentDescriptor,
        ...mutation.descriptor,
        // NOTE: animated props override the ones from the mutation
        props: { ...currentDescriptor!.props, ...mutationDescriptor.props, ...animatedProps },
        rawProps: { ...currentDescriptor!.rawProps, ...mutationDescriptor.rawProps, ...animatedProps },
        state: { ...currentDescriptor!.state, ...mutationDescriptor.state },
        childrenTags: children,
      };
      this.saveDescriptor(newDescriptor)
      return [mutation.descriptor.tag];
    } else if (mutation.type === MutationType.REMOVE) {
      const parentDescriptor = this.descriptorByTag.get(mutation.parentTag)!;
      const childDescriptor = this.descriptorByTag.get(mutation.childTag)!;
      const idx = parentDescriptor.childrenTags.indexOf(mutation.childTag);
      if (idx != -1) {
        parentDescriptor.childrenTags.splice(idx, 1);
      }
      childDescriptor.parentTag = undefined;
      return [mutation.parentTag];
    } else if (mutation.type === MutationType.DELETE) {
      this.deleteDescriptor(mutation.tag)
      this.animatedRawPropsByTag.delete(mutation.tag);
      return [];
    } else if (mutation.type === MutationType.REMOVE_DELETE_TREE) {
      return [];
    }
    return [];
  }

  private maybeOverwriteProps(descriptor: Descriptor) {
    /**
     * This is done to avoid creating breaking changes. Previously isDynamicBinder indicated that a third party package
     * didn't provided explicit NapiBinder and props were generated from rawProps. Currently, however descriptors have
     * rawProps property which can be used instead. `isDynamicBinder` and this change is going to be removed in the
     * future.
     */
    const props = descriptor.isDynamicBinder ? descriptor.rawProps : descriptor.props
    return { ...descriptor, props }
  }

  public createRootDescriptor(tag: Tag) {
    const rootDescriptor: RootDescriptor = {
      isDynamicBinder: false,
      type: 'RootView',
      tag,
      childrenTags: [],
      props: { top: 0, left: 0, width: 0, height: 0 },
      state: {},
      rawProps: {},
      layoutMetrics: {
        frame: {
          origin: {
            x: 0,
            y: 0,
          },
          size: {
            width: 0,
            height: 0,
          }
        }
      }
    }
    this.saveDescriptor(rootDescriptor)
  }

  public deleteRootDescriptor(tag: Tag) {
    const descriptor = this.getDescriptor(tag);
    if (descriptor?.type !== "RootView") {
      return;
    }
    // delay deleting the root descriptor until the mutation
    // removing all its children has been applied
    if (descriptor.childrenTags.length === 0) {
      this.descriptorByTag.delete(tag);
      return;
    }
    const unsubscribe = this.subscribeToDescriptorChanges(tag, (newDescriptor) => {
      if (newDescriptor.childrenTags.length === 0) {
        unsubscribe();
        this.descriptorByTag.delete(tag);
      }
    });
  }

  public getDescriptorByTagMap() {
    return this.descriptorByTag
  }
}
