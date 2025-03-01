import { instantiate, invoke } from '../build/main.mjs';
import mod from '../build/main.wasm';
import type {
  ExecutionContext,
  ExportedHandler,
  Response as CFResponse,
  Request as CFRequest,
} from '@cloudflare/workers-types';

const dartInstance = await instantiate(mod);

// グローバル型定義を追加
declare global {
  var __dart_cf_workers: {
    request: () => CFRequest;
    response: (response: Response) => void;
    env: () => Env;
    ctx: () => ExecutionContext;
  };
}

export default {
  async fetch(request: CFRequest, env, ctx): Promise<CFResponse> {
    return new Promise<CFResponse>((resolve) => {
      globalThis.__dart_cf_workers = {
        request: () => request,
        // biome-ignore lint/suspicious/noExplicitAny: <explanation>
        response: (response: any) => resolve(response as unknown as CFResponse),
        env: () => env,
        ctx: () => ctx,
      };
      invoke(dartInstance, request);
    });
  },
} satisfies ExportedHandler<Env>;
