"use client";
import { useState } from "react";
import { Download, FileSpreadsheet, Upload } from "lucide-react";
import { Button } from "./ui/button";
import { Modal } from "./common";
import { post } from "@/lib/api";
import { readDataURL } from "@/lib/payroll";
import { downloadRequest } from "./request-center";

type ImportResult = {
  valid: boolean;
  imported: number;
  rows: { row: number; name: string; email: string; error?: string }[];
};
export function EmployeeDataActions({
  onSaved,
}: {
  onSaved?: (message: string) => Promise<void>;
}) {
  const [open, setOpen] = useState(false),
    [busy, setBusy] = useState(false),
    [error, setError] = useState(""),
    [file, setFile] = useState<File | null>(null),
    [result, setResult] = useState<ImportResult | null>(null);
  async function download(template: boolean) {
    setError("");
    setBusy(true);
    try {
      await downloadRequest(
        `/employees/${template ? "template" : "export"}`,
        template
          ? "template-impor-karyawan.xlsx"
          : "data-karyawan-lengkap.xlsx",
      );
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  async function inspect(commit: boolean) {
    if (!file || busy) return;
    setBusy(true);
    setError("");
    try {
      if (
        !file.name.toLowerCase().endsWith(".xlsx") ||
        file.size > 2 * 1024 * 1024
      )
        throw new Error("Pilih file XLSX maksimal 2 MB.");
      const fileBase64 = (await readDataURL(file)).split(",")[1];
      const next = await post<ImportResult>("/employees/import", {
        fileBase64,
        commit,
      });
      setResult(next);
      if (next.imported) {
        await onSaved?.(`${next.imported} karyawan berhasil diimpor`);
        setOpen(false);
        setFile(null);
        setResult(null);
      }
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <>
      <Button
        variant="outline"
        disabled={busy}
        onClick={() => void download(false)}
      >
        <Download size={16} />
        Ekspor Excel
      </Button>
      <Button
        variant="outline"
        onClick={() => {
          setError("");
          setOpen(true);
        }}
      >
        <Upload size={16} />
        Impor karyawan
      </Button>
      {error && !open && (
        <span role="alert" className="error-message">
          {error}
        </span>
      )}
      {open && (
        <Modal
          title="Impor karyawan dari Excel"
          subtitle="Periksa seluruh baris sebelum menyimpan. Akun dan password tidak dibuat oleh impor."
          onClose={() => {
            if (!busy) setOpen(false);
          }}
        >
          <div className="employee-import-intro">
            <FileSpreadsheet size={26} />
            <div>
              <strong>Mulai dengan template terbaru</strong>
              <p>
                Template berisi kolom, aturan pengisian, dan referensi kode
                departemen, jabatan, lokasi serta ID atasan. Maksimal 500
                karyawan per file.
              </p>
            </div>
          </div>
          <Button
            variant="outline"
            disabled={busy}
            onClick={() => void download(true)}
          >
            <Download size={16} />
            Unduh template dan panduan
          </Button>
          <label className="field import-upload">
            <span>File karyawan (XLSX, maksimal 2 MB)</span>
            <input
              type="file"
              accept=".xlsx"
              disabled={busy}
              onChange={(e) => {
                setFile(e.target.files?.[0] || null);
                setResult(null);
                setError("");
              }}
            />
          </label>
          {result && (
            <section
              className="import-preview"
              aria-label="Hasil pemeriksaan impor"
            >
              <strong>
                {result.rows.length} baris diperiksa ·{" "}
                {result.rows.filter((r) => !!r.error).length} kesalahan
              </strong>
              <p>
                {result.valid
                  ? "Semua baris valid. Data siap ditambahkan."
                  : "Perbaiki file lalu periksa ulang. Belum ada karyawan yang ditambahkan."}
              </p>
              <ol>
                {result.rows.map((r) => (
                  <li key={r.row} className={r.error ? "has-error" : ""}>
                    <strong>
                      Baris {r.row} · {r.name || "Nama kosong"}
                    </strong>
                    <span>{r.error || r.email}</span>
                  </li>
                ))}
              </ol>
            </section>
          )}
          {error && (
            <p role="alert" className="error-message">
              {error}
            </p>
          )}
          <footer className="modal-footer">
            <Button
              variant="outline"
              disabled={busy}
              onClick={() => setOpen(false)}
            >
              Batal
            </Button>
            <Button
              variant="outline"
              disabled={!file || busy}
              onClick={() => void inspect(false)}
            >
              {busy ? "Memproses…" : "Periksa file"}
            </Button>
            <Button
              disabled={!result?.valid || busy}
              onClick={() => void inspect(true)}
            >
              Impor {result?.rows.length || 0} karyawan
            </Button>
          </footer>
        </Modal>
      )}
    </>
  );
}
