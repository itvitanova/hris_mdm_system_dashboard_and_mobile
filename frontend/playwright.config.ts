import { defineConfig, devices } from "@playwright/test";
if (!process.env.TEST_DATABASE_URL) {
  throw new Error("Set TEST_DATABASE_URL to an isolated PostgreSQL test database before running Playwright.");
}
export default defineConfig({
  testDir: "./tests",
  fullyParallel: false,
  workers: 1,
  timeout: 60000,
  use: {
    baseURL: "http://localhost:3001",
    trace: "retain-on-failure",
    ...devices["Desktop Chrome"],
  },
  webServer: [
    {
      command: "go run ./cmd/api",
      cwd: "../backend",
      url: "http://127.0.0.1:8081/api/health",
      reuseExistingServer: false,
      timeout: 120000,
      env: {
        DEMO_SEED: "true",
        LISTEN_ADDR: "127.0.0.1:8081",
        DATABASE_URL: process.env.TEST_DATABASE_URL,
        DATABASE_SCHEMA: `test_e2e_${Date.now()}`,
        APP_ORIGIN: "http://localhost:3001",
      },
    },
    {
      command: "npm run dev -- --port 3001",
      url: "http://localhost:3001",
      reuseExistingServer: false,
      timeout: 120000,
      env: { API_URL: "http://127.0.0.1:8081", NEXT_DIST_DIR: ".next-e2e" },
    },
  ],
});
