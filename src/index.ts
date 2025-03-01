import { instantiate, invoke } from '../build/main.mjs';
import mod from '../build/main.wasm';

const dartInstance = await instantiate(mod);

export default {
  async fetch(request: Request) {
    return executeDartWorker(request);
  },
};

async function executeDartWorker(request: Request) {
  return new Promise((resolve) => {
    globalThis.__dart_cf_workers = {
      request: () => request,
      response: (response) => resolve(response),
    };
    invoke(dartInstance, request);
  });
}

fetch;
