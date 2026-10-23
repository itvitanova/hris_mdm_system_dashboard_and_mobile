import { test, expect } from "@playwright/test";

test("admin dashboard, employee creation, inventory and payroll", async ({
  page,
}) => {
  const errors: string[] = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  await expect(
    page.getByRole("heading", { name: "Dashboard", exact: true }),
  ).toBeVisible();
  await expect(page.getByText("Selamat datang, Aditya")).toBeVisible();
  await page.screenshot({
    path: "test-results/dashboard-desktop.png",
    fullPage: true,
  });
  await page
    .getByRole("button", { name: "Tambah karyawan", exact: true })
    .click();
  const dialog = page.getByRole("dialog");
  await dialog.getByLabel("Nama lengkap").fill("Test Karyawan Baru");
  await dialog.getByLabel("Email kantor").fill("ui-test@mdm.local");
  await dialog.getByLabel("Departemen").selectOption({ label: "Engineering" });
  await dialog
    .getByLabel("Jabatan")
    .selectOption({ label: "Software Engineer" });
  await dialog.getByLabel("Gaji pokok").fill("9000000");
  await dialog.getByLabel("Status PTKP").selectOption("TK/0");
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Karyawan", exact: true })
    .click();
  await page
    .locator(".table-toolbar")
    .getByRole("textbox")
    .fill("Test Karyawan Baru");
  await expect(
    page.getByRole("button", { name: /Test Karyawan Baru ui-test/ }),
  ).toBeVisible();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "General Affair", exact: true })
    .click();
  await page.getByRole("button", { name: "Mutasi stok" }).first().click();
  await dialog.getByLabel("Jumlah").fill("2");
  await dialog.getByLabel("Catatan mutasi").fill("Penerimaan pengujian");
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await page
    .getByRole("button", { name: "Riwayat mutasi", exact: true })
    .click();
  await expect(page.getByText("Penerimaan pengujian")).toBeVisible();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Payroll", exact: true })
    .click();
  await page.getByRole("button", { name: "Buat payroll", exact: true }).click();
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  await expect(
    page.getByRole("button", { name: "Lihat slip" }).first(),
  ).toBeVisible();
  await page.getByRole("button", { name: "Lihat slip" }).first().click();
  await expect(
    dialog.getByText("Take-home pay", { exact: true }),
  ).toBeVisible();
  expect(errors).toEqual([]);
});

test("employee submits reimbursement, admin reviews it, employee cannot access colleagues", async ({
  page,
}) => {
  await page.goto("/");
  await page
    .getByRole("button", { name: "Karyawan demo", exact: true })
    .click();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Reimbursement", exact: true })
    .click();
  await page
    .getByRole("button", { name: "Buat pengajuan", exact: true })
    .click();
  const dialog = page.getByRole("dialog");
  await dialog.getByLabel("Judul pengajuan").fill("Transport E2E");
  await dialog.getByLabel("Nominal pengajuan").fill("150000");
  await dialog
    .getByLabel("Detail keperluan")
    .fill("Kunjungan klien, referensi kuitansi QA-001");
  await dialog
    .getByRole("button", { name: "Kirim pengajuan", exact: true })
    .click();
  await expect(dialog).not.toBeVisible();
  await expect(page.getByText("Transport E2E", { exact: true })).toBeVisible();
  const data = await page.request.get("/api/workspace");
  const body = await data.json();
  expect(body.employees).toHaveLength(1);
  expect(body.inventory).toEqual([]);
  expect(body.actor.role).toBe("employee");
  const forbidden = await page.request.post("/api/payroll/generate", {
    data: { period: "2026-01" },
  });
  expect(forbidden.status()).toBe(403);
  await page.getByRole("button", { name: "Keluar", exact: true }).click();
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Reimbursement", exact: true })
    .click();
  await page
    .getByRole("button", { name: "Setujui Transport E2E", exact: true })
    .click();
  await dialog.getByLabel("Catatan keputusan").fill("Bukti telah ditinjau");
  await dialog.getByRole("button", { name: "Simpan keputusan" }).click();
  await expect(dialog).not.toBeVisible();
  const row = page.getByRole("row").filter({ hasText: "Transport E2E" });
  await expect(row.getByText("Disetujui", { exact: true })).toBeVisible();
});

test("mobile portal fits viewport and face verification fails closed", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/?view=Mobile");
  await page
    .getByRole("button", { name: "Karyawan demo", exact: true })
    .click();
  await expect(
    page.getByRole("heading", { name: "Ruang karyawan", exact: true }),
  ).toBeVisible();
  await page.screenshot({
    path: "test-results/mobile-portal.png",
    fullPage: true,
  });
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= window.innerWidth,
    ),
  ).toBe(true);
  await page.getByRole("button", { name: "Absen dengan wajah" }).click();
  await expect(
    page.getByRole("dialog").getByText(/Layanan wajah belum terhubung/),
  ).toBeVisible();
  await expect(
    page.getByRole("button", { name: "Absen masuk", exact: true }),
  ).toBeDisabled();
  await page.getByRole("button", { name: "Tutup dialog" }).click();
  const manifest = await page.request.get("/manifest.webmanifest");
  expect(manifest.ok()).toBe(true);
  expect((await manifest.json()).display).toBe("standalone");
  expect((await page.request.get("/icons/icon-192.png")).ok()).toBe(true);
});
