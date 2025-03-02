import { instantiate, invoke } from '../build/main.mjs';
import mod from '../build/main.wasm';
import { Hono, type ExecutionContext } from 'hono';
import { prettyJSON } from 'hono/pretty-json';
import { createMiddleware } from 'hono/factory';
import { csrf } from 'hono/csrf';
import { cors } from 'hono/cors';
import { etag } from 'hono/etag';
import { requestId } from 'hono/request-id';
import { secureHeaders } from 'hono/secure-headers';
import { timing, startTime, endTime } from 'hono/timing';
import type { TimingVariables } from 'hono/timing';
import { appendTrailingSlash } from 'hono/trailing-slash';
import { logger } from 'hono/logger';

declare global {
  var __dart_cf_workers: {
    request: () => Request;
    response: (response: Response) => void;
    env: () => Env;
    ctx: () => ExecutionContext;
  };
}

const app = new Hono<{ Bindings: Env; Variables: TimingVariables }>();

// dart wasmを保持
// リクエスト間で使い回す
// See: https://developers.cloudflare.com/workers/runtime-apis/webassembly/javascript/#use-from-javascript
let dartInstance: unknown | null = null;

// Honoのミドルウェアを適用
// いくらあってもいいですからね
// See: https://hono.dev/docs/#middleware-helpers
app.use(prettyJSON());
app.use(csrf());
app.use(cors());
app.use(etag());
app.use(requestId());
app.use(secureHeaders());
app.use(timing());
app.use(appendTrailingSlash());
app.use(logger());

const dartInstanceMiddleware = createMiddleware(async (c, next) => {
  c.res.headers.append('X-Dart-Instance', 'true');
  c.res.headers.append('X-Dart-Initialize', dartInstance === null ? 'true' : 'false');
  if (!dartInstance) {
    startTime(c, 'dartInstance');
    dartInstance = await instantiate(mod);
    endTime(c, 'dartInstance');
  }
  await next();
});

app.all('*', dartInstanceMiddleware, async (c) => {
  startTime(c, 'dartInvoke');
  try {
    const result = await new Promise<Response>((resolve) => {
      globalThis.__dart_cf_workers = {
        request: () => c.req.raw,
        response: (response: Response) => resolve(response),
        env: () => c.env,
        ctx: () => c.executionCtx,
      };
      invoke(dartInstance);
    });
    endTime(c, 'dartInvoke');
    return result;
  } catch (e) {
    console.error(e);
    return new Response('Internal Server Error', {
      status: 500,
    });
  }
});

export default app;
