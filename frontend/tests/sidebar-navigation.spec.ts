import { resolve } from "node:path";
import { test, expect } from "@playwright/test";

test("workspace groups approvals below leave and exposes settings once", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  const sidebar = page.locator(".sidebar");
  await expect(sidebar.locator(".workspace-selector")).toHaveCount(0);
  await expect(
    sidebar.getByText("Company workspace", { exact: true }),
  ).toHaveCount(0);
  const workspace = sidebar
    .locator(".nav-group")
    .filter({ has: page.locator(".nav-label", { hasText: /^WORKSPACE$/ }) });
  await expect(workspace.locator(".nav-item > span")).toHaveText([
    "Dashboard",
    "Karyawan",
    "Kehadiran",
    "Cuti",
    "Persetujuan",
    "Alur Persetujuan",
  ]);
  await expect(
    sidebar.getByRole("button", { name: "Pengaturan", exact: true }),
  ).toHaveCount(1);
  await sidebar
    .getByRole("button", { name: "Pengaturan", exact: true })
    .click();
  await expect(page).toHaveURL(/view=Pengaturan/);
  await page.screenshot({
    path: resolve(__dirname, "../../tmp/sidebar-workspace-admin.png"),
    fullPage: true,
  });
  await page.setViewportSize({ width: 390, height: 844 });
  await page.getByRole("button", { name: "Buka menu", exact: true }).click();
  await expect(
    workspace.getByRole("button", { name: "Alur Persetujuan", exact: true }),
  ).toBeVisible();
  await page.screenshot({
    path: resolve(__dirname, "../../tmp/sidebar-workspace-mobile.png"),
    fullPage: true,
  });
});

test("employee navigation keeps approvals restricted after regrouping", async ({
  page,
}) => {
  await page.goto("/");
  await page
    .getByRole("button", { name: "Karyawan demo", exact: true })
    .click();
  const sidebar = page.locator(".sidebar");
  const workspace = sidebar
    .locator(".nav-group")
    .filter({ has: page.locator(".nav-label", { hasText: /^WORKSPACE$/ }) });
  await expect(workspace.locator(".nav-item > span")).toHaveText([
    "Dashboard",
    "Profil saya",
    "Kehadiran",
    "Cuti",
  ]);
  await expect(
    sidebar.getByRole("button", { name: "Alur Persetujuan", exact: true }),
  ).toHaveCount(0);
  await expect(sidebar.locator(".workspace-selector")).toHaveCount(0);
});
