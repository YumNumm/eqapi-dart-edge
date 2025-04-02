import { instantiate, invoke } from "../build/main.mjs";
import mod from "../build/main.wasm";

declare global {
  function __dart_cf_workers(): {
    request: Request;
    response: (response: Response) => void;
    env: Env;
    ctx: ExecutionContext;
  };
}

// dart wasmを保持
// リクエスト間で使い回す
// See: https://developers.cloudflare.com/workers/runtime-apis/webassembly/javascript/#use-from-javascript
let dartInstance: unknown | null = null;

export default {
  fetch: async (request: Request, env: Env, ctx: ExecutionContext) => {
    try {
      if (!dartInstance) {
        dartInstance = await instantiate(mod);
      }

      const result = await new Promise<Response>((resolve) => {
        globalThis.__dart_cf_workers = () => ({
          response: (response: Response) => resolve(response),
          request: request,
          env: env,
          ctx: ctx,
        });
        invoke(dartInstance, request, env, ctx);
      });
      return result;
    } catch (e) {
      console.error(e);
      return new Response("Internal Server Error", {
        status: 500,
      });
    }
  },
};
