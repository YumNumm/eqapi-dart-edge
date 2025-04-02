import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 100,
  duration: '1m',
};

export default function () {
  const res = http.get(
    "https://earthquake-edge.yumnumm.dev/earthquake/list?limit=50"
  );
  check(res, {
    "is status 200": (r) => r.status === 200,
  });
}
