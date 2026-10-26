import { choose } from "./choose";
import { test, expect } from "@playwright/test";

test("admin configures a staged approval policy without granting approvers admin access", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  await page
    .locator(".sidebar")
    .getByRole("button", { name: "Alur Persetujuan", exact: true })
    .click();
  const policy = page
    .locator(".approval-request")
    .filter({
      has: page.getByRole("heading", { name: "Reimbursement", exact: true }),
    });
  await policy.getByLabel("Tingkat atasan").fill("2");
  await policy
    .getByRole("button", { name: "Simpan alur Reimbursement", exact: true })
    .click();
  await expect(
    page.getByText("Alur persetujuan disimpan", { exact: true }),
  ).toBeVisible();
  let data = await (await page.request.get("/api/workspace")).json();
  expect(
    data.approvalPolicies.find((p: { id: string }) => p.id === "Reimbursement")
      .stages[0].level,
  ).toBe(2);
  await policy.getByLabel("Tingkat atasan").fill("1");
  await policy
    .getByRole("button", { name: "Simpan alur Reimbursement", exact: true })
    .click();
  await expect
    .poll(async () => {
      data = await (await page.request.get("/api/workspace")).json();
      return data.approvalPolicies.find(
        (p: { id: string }) => p.id === "Reimbursement",
      ).stages[0].level;
    })
    .toBe(1);
  await page.screenshot({
    path: "test-results/approval-policy.png",
    fullPage: true,
  });
});

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
  await choose(dialog, "Hubungan kerja", "PKWT");
  await choose(dialog, "Departemen", { label: "Engineering" });
  await choose(dialog, "Jabatan", { label: "Software Engineer" });
  await choose(dialog, "Service Point / HQ", { index: 1 });
  await dialog.getByLabel("Gaji pokok").fill("9000000");
  await dialog.getByLabel("Nama bank", { exact: false }).fill("Bank contoh");
  await dialog.getByLabel("Nama pemilik rekening").fill("Test Karyawan Baru");
  await dialog.getByLabel("Nomor rekening").fill("0012345678");
  await choose(dialog, "Status PTKP", "TK/0");
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
  await dialog
    .getByLabel("Tanggal transaksi 1", { exact: true })
    .fill("2026-01-02");
  await dialog.getByLabel("Kategori 1", { exact: true }).fill("Transportasi");
  await dialog
    .getByLabel("Deskripsi 1", { exact: true })
    .fill("Kunjungan klien");
  await dialog.getByLabel("Jumlah 1", { exact: true }).fill("150000");
  await dialog.getByLabel("Bukti transaksi 1", { exact: true }).setInputFiles({
    name: "nota.pdf",
    mimeType: "application/pdf",
    buffer: Buffer.from("%PDF-1.4\nfixture"),
  });
  await expect(
    dialog.getByText("Bukti tersimpan", { exact: true }),
  ).toBeVisible();
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
  await expect(row.getByText("Menunggu", { exact: true })).toBeVisible();
  // Manager approval is not final: finance has a separate, scoped account.
  const finance = await page.context().newPage();
  await finance.request.post("/api/auth/logout");
  await finance.request.post("/api/auth/login", {
    data: { email: "karyawan15@mdm.local", password: "DemoHris2026!" },
  });
  await finance.goto("/?view=Persetujuan");
  const request = finance
    .locator(".approval-request")
    .filter({ hasText: "Transport E2E" });
  await expect(request).toBeVisible();
  await finance.screenshot({
    path: "test-results/finance-approval.png",
    fullPage: true,
  });
  await request
    .getByRole("button", { name: "Verifikasi finance", exact: true })
    .click();
  const review = finance.getByRole("dialog");
  await review
    .getByLabel("Catatan keputusan")
    .fill("Verifikasi finance lengkap");
  await review.getByRole("button", { name: "Simpan keputusan" }).click();
  await expect(review).not.toBeVisible();
  const finalData = await (await finance.request.get("/api/workspace")).json();
  const final = finalData.requests.find(
    (r: { title: string }) => r.title === "Transport E2E",
  );
  expect(final.status).toBe("Disetujui");
  expect(final.canDownload).toBe(true);
  expect(finalData.employees).toHaveLength(1);
  const file = await finance.request.get(
    `/api/requests/${final.id}/document/xlsx`,
  );
  expect(file.ok()).toBe(true);
  expect((await file.body()).length).toBeGreaterThan(10000);
  await finance.close();
});

test("mobile portal fits viewport and face verification fails closed", async ({
  page,
}) => {
  test.setTimeout(120000);
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/?view=Mobile");
  // Earlier tests share this server's IP-based login budget. Honor its real
  // one-minute rate limit while keeping the production protection enabled.
  await expect
    .poll(
      async () => {
        if (
          await page
            .getByRole("heading", { name: "Ruang karyawan", exact: true })
            .isVisible()
        )
          return true;
        const response = page.waitForResponse(
          (r) =>
            r.url().endsWith("/api/auth/login") &&
            r.request().method() === "POST",
        );
        await page
          .getByRole("button", { name: "Karyawan demo", exact: true })
          .click();
        return (await response).ok();
      },
      { timeout: 80000, intervals: [5000] },
    )
    .toBe(true);
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
