/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow strict-local
 * @format
 */

type Foo = {
  /**
   * validating we don't translate this to a construct signature
   */
  constructor(): Foo,
};
