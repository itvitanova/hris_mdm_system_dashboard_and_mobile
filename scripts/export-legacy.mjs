// One-time migration utility only; the HRIS runtime uses PostgreSQL exclusively.
// Usage: node scripts/export-legacy.mjs > backend/data/legacy-export.json
import { DatabaseSync } from "node:sqlite";
const db = new DatabaseSync(process.argv[2] || "backend/data/hris.db", { readOnly: true });
try {
  const rows = db.prepare("SELECT collection,id,data FROM records ORDER BY collection,id").all();
  process.stdout.write(JSON.stringify(rows.map(row => ({ ...row, data: JSON.parse(typeof row.data === "string" ? row.data : Buffer.from(row.data).toString("utf8")) }))));
} finally { db.close(); }
