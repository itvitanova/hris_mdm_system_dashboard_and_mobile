"use client";
import { useState, type FormEvent } from "react";
import {
  ArrowDownToLine,
  Plus,
  Wallet,
  FileText,
  ShieldCheck,
  Search,
  Pencil,
  Upload,
  Loader2,
  Building2,
  CalendarDays,
} from "lucide-react";
import { post, csv, rupiah, displayDate } from "@/lib/api";
import {
  ptkpOptions,
  taxCategory,
  downloadFile,
  readDataURL,
} from "@/lib/payroll";
import type { Payroll, Workspace } from "@/lib/types";
import type { FormState } from "./forms";
import { Avatar, Badge, Empty, Field, Modal } from "./common";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Textarea } from "./ui/textarea";

export function PayrollView({
  data,
  open,
  query,
  onQuery,
  onSaved,
}: {
  data: Workspace;
  open: (f: FormState) => void;
  query: string;
  onQuery: (q: string) => void;
  onSaved: (message: string) => Promise<void>;
}) {
  const [period, setPeriod] = useState("Semua periode"),
    [slipID, setSlipID] = useState(""),
    [editing, setEditing] = useState<Payroll | null>(null),
    [importing, setImporting] = useState(false),
    [error, setError] = useState("");
  const admin = data.actor.role === "admin";
  const rows = data.payroll.filter(
    (p) =>
      (period === "Semua periode" || p.period === period) &&
      p.employeeName.toLowerCase().includes(query.toLowerCase()),
  );
  const slip = data.payroll.find((p) => p.id === slipID);
  const eligible = data.payroll.some(
    (p) =>
      p.period === period &&
      p.status === "Draft" &&
      (period.endsWith("-12") || p.lastTaxPeriod),
  );
  async function download(path: string, name: string) {
    setError("");
    try {
      await downloadFile(path, name);
    } catch (e) {
      setError((e as Error).message);
    }
  }
  return (
    <>
      <div className="page-heading">
        <div>
          <div className="eyebrow">COMPENSATION & BENEFITS</div>
          <h1>Payroll</h1>
          <p>Rincian penghasilan, pajak, dan potongan yang transparan.</p>
        </div>
        {admin && (
          <div className="heading-actions">
            <Button onClick={() => open({ type: "payroll" })}>
              <Plus size={17} />
              Buat payroll
            </Button>
          </div>
        )}
      </div>
      <div className="notice blue">
        <ShieldCheck size={19} />
        <span>
          PPh21 Januari–November mengikuti PTKP dan TER. Desember/masa pajak
          terakhir diisi HR. Tunjangan dan bonus default Rp0; reimbursement
          dibayar terpisah.
        </span>
      </div>
      <div className="mini-stats three">
        {[
          {
            label: "Total take-home pay terpilih",
            value: rupiah(rows.reduce((s, p) => s + p.netSalary, 0)),
            icon: Wallet,
          },
          {
            label: "Slip draft",
            value: rows.filter((p) => p.status === "Draft").length,
            icon: FileText,
          },
          {
            label: "Perlu dilengkapi pajaknya",
            value: rows.filter((p) => p.status === "Draft" && !p.taxReady)
              .length,
            icon: ShieldCheck,
          },
        ].map(({ label, value, icon: Icon }) => (
          <div className="mini-stat" key={label}>
            <span className="stat-icon blue">
              <Icon size={20} />
            </span>
            <div>
              <span>{label}</span>
              <strong>{value}</strong>
            </div>
          </div>
        ))}
      </div>
      {error && (
        <div role="alert" className="error-message">
          {error}
        </div>
      )}
      <section className="panel">
        <div className="table-toolbar">
          <label className="search-box">
            <Search size={17} />
            <input
              value={query}
              onChange={(e) => onQuery(e.target.value)}
              aria-label="Cari nama karyawan"
              placeholder="Cari nama karyawan…"
            />
          </label>
          <div>
            <select
              aria-label="Periode payroll"
              value={period}
              onChange={(e) => setPeriod(e.target.value)}
            >
              <option>Semua periode</option>
              {[...new Set(data.payroll.map((p) => p.period))]
                .sort()
                .reverse()
                .map((p) => (
                  <option key={p}>{p}</option>
                ))}
            </select>
            <Button
              variant="outline"
              disabled={!rows.length}
              onClick={() =>
                csv(
                  "payroll.csv",
                  rows.map((p) => ({
                    IDKaryawan: p.employeeId,
                    Nama: p.employeeName,
                    Periode: p.period,
                    GajiPokok: p.baseSalary,
                    Tunjangan: p.allowance || 0,
                    Lembur: p.overtime,
                    Bonus: p.bonus || 0,
                    Bruto: p.grossSalary,
                    PTKP: p.ptkp,
                    KategoriTER: p.taxCategory,
                    PPh21: p.pph21,
                    BPJSKesehatan: p.bpjsHealth,
                    JHT: p.jht,
                    JP: p.jp,
                    TotalPotongan: p.deductions,
                    TakeHomePay: p.netSalary,
                    Status: p.status,
                  })),
                )
              }
            >
              <ArrowDownToLine size={16} />
              Ekspor CSV
            </Button>
          </div>
        </div>
        {admin && (
          <div className="tax-import-bar">
            <div>
              <strong>PPh21 masa pajak terakhir</strong>
              <span>
                Pilih satu periode, unduh template, lalu isi nominal PPh21 per
                karyawan.
              </span>
            </div>
            <Button
              variant="outline"
              size="sm"
              disabled={!eligible}
              onClick={() =>
                download(
                  `/payroll/tax-template?period=${period}`,
                  `template-pph21-${period}.xlsx`,
                )
              }
            >
              <ArrowDownToLine size={14} />
              Template Excel
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={!eligible}
              onClick={() => setImporting(true)}
            >
              <Upload size={14} />
              Impor PPh21
            </Button>
          </div>
        )}
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Karyawan</th>
                <th>Periode</th>
                <th>Total pendapatan</th>
                <th>Total potongan</th>
                <th>Take-home pay</th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((p) => (
                <tr key={p.id}>
                  <td>
                    <div className="person">
                      <Avatar name={p.employeeName} size="sm" />
                      <div>
                        <strong>{p.employeeName}</strong>
                        <span>{p.department}</span>
                      </div>
                    </div>
                  </td>
                  <td>
                    {p.period}
                    <span className="table-sub">
                      {p.ptkp || "PTKP belum diisi"}
                    </span>
                  </td>
                  <td>
                    {rupiah(
                      p.version >= 2
                        ? p.grossSalary
                        : p.baseSalary + p.overtime + p.reimbursement,
                    )}
                  </td>
                  <td>
                    {rupiah(p.deductions)}
                    {p.status === "Draft" && !p.taxReady && (
                      <span className="table-sub tax-pending">
                        PPh21 belum lengkap
                      </span>
                    )}
                  </td>
                  <td>
                    <strong>{rupiah(p.netSalary)}</strong>
                  </td>
                  <td>
                    <Badge>{p.status}</Badge>
                  </td>
                  <td>
                    <div className="inline-actions">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setSlipID(p.id)}
                      >
                        Lihat slip
                      </Button>
                      {admin && p.status === "Draft" && (
                        <>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setEditing(p)}
                          >
                            <Pencil size={13} />
                            Edit komponen
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            disabled={!p.taxReady}
                            title={
                              !p.taxReady
                                ? "Lengkapi PTKP dan PPh21 terlebih dahulu"
                                : "Finalisasi slip"
                            }
                            onClick={() =>
                              open({ type: "finalize", payroll: p })
                            }
                          >
                            Finalisasi
                          </Button>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!rows.length && (
          <Empty
            text="Belum ada payroll"
            description={
              admin
                ? "Buat draft payroll untuk periode yang dipilih."
                : "Slip tersedia setelah payroll dibuat oleh HR."
            }
          />
        )}
        <div className="panel-table-footer">
          {rows.length} slip · Angka draft belum final bila status pajak belum
          lengkap.
        </div>
      </section>
      {editing && (
        <PayrollEditor
          payroll={editing}
          onClose={() => setEditing(null)}
          onSaved={onSaved}
        />
      )}
      {importing && (
        <TaxImport
          period={period}
          onClose={() => setImporting(false)}
          onSaved={onSaved}
        />
      )}
      {slip && (
        <Modal
          title="Slip gaji"
          subtitle={`${slip.employeeName} · ${slip.period}`}
          onClose={() => setSlipID("")}
        >
          <div className="detailed-payslip">
            <div className="pay-company">
              {slip.companyLogo ? (
                <img src={slip.companyLogo} alt="Logo perusahaan" />
              ) : (
                <span className="stat-icon blue">
                  <Building2 size={23} />
                </span>
              )}
              <div>
                <h3>{slip.companyName || data.settings.company}</h3>
                {slip.companyAddress && <p>{slip.companyAddress}</p>}
              </div>
              <Badge>{slip.status}</Badge>
            </div>
            <div className="pay-identity">
              <div>
                <span>Karyawan</span>
                <strong>{slip.employeeName}</strong>
                <small>{slip.employeeId}</small>
              </div>
              <div>
                <span>Periode</span>
                <strong>{slip.period}</strong>
                <small>
                  {slip.department} · {slip.position}
                </small>
              </div>
            </div>
            {slip.version < 2 ? (
              <div className="notice amber">
                Slip historis menggunakan rincian versi sebelumnya.
              </div>
            ) : (
              <div className="pay-tax-meta">
                <span>
                  PTKP <strong>{slip.ptkp || "Belum diisi"}</strong>
                </span>
                <span>
                  Kategori TER <strong>{slip.taxCategory || "—"}</strong>
                </span>
                <span>
                  {!slip.taxReady
                    ? "PPh21 belum lengkap"
                    : slip.taxMode === "auto"
                      ? `TER ${(slip.taxRateBps / 100).toLocaleString("id-ID")}%`
                      : "PPh21 manual HR"}
                </span>
              </div>
            )}
            <div className="pay-section-title">Pendapatan</div>
            {[
              ["Gaji pokok", slip.baseSalary],
              ["Tunjangan", slip.allowance || 0],
              ["Lembur", slip.overtime],
              ["Bonus", slip.bonus || 0],
              ...(slip.version < 2
                ? [["Reimbursement historis", slip.reimbursement]]
                : []),
            ].map(([k, v]) => (
              <PayLine key={String(k)} label={String(k)} value={Number(v)} />
            ))}
            <PayLine
              label="Total pendapatan"
              value={
                slip.version >= 2
                  ? slip.grossSalary
                  : slip.baseSalary + slip.overtime + slip.reimbursement
              }
              total
            />
            <div className="pay-section-title">Potongan</div>
            {slip.version >= 2 ? (
              <>
                <PayLine
                  label={slip.pph21 < 0 ? "PPh21 (pengembalian)" : "PPh21"}
                  value={slip.pph21}
                  pending={!slip.taxReady}
                />
                <PayLine
                  label="BPJS Kesehatan · 1% gaji pokok"
                  value={slip.bpjsHealth}
                />
                <PayLine label="JHT · 2% gaji pokok" value={slip.jht} />
                <PayLine
                  label="Jaminan Pensiun (JP) · 1% gaji pokok"
                  value={slip.jp}
                />
              </>
            ) : null}
            <PayLine label="Total potongan" value={slip.deductions} total />
            <div className="pay-net">
              <span>Take-home pay</span>
              <strong>{rupiah(slip.netSalary)}</strong>
            </div>
            {!slip.taxReady && slip.version >= 2 && (
              <p className="notice amber">
                Lengkapi status PTKP dan PPh21 manual untuk masa pajak terakhir
                sebelum finalisasi. Take-home pay draft masih dapat berubah.
              </p>
            )}
            {slip.taxMode === "manual" && slip.taxNote && (
              <p className="form-note">Catatan PPh21: {slip.taxNote}</p>
            )}
            {slip.finalizedAt && (
              <p className="pay-finalized">
                Difinalkan {displayDate(slip.finalizedAt)} oleh{" "}
                {slip.finalizedBy}
              </p>
            )}
            <p className="pay-slip-foot">
              Dokumen elektronik ini merupakan rincian penghasilan dan tidak
              menggantikan bukti transfer.
            </p>
            <Button
              className="pay-download"
              onClick={() =>
                download(
                  `/payroll/${encodeURIComponent(slip.id)}/pdf`,
                  `slip-gaji-${slip.period}-${slip.employeeId}.pdf`,
                )
              }
            >
              <ArrowDownToLine size={17} />
              Unduh slip PDF
            </Button>
            {error && (
              <div role="alert" className="error-message">
                {error}
              </div>
            )}
          </div>
        </Modal>
      )}
    </>
  );
}
function PayLine({
  label,
  value,
  total = false,
  pending = false,
}: {
  label: string;
  value: number;
  total?: boolean;
  pending?: boolean;
}) {
  return (
    <div className={`pay-line ${total ? "pay-line-total" : ""}`}>
      <span>{label}</span>
      <strong className={value < 0 ? "text-green" : ""}>
        {pending ? "Belum diisi" : rupiah(value)}
      </strong>
    </div>
  );
}

function PayrollEditor({
  payroll: p,
  onClose,
  onSaved,
}: {
  payroll: Payroll;
  onClose: () => void;
  onSaved: (m: string) => Promise<void>;
}) {
  const [busy, setBusy] = useState(false),
    [error, setError] = useState(""),
    [allowance, setAllowance] = useState(p.allowance || 0),
    [bonus, setBonus] = useState(p.bonus || 0),
    [ptkp, setPTKP] = useState(p.ptkp || ""),
    [last, setLast] = useState(p.lastTaxPeriod || p.period.endsWith("-12")),
    [mode, setMode] = useState(p.taxMode || "auto");
  const manual = last || mode === "manual";
  async function save(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setBusy(true);
    setError("");
    const f = new FormData(e.currentTarget);
    try {
      await post(`/payroll/${encodeURIComponent(p.id)}/update`, {
        revision: p.revision,
        allowance,
        bonus,
        ptkp,
        taxMode: manual ? "manual" : "auto",
        manualPph21: manual ? Number(f.get("pph21")) : null,
        taxNote: manual ? String(f.get("taxNote") || "") : "",
        lastTaxPeriod: last,
      });
      await onSaved("Komponen payroll berhasil disimpan");
      onClose();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <Modal
      title="Edit komponen payroll"
      subtitle={`${p.employeeName} · ${p.period}`}
      onClose={() => {
        if (!busy) onClose();
      }}
    >
      <form onSubmit={save}>
        <div className="form-grid">
          <div className="form-summary full">
            <strong>
              Gaji pokok {rupiah(p.baseSalary)} · Lembur {rupiah(p.overtime)}
            </strong>
            <p>Diambil dari profil karyawan dan pengajuan lembur disetujui.</p>
          </div>
          <Field label="Tunjangan (Rp) *">
            <Input
              name="allowance"
              type="number"
              min="0"
              max="1000000000000"
              step="1"
              required
              value={allowance}
              onChange={(e) => setAllowance(Number(e.target.value))}
            />
          </Field>
          <Field label="Bonus (Rp) *">
            <Input
              name="bonus"
              type="number"
              min="0"
              max="1000000000000"
              step="1"
              required
              value={bonus}
              onChange={(e) => setBonus(Number(e.target.value))}
            />
          </Field>
          <div className="pay-edit-gross full">
            <span>Bruto pendapatan</span>
            <strong>
              {rupiah(p.baseSalary + p.overtime + allowance + bonus)}
            </strong>
          </div>
          <Field label="Status PTKP *">
            <select
              value={ptkp}
              required
              onChange={(e) => setPTKP(e.target.value)}
            >
              <option value="" disabled>
                Pilih PTKP
              </option>
              {ptkpOptions.map((s) => (
                <option key={s}>{s}</option>
              ))}
            </select>
          </Field>
          <Field label="Kategori TER">
            <Input readOnly value={taxCategory(ptkp) || "—"} />
          </Field>
          <label className="master-active-toggle full">
            <input
              type="checkbox"
              checked={last}
              disabled={p.period.endsWith("-12")}
              onChange={(e) => setLast(e.target.checked)}
            />
            <span>
              <strong>Masa pajak terakhir / karyawan berhenti</strong>
              <small>Desember otomatis memakai input PPh21 manual.</small>
            </span>
          </label>
          <Field label="Perhitungan PPh21" wide>
            <select
              value={manual ? "manual" : "auto"}
              disabled={last}
              onChange={(e) => setMode(e.target.value as "auto" | "manual")}
            >
              <option value="auto">Otomatis TER (Januari–November)</option>
              <option value="manual">Manual HR / koreksi</option>
            </select>
          </Field>
          {manual && (
            <>
              <Field label="PPh21 periode ini (Rp) *" wide>
                <Input
                  key={p.id}
                  type="number"
                  name="pph21"
                  step="1"
                  min={last ? "-1000000000000" : "0"}
                  max="1000000000000"
                  required
                  defaultValue={p.manualPph21 ?? ""}
                  placeholder="Isi 0 jika nihil; negatif untuk pengembalian"
                />
              </Field>
              <Field label="Catatan PPh21 manual *" wide>
                <Textarea
                  name="taxNote"
                  required
                  maxLength={1000}
                  rows={3}
                  defaultValue={p.taxNote}
                  placeholder="Alasan koreksi atau referensi perhitungan HR"
                />
              </Field>
            </>
          )}
          <p className="form-note full">
            PPh21 dihitung ulang saat disimpan. BPJS Kesehatan 1%, JHT 2%, dan
            JP 1% dari gaji pokok. Input tunjangan/bonus hanya berlaku untuk
            periode ini.
          </p>
        </div>
        {error && (
          <div className="error-message" role="alert">
            {error}
          </div>
        )}
        <footer className="modal-footer">
          <Button
            type="button"
            variant="outline"
            disabled={busy}
            onClick={onClose}
          >
            Batal
          </Button>
          <Button disabled={busy}>
            {busy && <Loader2 size={16} className="spin" />}Simpan komponen
          </Button>
        </footer>
      </form>
    </Modal>
  );
}
function TaxImport({
  period,
  onClose,
  onSaved,
}: {
  period: string;
  onClose: () => void;
  onSaved: (m: string) => Promise<void>;
}) {
  const [file, setFile] = useState<File | null>(null),
    [busy, setBusy] = useState(false),
    [error, setError] = useState("");
  async function submit(e: FormEvent) {
    e.preventDefault();
    if (!file) return;
    setBusy(true);
    setError("");
    try {
      if (file.size > 3 * 1024 * 1024) throw new Error("File maksimal 3 MB");
      const url = await readDataURL(file);
      const result = await post<{ count: number }>("/payroll/import-tax", {
        period,
        fileBase64: url.split(",")[1],
      });
      await onSaved(`${result.count} PPh21 berhasil diimpor`);
      onClose();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <Modal
      title="Impor PPh21 dari Excel"
      subtitle={`Periode ${period} · Masa pajak terakhir`}
      onClose={() => {
        if (!busy) onClose();
      }}
    >
      <form onSubmit={submit}>
        <p className="form-note">
          Gunakan template terbaru dari aplikasi. Isi PTKP, PPh21 periode ini
          (termasuk 0 bila nihil), dan catatan. Nilai negatif adalah
          pengembalian. Seluruh impor dibatalkan jika ada satu baris yang tidak
          valid atau revisi berubah.
        </p>
        <Field label="File template terisi (.xlsx) *" wide>
          <Input
            className="tax-file-input"
            type="file"
            accept=".xlsx"
            required
            onChange={(e) => setFile(e.target.files?.[0] || null)}
          />
        </Field>
        {error && (
          <div role="alert" className="error-message">
            {error}
          </div>
        )}
        <footer className="modal-footer">
          <Button
            variant="outline"
            type="button"
            disabled={busy}
            onClick={onClose}
          >
            Batal
          </Button>
          <Button disabled={busy || !file}>
            {busy && <Loader2 className="spin" size={16} />}Impor PPh21
          </Button>
        </footer>
      </form>
    </Modal>
  );
}
