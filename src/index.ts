import { instantiate, invoke } from '../build/main.mjs';
import mod from '../build/main.wasm';
// グローバルオブジェクトの型定義を追加
declare global {
  var __dart_cf_workers: {
    request: () => Request;
    response: (response: Response) => void;
    env: () => Env;
    ctx: () => ExecutionContext;
  };
}

const dartInstance = await instantiate(mod);

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<Response> {
    const start = performance.now();
    try {
      const result = await new Promise<Response>((resolve) => {
        globalThis.__dart_cf_workers = {
          request: () => request,
          response: (response: Response) => resolve(response),
          env: () => env,
          ctx: () => ctx,
        };
        invoke(dartInstance, request);
      });
      const end = performance.now();
      console.log(`Time taken: ${end - start} milliseconds`);
      return result;
    } catch (e) {
      console.error(e);
      return new Response('Internal Server Error', {
        status: 500,
      });
    }
  },
} satisfies ExportedHandler<Env>;
