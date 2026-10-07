// `npm run build`: vite build under a lock, so several people (or agents)
// building at once do not write inst/app/react/ui.js over each other.
import { mkdirSync, rmSync, statSync } from "node:fs";
import { spawnSync } from "node:child_process";

const lock = new URL("../.build-lock", import.meta.url);
const wait = (ms) => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);
for (let i = 0; ; i++) {
  try { mkdirSync(lock); break; } catch {
    // a lock older than 3 minutes was left by a build that died
    try { if (Date.now() - statSync(lock).mtimeMs > 180000) rmSync(lock, { recursive: true, force: true }); } catch { /* gone */ }
    if (i > 600) { console.error("build lock still held after 5 minutes"); process.exit(1); }
    wait(500);
  }
}
try {
  const r = spawnSync("npx", ["vite", "build", ...process.argv.slice(2)], { stdio: "inherit", shell: true });
  process.exitCode = r.status ?? 1;
} finally {
  rmSync(lock, { recursive: true, force: true });
}
