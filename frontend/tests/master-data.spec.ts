import { choose } from "./choose";
import { test, expect } from "@playwright/test";

test("master submenu, CRUD, employee selections and reference protection", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  const sidebar = page.locator(".sidebar");
  const parent = sidebar.getByRole("button", {
    name: "Master Data",
    exact: true,
  });
  await expect(parent).toHaveAttribute("aria-expanded", "true");
  await parent.click();
  await expect(
    sidebar.getByRole("button", { name: "Departemen", exact: true }),
  ).not.toBeVisible();
  await parent.click();
  await sidebar
    .getByRole("button", { name: "Departemen", exact: true })
    .click();
  const dialog = page.getByRole("dialog");
  await page.getByRole("button", { name: "Tambah departemen" }).click();
  await dialog.getByLabel("Kode").fill("DEP-QA");
  await dialog.getByLabel("Nama departemen").fill("Quality Assurance");
  await dialog.getByLabel("Keterangan").fill("Tim pengujian");
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await sidebar.getByRole("button", { name: "Jabatan", exact: true }).click();
  await page.getByRole("button", { name: "Tambah jabatan" }).click();
  await dialog.getByLabel("Kode").fill("POS-QA");
  await dialog.getByLabel("Nama jabatan").fill("QA Specialist");
  await choose(dialog, "Departemen", { label: "Quality Assurance" });
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await sidebar.getByRole("button", { name: "Karyawan", exact: true }).click();
  await page
    .getByRole("button", { name: "Tambah karyawan", exact: true })
    .click();
  await dialog.getByLabel("Nama lengkap").fill("Master Reference QA");
  await dialog.getByLabel("Email kantor").fill("master-reference@mdm.local");
  await choose(dialog, "Hubungan kerja", "PKWT");
  await dialog.getByLabel("Nama bank").fill("Bank contoh");
  await dialog.getByLabel("Nama pemilik rekening").fill("Karyawan contoh");
  await dialog.getByLabel("Nomor rekening").fill("0012345678");
  await expect(
    dialog.getByRole("combobox", { name: /Jabatan/ }),
  ).toBeDisabled();
  await choose(dialog, "Departemen", { label: "Quality Assurance" });
  await choose(dialog, "Jabatan", { label: "QA Specialist" });
  await choose(dialog, "Status PTKP", "TK/0");
  await choose(dialog, "Service Point / HQ", "HQ");
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await sidebar
    .getByRole("button", { name: "Departemen", exact: true })
    .click();
  const row = page.getByRole("row").filter({ hasText: "Quality Assurance" });
  await expect(row.getByText("1 karyawan", { exact: true })).toBeVisible();
  await expect(
    row.getByRole("button", { name: "Hapus Quality Assurance", exact: true }),
  ).toBeDisabled();
  await row
    .getByRole("button", { name: "Edit Quality Assurance", exact: true })
    .click();
  await dialog.getByLabel("Nama departemen").fill("Quality & Testing");
  await dialog.getByRole("checkbox", { name: /^Aktif/ }).uncheck();
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await sidebar.getByRole("button", { name: "Karyawan", exact: true }).click();
  await page
    .locator(".table-toolbar")
    .getByRole("textbox")
    .fill("Master Reference QA");
  await expect(
    page.getByRole("cell", { name: "Quality & Testing", exact: true }),
  ).toBeVisible();
  await page
    .getByRole("button", { name: "Tambah karyawan", exact: true })
    .click();
  await dialog.getByRole("combobox", { name: /Departemen/ }).click();
  await expect(
    dialog.getByRole("option", { name: "Quality & Testing", exact: true }),
  ).toHaveCount(0);
  await dialog
    .getByRole("textbox", { name: /Cari departemen/ })
    .press("Escape");
  await dialog.getByRole("button", { name: "Batal", exact: true }).click();
  await sidebar.getByRole("button", { name: "Jabatan", exact: true }).click();
  await page.getByRole("button", { name: "Tambah jabatan" }).click();
  await dialog.getByLabel("Kode").fill("POS-TEMP");
  await dialog.getByLabel("Nama jabatan").fill("Temporary Role");
  await choose(dialog, "Departemen", { label: "Engineering" });
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await page
    .getByRole("button", { name: "Hapus Temporary Role", exact: true })
    .click();
  await dialog.getByRole("button", { name: "Hapus data", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await expect(page.getByText("Temporary Role", { exact: true })).toHaveCount(
    0,
  );
});

test("employee cannot view or mutate master data", async ({ page }) => {
  await page.goto("/");
  await page
    .getByRole("button", { name: "Karyawan demo", exact: true })
    .click();
  await expect(
    page.getByRole("heading", { name: "Dashboard", exact: true }),
  ).toBeVisible();
  await expect(
    page
      .locator(".sidebar")
      .getByRole("button", { name: "Master Data", exact: true }),
  ).toHaveCount(0);
  expect(
    (await page.request.get("/api/master-data/departments")).status(),
  ).toBe(403);
  expect(
    (
      await page.request.post("/api/master-data/positions", {
        data: { code: "BAD", name: "Unauthorized", active: true },
      })
    ).status(),
  ).toBe(403);
});
