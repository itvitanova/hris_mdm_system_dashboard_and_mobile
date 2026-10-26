import { test, expect } from "@playwright/test";
import { choose } from "./choose";

test("employee import and complete XLSX export explain validation without saving bad input", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Karyawan", exact: true })
    .click();
  const original = (await (await page.request.get("/api/workspace")).json())
    .employees.length;
  const exported = page.waitForEvent("download");
  await page.getByRole("button", { name: "Ekspor Excel", exact: true }).click();
  expect((await exported).suggestedFilename()).toBe(
    "data-karyawan-lengkap.xlsx",
  );
  await page
    .getByRole("button", { name: "Impor karyawan", exact: true })
    .click();
  const dialog = page.getByRole("dialog");
  const template = page.waitForEvent("download");
  await dialog
    .getByRole("button", { name: "Unduh template dan panduan" })
    .click();
  expect((await template).suggestedFilename()).toBe(
    "template-impor-karyawan.xlsx",
  );
  await dialog
    .getByLabel(/File karyawan/)
    .setInputFiles({
      name: "invalid.xlsx",
      mimeType:
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      buffer: Buffer.from("invalid workbook"),
    });
  await dialog
    .getByRole("button", { name: "Periksa file", exact: true })
    .click();
  await expect(dialog.getByRole("alert")).toContainText(
    "XLSX tidak dapat dibaca",
  );
  expect(
    (await (await page.request.get("/api/workspace")).json()).employees.length,
  ).toBe(original);
  await dialog.getByRole("button", { name: "Batal", exact: true }).click();
  await page
    .getByRole("button", { name: "Tambah karyawan", exact: true })
    .click();
  await expect(
    dialog.getByRole("combobox", { name: /Jabatan/ }),
  ).toBeDisabled();
  await choose(dialog, "Departemen", "Engineering");
  await dialog.getByRole("combobox", { name: /Jabatan/ }).click();
  await expect(
    dialog.getByRole("option", { name: "Software Engineer", exact: true }),
  ).toBeVisible();
  await expect(
    dialog.getByRole("option", { name: "Finance Analyst", exact: true }),
  ).toHaveCount(0);
  await dialog.getByRole("textbox", { name: /Cari jabatan/ }).press("Escape");
  await page.screenshot({
    path: "../tmp/web-employee-search.png",
    fullPage: true,
  });
});

test("reimbursement follows active finance, previews evidence, filters month and fits a narrow detail dialog", async ({
  page,
  playwright,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  const employee = await playwright.request.newContext({
    baseURL: "http://localhost:3001",
    extraHTTPHeaders: { Origin: "http://localhost:3001" },
  });
  try {
    expect(
      (
        await employee.post("/api/auth/login", {
          data: { email: "nadia@mdm.local", password: "DemoHris2026!" },
        })
      ).ok(),
    ).toBeTruthy();
    const workspace = await (await employee.get("/api/workspace")).json();
    const day = workspace.attendanceDate;
    const upload = await employee.post("/api/request-receipts", {
      data: {
        name: "bukti-contoh.png",
        fileBase64:
          "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aE1sAAAAASUVORK5CYII=",
      },
    });
    expect(upload.ok()).toBeTruthy();
    const proof = await upload.json();
    const title = "Reimbursement bukti pilot " + Date.now();
    const created = await employee.post("/api/requests", {
      data: {
        kind: "Reimbursement",
        title,
        description: "Kunjungan kantor contoh",
        startDate: day,
        endDate: day,
        items: [
          {
            date: day,
            description: "Parkir kantor",
            category: "Transportasi",
            amount: 25000,
            receiptId: proof.id,
          },
        ],
      },
    });
    expect(created.ok()).toBeTruthy();
    const own = (
      await (await employee.get("/api/workspace")).json()
    ).requests.find((r: { title: string }) => r.title === title);
    expect(
      (
        await page.request.post(`/api/requests/${own.id}/review`, {
          data: {
            status: "Disetujui",
            note: "Bukti sesuai",
            revision: own.revision,
          },
        })
      ).ok(),
    ).toBeTruthy();
    await page.reload();
    await page
      .locator(".sidebar")
      .getByRole("button", { name: "Reimbursement", exact: true })
      .click();
    const row = page.getByRole("row").filter({ hasText: title });
    await expect(row).toContainText("Menunggu verifikasi finance");
    await row
      .getByRole("button", { name: "Rincian dan dokumen", exact: true })
      .click();
    const details = page.getByRole("dialog", {
      name: "Rincian dan dokumen",
      exact: true,
    });
    await expect(
      details.getByRole("heading", {
        name: "Rincian pengeluaran",
        exact: true,
      }),
    ).toBeVisible();
    await details
      .getByRole("button", { name: "Lihat bukti transaksi 1" })
      .click();
    const preview = page.getByRole("dialog", {
      name: "Bukti transaksi",
      exact: true,
    });
    await expect(
      preview.getByRole("img", {
        name: "Bukti transaksi yang diunggah pemohon",
      }),
    ).toBeVisible();
    await preview.getByRole("button", { name: "Tutup dialog" }).click();
    await page.setViewportSize({ width: 390, height: 844 });
    await expect(details.locator(".request-details")).toBeVisible();
    expect(
      await details.evaluate((d) => d.scrollWidth <= d.clientWidth + 1),
    ).toBeTruthy();
    await page.screenshot({
      path: "../tmp/web-reimbursement-detail-390.png",
      fullPage: true,
    });
    await details.getByRole("button", { name: "Tutup dialog" }).click();
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.getByLabel("Bulan pengajuan").fill("2099-01");
    await expect(row).toHaveCount(0);
    await page.getByLabel("Bulan pengajuan").fill(day.slice(0, 7));
    await expect(row).toBeVisible();
  } finally {
    await employee.dispose();
  }
});
