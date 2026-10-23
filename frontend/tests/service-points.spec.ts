import { test, expect } from "@playwright/test";

test("service point coordinates, assignment, admin permission switch and map links", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Admin demo", exact: true }).click();
  const sidebar = page.locator(".sidebar");
  await sidebar
    .getByRole("button", { name: "Service Point / HQ", exact: true })
    .click();
  await page
    .getByRole("button", { name: "Tambah lokasi", exact: true })
    .click();
  const dialog = page.getByRole("dialog");
  await dialog.getByLabel("Kode").fill("SP-MKS");
  await dialog.getByLabel("Nama lokasi").fill("Makassar Service Point");
  await dialog.getByLabel("Latitude").fill("-5.147665");
  await dialog.getByLabel("Longitude").fill("119.432732");
  await dialog.getByLabel("Zona waktu").selectOption("Asia/Makassar");
  await dialog
    .getByRole("button", { name: "Simpan lokasi", exact: true })
    .click();
  await expect(dialog).not.toBeVisible();
  const row = page
    .getByRole("row")
    .filter({ hasText: "Makassar Service Point" });
  await expect(
    row.getByRole("link", { name: /Buka Google Maps/ }),
  ).toHaveAttribute("href", /query=-5.147665%2C119.432732/);
  await row
    .getByRole("button", { name: "Edit Makassar Service Point", exact: true })
    .click();
  await expect(dialog.getByLabel("Zona waktu")).toHaveValue("Asia/Makassar");
  await dialog.getByLabel("Radius absensi").fill("150");
  await dialog
    .getByRole("button", { name: "Simpan lokasi", exact: true })
    .click();
  await expect(dialog).not.toBeVisible();
  await sidebar.getByRole("button", { name: "Karyawan", exact: true }).click();
  await page
    .getByRole("button", { name: "Tambah karyawan", exact: true })
    .click();
  await dialog.getByLabel("Nama lengkap").fill("Service Point QA");
  await dialog.getByLabel("Email kantor").fill("servicepoint-qa@mdm.local");
  await dialog.getByLabel("Departemen").selectOption({ index: 1 });
  await dialog.getByLabel("Jabatan").selectOption({ index: 1 });
  await dialog
    .getByLabel("Service Point / HQ")
    .selectOption({ label: "Makassar Service Point (Service Point)" });
  await dialog.getByLabel("Status PTKP").selectOption("TK/0");
  const toggle = dialog.getByRole("switch");
  await expect(toggle).not.toBeChecked();
  await toggle.check();
  await dialog.getByRole("button", { name: "Simpan", exact: true }).click();
  await expect(dialog).not.toBeVisible();
  let workspace = await (await page.request.get("/api/workspace")).json();
  let emp = workspace.employees.find(
    (e: { email: string }) => e.email === "servicepoint-qa@mdm.local",
  );
  expect(emp.allowAnyLocation).toBe(true);
  expect(
    workspace.servicePoints.find(
      (p: { id: string }) => p.id === emp.servicePointId,
    ).code,
  ).toBe("SP-MKS");
  await expect(
    page.getByRole("columnheader", { name: "Service Point / HQ", exact: true }),
  ).toBeVisible();
  await expect(
    page
      .getByRole("row")
      .filter({ hasText: emp.email })
      .getByRole("cell", { name: "Makassar Service Point", exact: true }),
  ).toBeVisible();
  await page
    .getByLabel("Filter Service Point")
    .selectOption(emp.servicePointId);
  await expect(page.locator("tbody tr")).toHaveCount(1);
  await expect(page.getByText(emp.email, { exact: true })).toBeVisible();
  await page
    .getByLabel("Filter status", { exact: true })
    .selectOption("Nonaktif");
  await expect(
    page.getByText("Karyawan tidak ditemukan", { exact: true }),
  ).toBeVisible();
  await page
    .getByLabel("Filter status", { exact: true })
    .selectOption("Semua status");
  await expect(page.locator("tbody tr")).toHaveCount(1);
  await page.getByLabel("Filter Service Point").selectOption("HQ");
  await expect(page.getByText(emp.email, { exact: true })).toHaveCount(0);
  await expect(page.locator("tbody tr")).not.toHaveCount(0);
  await page.getByLabel("Filter Service Point").selectOption("");
  await expect(page.getByText(emp.email, { exact: true })).toBeVisible();
  await page.screenshot({
    path: "test-results/employee-service-point.png",
    fullPage: true,
  });
  await sidebar
    .getByRole("button", { name: "Service Point / HQ", exact: true })
    .click();
  await expect(
    row.getByRole("button", {
      name: "Hapus Makassar Service Point",
      exact: true,
    }),
  ).toBeDisabled();
  // Turning permission off is saved by the same admin-only employee endpoint.
  const response = await page.request.post("/api/employees", {
    data: { ...emp, allowAnyLocation: false },
  });
  expect(response.ok()).toBe(true);
  workspace = await (await page.request.get("/api/workspace")).json();
  emp = workspace.employees.find(
    (e: { email: string }) => e.email === "servicepoint-qa@mdm.local",
  );
  expect(emp.allowAnyLocation).toBe(false);
  await page.screenshot({
    path: "test-results/service-points.png",
    fullPage: true,
  });
});
