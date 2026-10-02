// Generates traffic against every configured target. Rates are randomized
// when the script is initialized, so each cycle (one `k6 run`) draws a new
// curve. Unreachable targets just fail requests until they come up, so the
// generator never depends on what it's pointed at being deployed first.
import http from 'k6/http';
import exec from 'k6/execution';

const config = JSON.parse(open('/etc/traffic-generator/config.json'));

function between(min, max) {
  return min + Math.random() * (max - min);
}

function stages(target) {
  const out = [];
  for (let i = 0; i < config.cycle.stages; i++) {
    const spike = Math.random() < target.spikeChance;
    const rate = Math.round(
      spike ? target.maxRate * config.cycle.spikeMultiplier : between(target.minRate, target.maxRate),
    );
    out.push({ target: rate, duration: config.cycle.rampDuration });
    out.push({ target: rate, duration: config.cycle.holdDuration });
  }
  return out;
}

const targets = Object.fromEntries(
  config.targets.map((t) => [t.name, { ...t, totalWeight: t.requests.reduce((sum, r) => sum + r.weight, 0) }]),
);

export const options = {
  discardResponseBodies: true,
  scenarios: Object.fromEntries(
    config.targets.map((t) => [
      t.name,
      {
        executor: 'ramping-arrival-rate',
        exec: 'hit',
        startRate: t.minRate,
        timeUnit: '1s',
        preAllocatedVUs: Math.min(5, t.maxVUs),
        maxVUs: t.maxVUs,
        stages: stages(t),
      },
    ]),
  ),
};

function pick(target) {
  let roll = Math.random() * target.totalWeight;
  for (const r of target.requests) {
    roll -= r.weight;
    if (roll < 0) return r;
  }
  return target.requests[target.requests.length - 1];
}

export function hit() {
  const target = targets[exec.scenario.name];
  const req = pick(target);
  http.request(req.method, target.url + req.path, null, {
    timeout: target.timeout,
    tags: { name: req.path },
  });
}
