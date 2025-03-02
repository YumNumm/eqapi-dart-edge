import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '3s',
};

export default function () {
  http.get('http://localhost:8787/earthquake/list');
  sleep(1);
}
