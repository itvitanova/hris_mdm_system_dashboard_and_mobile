// Run from the repository root before starting the API on an empty PostgreSQL DB.
import { spawnSync } from "node:child_process";
import { writeFileSync } from "node:fs";

const exported = spawnSync(process.execPath, ["scripts/export-legacy.mjs", ...process.argv.slice(2)], { maxBuffer: 128 * 1024 * 1024 });
if (exported.status !== 0) {
  process.stderr.write(exported.stderr);
  process.exit(exported.status || 1);
}
writeFileSync("backend/data/legacy-export.json", exported.stdout, { mode: 0o600 });
const imported = spawnSync("docker", ["compose", "run", "--rm", "-T", "--no-deps", "backend", "hris-import"], {
  input: exported.stdout,
  maxBuffer: 1024 * 1024,
});
if (imported.stdout) process.stdout.write(imported.stdout);
if (imported.stderr) process.stderr.write(imported.stderr);
if (imported.error) process.stderr.write(imported.error.message + "\n");
process.exit(imported.status || (imported.error ? 1 : 0));
