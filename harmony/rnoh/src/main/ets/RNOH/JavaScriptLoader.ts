import fs from '@ohos.file.fs';
import http from '@ohos.net.http';
import util from '@ohos.util';
import request from '@ohos.request';
import common from '@ohos.app.ability.common';
import type resmgr from "@ohos.resourceManager";

import type { RNOHLogger } from './RNOHLogger'

export default class JavaScriptLoader {
  constructor(private resourceManager: resmgr.ResourceManager, private logger: RNOHLogger) {
  }
  
  public async loadBundle(uriString: string): Promise<string> {
    if (uriString.startsWith("http")) {
      return this.loadFromNetwork(uriString);
    } else if (fs.accessSync(uriString)) {
      return this.loadFromFile(uriString);
    } else {
      return this.loadFromResource(uriString);
    }
  }

  loadFromResource(bundlePath: string): Promise<string> {
    return new Promise((resolve, reject) => {
      this.resourceManager.getRawFileContent(bundlePath, (error, data) => {
        if (error != null) {
          console.error("RNOH, loadFromResource error " + error.message);
          reject(error.message);
        } else {
          let result = this.fromUtf8Array(data);
          resolve(result);
        }
      })
    });
  }

  fromUtf8Array(data) {
    var result = '';
    for (var i = 0; i < data.length; i += 65536) {
      var chunk = data.slice(i, i + 65536);
      result += String.fromCharCode.apply(null, chunk);
    }
    return result;
  }

  async loadFromFile(bundlePath: string): Promise<string> {
    try {
      const bundleFileContent = await this.resourceManager.getRawFileContent(bundlePath);
      const bundle = util.TextDecoder.create("utf-8").decodeWithStream(bundleFileContent);
      return bundle;
    } catch (err) {
      this.logger.fatal("Failed to load local bundle: " + bundlePath);
      throw err;
    }
  }

  async loadFromNetwork(uriString: string): Promise<string> {
    const httpRequest = http.createHttp();
    try {
      this.logger.info('loading bundle ' + uriString)
      const data = await httpRequest.request(
        uriString,
        {
          header: {
            'Content-Type': 'text/javascript'
          },
        }
      );
      this.logger.info('code:' + data.responseCode);
      this.logger.info('header:' + JSON.stringify(data.header));
      this.logger.info('cookies:' + data.cookies);
      return data.result as string;
    } catch (err) {
      this.logger.error('Bundle load error: ' + JSON.stringify(err));
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }

  async splitLoadFromNetwork(uriString: string): Promise<string> {
    const httpRequest = http.createHttp();
    let content = '';
    try {
      this.logger.info('loading bundle ' + uriString)
      const rsp = await httpRequest.request(
        uriString + '/split-pkgs',
        {
          header: {
            'Content-Type': 'text/javascript'
          },
        }
      );
      this.logger.info('splitLoadFromNetwork num:' + (rsp.result as number));
      for (let i = 0; i < (rsp.result as number); i++) {
        const tmp = await httpRequest.request(
          uriString + '/get-pkg',
          {
            header: {
              'Content-Type': 'text/javascript',
              'pkg': i + '',
            },
          }
        );
        content = content + (tmp.result as string)
      }

      return content;
    } catch (err) {
      this.logger.error('Bundle load error: ' + JSON.stringify(err));
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }

  async downloadBundle(context: common.UIAbilityContext, uriString: string): Promise<string> {
    let filesDir = context.filesDir;
    let filePath = filesDir + '/js.bundle';
    console.info(`download js.bundle in ${filePath}`);
    const promise = new Promise<string>((resolve, reject) => {
      try {
        request.downloadFile(context, {
          url: uriString,
          filePath: filePath
        }).then((downloadTask) => {
          downloadTask.on('complete', () => {
            console.info('download complete');
            let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE);
            let buf = new ArrayBuffer(1024);
            let readLen = fs.readSync(file.fd, buf);
            const content = String.fromCharCode.apply(null, new Uint8Array(buf.slice(0, readLen)));
            console.log(`get js bundle length ${readLen}`);
            fs.closeSync(file);
            resolve(content);
          });
        }).catch((err) => {
          console.error(`Invoke downloadTask failed, code is ${err.code}, message is ${err.message}`);
          reject('');
        });
      } catch (err) {
        console.error(`Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
        reject('');
      }

    });
    return promise
  }

}