"use client";
import { useState, type FormEvent } from "react";
import { AlertCircle, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Field, Modal } from "./common";
import { api, post, localDate } from "@/lib/api";
import { ptkpOptions, readDataURL } from "@/lib/payroll";
import type {
  Employee,
  HRRequest,
  Inventory,
  Payroll,
  Workspace,
} from "@/lib/types";
export type FormState = {
  type:
    | "employee"
    | "request"
    | "item"
    | "stock"
    | "payroll"
    | "finalize"
    | "account"
    | "review";
  employee?: Employee;
  kind?: string;
  item?: Inventory;
  payroll?: Payroll;
  request?: HRRequest;
  decision?: string;
};
const kinds = [
  "Cuti",
  "Reimbursement",
  "Petty Cash",
  "General Affair",
  "Lembur",
];
export function Forms({
  form,
  data,
  onClose,
  onSaved,
}: {
  form: FormState;
  data: Workspace;
  onClose: () => void;
  onSaved: (message: string) => Promise<void>;
}) {
  const [busy, setBusy] = useState(false),
    [error, setError] = useState(""),
    [kind, setKind] = useState(form.kind || "Cuti");
  const titles = {
    employee: form.employee ? "Edit data karyawan" : "Tambah karyawan",
    request: "Buat pengajuan",
    item: "Tambah barang",
    stock: "Catat mutasi stok",
    payroll: "Buat draft payroll",
    finalize: "Finalisasi payroll",
    account: "Buat akun karyawan",
    review: `${form.decision === "Disetujui" ? "Setujui" : "Tolak"} pengajuan`,
  };
  async function submit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setBusy(true);
    setError("");
    const f = new FormData(e.currentTarget);
    const str = (key: string) => String(f.get(key) || "");
    const num = (key: string) => Number(f.get(key) || 0);
    try {
      switch (form.type) {
        case "employee":
          await post("/employees", {
            id: form.employee?.id || "",
            name: str("name"),
            email: str("email"),
            departmentId: str("departmentId"),
            positionId: str("positionId"),
            servicePointId: str("servicePointId"),
            allowAnyLocation: f.get("allowAnyLocation") === "on",
            status: str("status"),
            phone: str("phone"),
            address: str("address"),
            birthDate: str("birthDate"),
            joinDate: str("joinDate"),
            salary: num("salary"),
            ptkp: str("ptkp"),
            leaveBalance: num("leaveBalance"),
            faceEnrolled: false,
          });
          break;
        case "request":
          await post("/requests", {
            kind,
            title: str("title"),
            description: str("description"),
            startDate: str("startDate"),
            endDate: str("endDate"),
            amount: num("amount"),
            hours: num("hours"),
          });
          break;
        case "item":
          await post("/inventory", {
            name: str("name"),
            category: str("category"),
            unit: str("unit"),
            stock: num("stock"),
            minimum: num("minimum"),
          });
          break;
        case "stock":
          await post(`/inventory/${form.item?.id}/adjust`, {
            quantity: num("quantity") * (str("direction") === "out" ? -1 : 1),
            note: str("note"),
          });
          break;
        case "payroll":
          await post("/payroll/generate", { period: str("period") });
          break;
        case "finalize":
          await post(`/payroll/${form.payroll?.id}/finalize`, {
            revision: form.payroll?.revision,
          });
          break;
        case "account":
          await post("/accounts", {
            employeeId: form.employee?.id,
            password: str("password"),
            role: str("role"),
          });
          break;
        case "review":
          await post(`/requests/${form.request?.id}/review`, {
            status: form.decision,
            note: str("note"),
          });
          break;
      }
      await onSaved(
        form.type === "request"
          ? "Pengajuan berhasil dikirim"
          : form.type === "review"
            ? "Keputusan berhasil disimpan"
            : "Data berhasil disimpan",
      );
      onClose();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Gagal menyimpan data");
    } finally {
      setBusy(false);
    }
  }
  const emp = form.employee;
  return (
    <Modal
      title={titles[form.type]}
      subtitle="Lengkapi informasi berikut. Tanda * wajib diisi."
      onClose={() => {
        if (!busy) onClose();
      }}
    >
      <form onSubmit={submit}>
        <div className="form-grid">
          {form.type === "employee" && (
            <>
              <Field label="Nama lengkap *">
                <Input
                  name="name"
                  required
                  defaultValue={emp?.name}
                  placeholder="Nama sesuai identitas"
                  maxLength={120}
                />
              </Field>
              <Field label="Email kantor *">
                <Input
                  name="email"
                  type="email"
                  required
                  defaultValue={emp?.email}
                  placeholder="nama@perusahaan.com"
                />
              </Field>
              <Field label="Departemen *">
                <select
                  name="departmentId"
                  required
                  defaultValue={emp?.departmentId || ""}
                >
                  <option value="" disabled>
                    Pilih departemen
                  </option>
                  {(data.masterData.departments || [])
                    .filter((d) => d.active || d.id === emp?.departmentId)
                    .map((d) => (
                      <option key={d.id} value={d.id}>
                        {d.name}
                        {!d.active ? " (nonaktif)" : ""}
                      </option>
                    ))}
                </select>
              </Field>
              <Field label="Jabatan *">
                <select
                  name="positionId"
                  required
                  defaultValue={emp?.positionId || ""}
                >
                  <option value="" disabled>
                    Pilih jabatan
                  </option>
                  {(data.masterData.positions || [])
                    .filter((p) => p.active || p.id === emp?.positionId)
                    .map((p) => (
                      <option key={p.id} value={p.id}>
                        {p.name}
                        {!p.active ? " (nonaktif)" : ""}
                      </option>
                    ))}
                </select>
              </Field>
              {(!(data.masterData.departments || []).some((d) => d.active) ||
                !(data.masterData.positions || []).some((p) => p.active)) && (
                <p className="form-note full">
                  Tambahkan departemen dan jabatan aktif melalui menu Master
                  Data terlebih dahulu.
                </p>
              )}
              <Field label="Service Point / HQ *" wide>
                <select
                  name="servicePointId"
                  required
                  defaultValue={emp?.servicePointId || ""}
                >
                  <option value="" disabled>
                    Pilih lokasi penugasan
                  </option>
                  {(data.servicePoints || [])
                    .filter((p) => p.active || p.id === emp?.servicePointId)
                    .map((p) => (
                      <option key={p.id} value={p.id}>
                        {p.name} ({p.kind}){!p.active ? " - nonaktif" : ""}
                      </option>
                    ))}
                </select>
              </Field>
              <label className="attendance-permission-switch full">
                <input
                  type="checkbox"
                  role="switch"
                  name="allowAnyLocation"
                  defaultChecked={emp?.allowAnyLocation ?? false}
                />
                <span>
                  <strong>Izinkan absensi dari lokasi mana saja</strong>
                  <small>
                    Default nonaktif: wajib di lokasi penugasan. Jika aktif, GPS
                    aktual masuk dan keluar tetap dicatat dan wajah tetap
                    diverifikasi.
                  </small>
                </span>
              </label>
              <Field label="Nomor telepon">
                <Input
                  name="phone"
                  type="tel"
                  defaultValue={emp?.phone}
                  placeholder="08xx xxxx xxxx"
                />
              </Field>
              <Field label="Status">
                <select name="status" defaultValue={emp?.status || "Aktif"}>
                  <option>Aktif</option>
                  <option>Probation</option>
                  <option>Nonaktif</option>
                </select>
              </Field>
              <Field label="Tanggal lahir">
                <Input
                  name="birthDate"
                  type="date"
                  defaultValue={emp?.birthDate}
                />
              </Field>
              <Field label="Tanggal bergabung">
                <Input
                  name="joinDate"
                  type="date"
                  defaultValue={emp?.joinDate}
                />
              </Field>
              <Field label="Gaji pokok (Rp) *">
                <Input
                  name="salary"
                  type="number"
                  min="0"
                  max="1000000000000"
                  required
                  defaultValue={emp?.salary || 0}
                />
              </Field>
              <Field label="Saldo cuti (hari) *">
                <Input
                  name="leaveBalance"
                  type="number"
                  min="0"
                  max="365"
                  required
                  defaultValue={emp?.leaveBalance ?? 12}
                />
              </Field>
              <Field label="Status PTKP *" wide>
                <select name="ptkp" required defaultValue={emp?.ptkp || ""}>
                  <option value="" disabled>
                    Pilih status PTKP untuk PPh21
                  </option>
                  {ptkpOptions.map((status) => (
                    <option key={status}>{status}</option>
                  ))}
                </select>
              </Field>
              <Field label="Alamat tempat tinggal" wide>
                <Textarea name="address" defaultValue={emp?.address} rows={2} />
              </Field>
              {!emp && (
                <p className="form-note full">
                  Setelah tersimpan, buka detail karyawan untuk membuat akun dan
                  mendaftarkan wajah.
                </p>
              )}
            </>
          )}
          {form.type === "request" && (
            <>
              <Field label="Jenis pengajuan *" wide>
                <select value={kind} onChange={(e) => setKind(e.target.value)}>
                  {kinds.map((k) => (
                    <option key={k}>{k}</option>
                  ))}
                </select>
              </Field>
              <Field label="Judul pengajuan *" wide>
                <Input
                  name="title"
                  required
                  maxLength={160}
                  placeholder={
                    kind === "Cuti"
                      ? "Contoh: Cuti keperluan keluarga"
                      : "Ringkasan keperluan Anda"
                  }
                />
              </Field>
              <Field label="Tanggal mulai *">
                <Input
                  name="startDate"
                  type="date"
                  required
                  defaultValue={localDate(data.settings.timezone)}
                />
              </Field>
              <Field label="Tanggal selesai *">
                <Input
                  name="endDate"
                  type="date"
                  required
                  defaultValue={localDate(data.settings.timezone)}
                />
              </Field>
              {(kind === "Reimbursement" || kind === "Petty Cash") && (
                <Field label="Nominal pengajuan (Rp) *" wide>
                  <Input
                    name="amount"
                    type="number"
                    min="1"
                    max="1000000000000"
                    required
                    placeholder="0"
                  />
                </Field>
              )}
              {kind === "Lembur" && (
                <Field label="Durasi lembur (jam) *" wide>
                  <Input
                    name="hours"
                    type="number"
                    min="0.5"
                    max="24"
                    step="0.5"
                    required
                    placeholder="Contoh: 2"
                  />
                </Field>
              )}
              <Field label="Detail keperluan / referensi bukti *" wide>
                <Textarea
                  name="description"
                  required
                  rows={4}
                  maxLength={3000}
                  placeholder="Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung…"
                />
              </Field>
              <p className="form-note full">
                {kind === "Cuti"
                  ? "Cuti dihitung per hari kalender, termasuk akhir pekan. Saldo dipotong setelah disetujui."
                  : kind === "Lembur"
                    ? "Gunakan tanggal mulai dan selesai yang sama. Buat pengajuan terpisah untuk hari berbeda."
                    : "Pengajuan dikirim ke admin untuk ditinjau. Persetujuan tidak otomatis melakukan pembayaran atau mengeluarkan stok."}
              </p>
            </>
          )}
          {form.type === "item" && (
            <>
              <Field label="Nama barang *" wide>
                <Input
                  name="name"
                  required
                  placeholder="Contoh: Kertas A4 80 gsm"
                />
              </Field>
              <Field label="Kategori *">
                <select name="category">
                  <option>Alat tulis</option>
                  <option>Pantry</option>
                  <option>Kebersihan</option>
                  <option>Lainnya</option>
                </select>
              </Field>
              <Field label="Satuan *">
                <Input name="unit" required placeholder="rim, box, pak…" />
              </Field>
              <Field label="Stok awal *">
                <Input
                  name="stock"
                  type="number"
                  min="0"
                  max="1000000"
                  required
                  defaultValue={0}
                />
              </Field>
              <Field label="Stok minimum *">
                <Input
                  name="minimum"
                  type="number"
                  min="0"
                  max="1000000"
                  required
                  defaultValue={5}
                />
              </Field>
            </>
          )}
          {form.type === "stock" && (
            <>
              <div className="form-summary full">
                <strong>{form.item?.name}</strong>
                <p>
                  Stok saat ini: {form.item?.stock} {form.item?.unit}
                </p>
              </div>
              <Field label="Jenis mutasi *">
                <select name="direction">
                  <option value="in">Barang masuk</option>
                  <option value="out">Barang keluar</option>
                </select>
              </Field>
              <Field label="Jumlah *">
                <Input
                  name="quantity"
                  type="number"
                  min="1"
                  max="1000000"
                  required
                />
              </Field>
              <Field label="Catatan mutasi *" wide>
                <Textarea
                  name="note"
                  rows={3}
                  required
                  placeholder="Keperluan / nomor referensi penerimaan"
                />
              </Field>
            </>
          )}
          {form.type === "payroll" && (
            <>
              <Field label="Periode payroll *" wide>
                <Input
                  name="period"
                  type="month"
                  required
                  defaultValue={localDate(data.settings.timezone).slice(0, 7)}
                />
              </Field>
              <div className="form-note full">
                Gaji pokok dan lembur disetujui diambil otomatis. Tunjangan dan
                bonus mulai dari Rp0 per periode. Potongan BPJS Kesehatan 1%,
                JHT 2%, dan JP 1% dari gaji pokok. PPh21 mengikuti PTKP dan TER;
                Desember/masa pajak terakhir diisi manual. Reimbursement dibayar
                di luar payroll. Menghitung ulang periode yang sama
                mempertahankan input HR pada draft; periode dengan slip final
                dikunci.
              </div>
            </>
          )}
          {form.type === "finalize" && (
            <>
              <div className="form-summary full">
                <strong>{form.payroll?.employeeName}</strong>
                <p>
                  Periode {form.payroll?.period}. Pastikan seluruh komponen
                  telah ditinjau.
                </p>
              </div>
              <div className="form-summary full">
                <strong>
                  Take-home pay:{" "}
                  {new Intl.NumberFormat("id-ID", {
                    style: "currency",
                    currency: "IDR",
                    maximumFractionDigits: 0,
                  }).format(form.payroll?.netSalary || 0)}
                </strong>
                <p>
                  PPh21, BPJS Kesehatan, JHT, dan JP telah diperinci pada slip.
                  Gunakan Edit komponen untuk koreksi sebelum finalisasi.
                </p>
              </div>
              <p className="form-note full">
                Finalisasi mengunci slip. Aksi ini mencatat payroll dan tidak
                mentransfer dana.
              </p>
            </>
          )}
          {form.type === "account" && (
            <>
              <div className="form-summary full">
                <strong>{emp?.name}</strong>
                <p>Email masuk: {emp?.email}</p>
              </div>
              <Field label="Kata sandi awal (minimal 12 karakter) *" wide>
                <Input
                  name="password"
                  type="password"
                  required
                  minLength={12}
                  autoComplete="new-password"
                />
              </Field>
              <Field label="Peran akses *" wide>
                <select name="role">
                  <option value="employee">Karyawan</option>
                  <option value="admin">Administrator HR</option>
                </select>
              </Field>
              <p className="form-note full">
                Admin dapat mengakses seluruh data HR dan payroll. Sampaikan
                kata sandi melalui kanal internal yang aman.
              </p>
            </>
          )}
          {form.type === "review" && (
            <>
              <div className="form-summary full">
                <strong>{form.request?.title}</strong>
                <p>
                  {form.request?.employeeName} · {form.request?.kind}
                </p>
                <p>{form.request?.description}</p>
              </div>
              <Field label="Catatan keputusan" wide>
                <Textarea
                  name="note"
                  rows={3}
                  placeholder="Tambahkan catatan untuk karyawan…"
                />
              </Field>
            </>
          )}
        </div>
        {error && (
          <div role="alert" className="error-message">
            <AlertCircle size={17} />
            {error}
          </div>
        )}
        <footer className="modal-footer">
          <Button
            variant="outline"
            type="button"
            onClick={onClose}
            disabled={busy}
          >
            Batal
          </Button>
          <Button type="submit" disabled={busy}>
            {busy && <Loader2 className="spin" size={16} />}{" "}
            {form.type === "request"
              ? "Kirim pengajuan"
              : form.type === "review"
                ? "Simpan keputusan"
                : "Simpan"}
          </Button>
        </footer>
      </form>
    </Modal>
  );
}
export function SettingsForm({
  data,
  onSaved,
}: {
  data: Workspace;
  onSaved: (message: string) => Promise<void>;
}) {
  const [busy, setBusy] = useState(false),
    [error, setError] = useState(""),
    [logo, setLogo] = useState(data.settings.companyLogo || "");
  async function submit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setBusy(true);
    setError("");
    const f = new FormData(e.currentTarget);
    try {
      await api("/settings", {
        method: "PUT",
        body: JSON.stringify({
          ...data.settings,
          company: f.get("company"),
          companyAddress: f.get("companyAddress"),
          companyLogo: logo,
          locationName: f.get("locationName"),
          latitude: Number(f.get("latitude")),
          longitude: Number(f.get("longitude")),
          workStart: f.get("workStart"),
          timezone: f.get("timezone"),
          radius: Number(f.get("radius")),
        }),
      });
      await onSaved("Pengaturan berhasil diperbarui");
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <form className="panel settings-form" onSubmit={submit}>
      <div className="panel-title">
        <h3>Perusahaan & lokasi absensi</h3>
        <p>Semua validasi lokasi dilakukan kembali oleh server.</p>
      </div>
      <div className="form-grid">
        <Field label="Nama PT / perusahaan *">
          <Input
            name="company"
            maxLength={120}
            required
            defaultValue={data.settings.company}
          />
        </Field>
        <Field label="Alamat perusahaan (ditampilkan pada slip PDF)" wide>
          <Textarea
            name="companyAddress"
            maxLength={500}
            rows={2}
            defaultValue={data.settings.companyAddress}
          />
        </Field>
        <Field label="Logo perusahaan (PNG/JPEG, maksimal 300 KB)" wide>
          <Input
            type="file"
            accept="image/png,image/jpeg"
            onChange={async (e) => {
              const file = e.target.files?.[0];
              if (!file) return;
              if (file.size > 300 * 1024) {
                setError("Logo maksimal 300 KB");
                return;
              }
              try {
                setLogo(await readDataURL(file));
                setError("");
              } catch (err) {
                setError((err as Error).message);
              }
            }}
          />
          {logo && (
            <div className="company-logo-preview">
              <img src={logo} alt="Logo perusahaan" />
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => setLogo("")}
              >
                Hapus logo
              </Button>
            </div>
          )}
        </Field>
        <p className="form-note full">
          Pengaturan lokasi berikut hanya untuk HQ bawaan. Kelola penugasan lain
          melalui Master Data - Service Point / HQ.
        </p>
        <Field label="Nama lokasi HQ *">
          <Input
            name="locationName"
            required
            defaultValue={data.settings.locationName}
          />
        </Field>
        <Field label="Latitude *">
          <Input
            type="number"
            name="latitude"
            step="any"
            min="-90"
            max="90"
            required
            defaultValue={data.settings.latitude}
          />
        </Field>
        <Field label="Longitude *">
          <Input
            type="number"
            name="longitude"
            step="any"
            min="-180"
            max="180"
            required
            defaultValue={data.settings.longitude}
          />
        </Field>
        <Field label="Radius (meter)">
          <Input
            name="radius"
            type="number"
            min={10}
            max={10000}
            required
            defaultValue={data.settings.radius}
          />
        </Field>
        <Field label="Jam mulai kerja *">
          <Input
            name="workStart"
            type="time"
            required
            defaultValue={data.settings.workStart}
          />
        </Field>
        <Field label="Zona waktu *" wide>
          <select name="timezone" defaultValue={data.settings.timezone}>
            <option>Asia/Jakarta</option>
            <option>Asia/Makassar</option>
            <option>Asia/Jayapura</option>
          </select>
        </Field>
      </div>
      {error && (
        <div role="alert" className="error-message">
          {error}
        </div>
      )}
      <Button disabled={busy}>
        {busy ? "Menyimpan…" : "Simpan pengaturan"}
      </Button>
    </form>
  );
}
