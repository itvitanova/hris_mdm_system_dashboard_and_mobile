import { test, expect } from "@playwright/test";
import { readFile } from "node:fs/promises";

test("payroll components, TER, formal PDF and final lock", async ({
  page,
}, info) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Payroll", exact: true })
    .click();
  await page.getByRole("button", { name: "Buat payroll", exact: true }).click();
  const dialog = page.getByRole("dialog");
  await dialog.getByLabel("Periode payroll").fill("2031-11");
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await page
    .getByLabel("Periode payroll", { exact: true })
    .selectOption("2031-11");
  const row = page.getByRole("row").filter({ hasText: "Nadia Putri" });
  await row.getByRole("button", { name: "Edit komponen", exact: true }).click();
  await expect(dialog.getByLabel("Tunjangan")).toHaveValue("0");
  await expect(dialog.getByLabel("Bonus")).toHaveValue("0");
  await dialog.getByLabel("Tunjangan").fill("1000000");
  await dialog.getByLabel("Bonus").fill("500000");
  await dialog.getByLabel("Status PTKP").selectOption("TK/0");
  await dialog
    .getByRole("button", { name: "Simpan komponen", exact: true })
    .click();
  await expect(dialog).not.toBeVisible();
  await expect(row).toContainText("9.013.750");
  await row.getByRole("button", { name: "Lihat slip", exact: true }).click();
  await expect(
    dialog.getByText("BPJS Kesehatan · 1% gaji pokok", { exact: true }),
  ).toBeVisible();
  await expect(dialog.getByText("166.250", { exact: false })).toBeVisible();
  await expect(dialog.getByText("Reimbursement", { exact: true })).toHaveCount(
    0,
  );
  await page.screenshot({
    path: "test-results/payroll-detailed.png",
    fullPage: true,
  });
  const pending = page.waitForEvent("download");
  await dialog
    .getByRole("button", { name: "Unduh slip PDF", exact: true })
    .click();
  const download = await pending;
  const path = info.outputPath("slip.pdf");
  await download.saveAs(path);
  expect((await readFile(path)).subarray(0, 5).toString()).toBe("%PDF-");
  await dialog
    .getByRole("button", { name: "Tutup dialog", exact: true })
    .click();
  await row.getByRole("button", { name: "Finalisasi", exact: true }).click();
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await expect(row.getByText("Final", { exact: true })).toBeVisible();
  await expect(
    row.getByRole("button", { name: "Edit komponen", exact: true }),
  ).toHaveCount(0);
});

test("December explicit manual PPh21, refund, Excel template and invalid import", async ({
  page,
}, info) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Payroll", exact: true })
    .click();
  await page.getByRole("button", { name: "Buat payroll", exact: true }).click();
  const dialog = page.getByRole("dialog");
  await dialog.getByLabel("Periode payroll").fill("2031-12");
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await page
    .getByLabel("Periode payroll", { exact: true })
    .selectOption("2031-12");
  const row = page.getByRole("row").filter({ hasText: "Nadia Putri" });
  await expect(
    row.getByRole("button", { name: "Finalisasi", exact: true }),
  ).toBeDisabled();
  await row.getByRole("button", { name: "Edit komponen", exact: true }).click();
  await expect(dialog.getByLabel("Tunjangan")).toHaveValue("0");
  await expect(dialog.getByLabel("Bonus")).toHaveValue("0");
  await dialog.getByLabel("Status PTKP").selectOption("K/1");
  await dialog.getByLabel("PPh21 periode ini").fill("-500000");
  await dialog
    .getByLabel("Catatan PPh21 manual")
    .fill("Pengembalian kelebihan potong tahun 2031");
  await dialog
    .getByRole("button", { name: "Simpan komponen", exact: true })
    .click();
  await expect(dialog).not.toBeVisible();
  await expect(row).toContainText("8.180.000");
  const pending = page.waitForEvent("download");
  await page
    .getByRole("button", { name: "Template Excel", exact: true })
    .click();
  const file = await pending;
  const path = info.outputPath("template.xlsx");
  await file.saveAs(path);
  expect((await readFile(path)).subarray(0, 2).toString()).toBe("PK");
  await page.getByRole("button", { name: "Impor PPh21", exact: true }).click();
  await dialog.getByLabel("File template terisi").setInputFiles(path);
  await dialog
    .getByRole("button", { name: "Impor PPh21", exact: true })
    .click();
  await expect(dialog.getByRole("alert")).toContainText("baris");
  await dialog.getByRole("button", { name: "Batal", exact: true }).click();
  await expect(row).toContainText("8.180.000");
  await row.getByRole("button", { name: "Lihat slip", exact: true }).click();
  await expect(
    dialog.getByText("PPh21 (pengembalian)", { exact: true }),
  ).toBeVisible();
  await page.setViewportSize({ width: 390, height: 844 });
  await page.screenshot({
    path: "test-results/payroll-mobile.png",
    fullPage: true,
  });
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= innerWidth,
    ),
  ).toBe(true);
});
