import http from 'k6/http';
import { check } from 'k6';

export let options = {
  thresholds: {
    checks: [{threshold: 'rate == 1.00', abortOnFail: true}],
  }
};

export default function () {
  const res = http.get('http://classicpress:80');
  
  check(res, {
    'page is accessible': (r) => r.status === 200,
    'installation page is visible': (r) => {
      return /<title>ClassicPress.*Installation2<\/title>/.test(r.body);
    },
  });
}
