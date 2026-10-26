"use client";
import { EmployeeDataActions } from "./employee-import";
import { RequestDetails } from "./request-center";
import { MapLink } from "./map-link";
import { useState } from "react";
import {
  ArrowDownToLine,
  ArrowRight,
  Check,
  ChevronRight,
  Clock3,
  FileText,
  Filter,
  MapPin,
  MoreHorizontal,
  Package,
  Plus,
  Search,
  ShieldCheck,
  Smartphone,
  Users,
  Wallet,
  X,
  CalendarDays,
  ScanFace,
  ArrowUpRight,
  AlertTriangle,
} from "lucide-react";
import { Avatar, Badge, Empty, Modal } from "./common";
import { Button } from "./ui/button";
import { api, csv, displayDate, localDate, rupiah } from "@/lib/api";
import type {
  Employee,
  HRRequest,
  Payroll,
  View,
  Workspace,
} from "@/lib/types";
import type { FormState } from "./forms";
export type ViewProps = {
  data: Workspace;
  open: (form: FormState) => void;
  query: string;
  onQuery: (q: string) => void;
  onAttendance: () => void;
  onEmployee: (e: Employee) => void;
  onReview: (r: HRRequest, decision: string) => void;
};
export function EmployeesView({
  data,
  open,
  query,
  onQuery,
  onEmployee,
  onSaved,
}: ViewProps & { onSaved?: (message: string) => Promise<void> }) {
  const [dept, setDept] = useState("Semua departemen"),
    [status, setStatus] = useState("Semua status"),
    [servicePoint, setServicePoint] = useState("");
  const admin = data.actor.role === "admin";
  const sites = new Map((data.servicePoints || []).map((p) => [p.id, p]));
  const siteName = (employee: Employee) =>
    sites.get(employee.servicePointId)?.name || "Belum ditentukan";
  const rows = data.employees.filter(
    (e) =>
      `${e.name} ${e.email} ${e.position} ${e.id}`
        .toLowerCase()
        .includes(query.toLowerCase()) &&
      (dept === "Semua departemen" || e.department === dept) &&
      (status === "Semua status" || e.status === status) &&
      (servicePoint === "" ||
        (servicePoint === "__unassigned"
          ? !sites.has(e.servicePointId)
          : e.servicePointId === servicePoint)),
  );
  return (
    <>
      <PageHeading
        eyebrow="PEOPLE MANAGEMENT"
        title={admin ? "Karyawan" : "Profil saya"}
        subtitle="Kenali tim Anda dan kelola informasi karyawan dengan mudah."
        actions={
          admin ? (
            <Button onClick={() => open({ type: "employee" })}>
              <Plus size={17} />
              Tambah karyawan
            </Button>
          ) : undefined
        }
      />
      <div className="mini-stats">
        <MiniStat
          title="Total karyawan"
          value={data.employees.length}
          icon={<Users size={20} />}
        />
        <MiniStat
          title="Karyawan aktif"
          value={data.employees.filter((e) => e.status === "Aktif").length}
          icon={<ShieldCheck size={20} />}
        />
        <MiniStat
          title="Masa probation"
          value={data.employees.filter((e) => e.status === "Probation").length}
          icon={<Clock3 size={20} />}
        />
        <MiniStat
          title="Departemen"
          value={new Set(data.employees.map((e) => e.department)).size}
          icon={<Package size={20} />}
        />
      </div>
      <section className="panel">
        <div className="table-toolbar employee-table-toolbar">
          <SearchBox
            value={query}
            onChange={onQuery}
            placeholder="Cari nama, jabatan, atau email…"
          />
          <div>
            <select
              aria-label="Filter Service Point"
              value={servicePoint}
              onChange={(e) => setServicePoint(e.target.value)}
            >
              <option value="">Semua Service Point / HQ</option>
              {(data.servicePoints || []).map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                  {!p.active ? " (nonaktif)" : ""}
                </option>
              ))}
              {data.employees.some((e) => !sites.has(e.servicePointId)) && (
                <option value="__unassigned">Belum ditentukan</option>
              )}
            </select>
            <select
              aria-label="Filter departemen"
              value={dept}
              onChange={(e) => setDept(e.target.value)}
            >
              <option>Semua departemen</option>
              {[...new Set(data.employees.map((e) => e.department))].map(
                (d) => (
                  <option key={d}>{d}</option>
                ),
              )}
            </select>
            <select
              aria-label="Filter status"
              value={status}
              onChange={(e) => setStatus(e.target.value)}
            >
              <option>Semua status</option>
              <option>Aktif</option>
              <option>Probation</option>
              <option>Nonaktif</option>
            </select>
            {admin && <EmployeeDataActions onSaved={onSaved} />}
          </div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Karyawan</th>
                <th>Departemen</th>
                <th>Jabatan</th>
                <th>Service Point / HQ</th>
                <th>Bergabung</th>
                <th>Status</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {rows.map((e) => (
                <tr key={e.id}>
                  <td>
                    <button
                      className="person person-button"
                      onClick={() => onEmployee(e)}
                    >
                      <Avatar name={e.name} />
                      <div>
                        <strong>{e.name}</strong>
                        <span>{e.email}</span>
                      </div>
                    </button>
                  </td>
                  <td>{e.department}</td>
                  <td>{e.position}</td>
                  <td>{siteName(e)}</td>
                  <td>{displayDate(e.joinDate)}</td>
                  <td>
                    <Badge>{e.status}</Badge>
                  </td>
                  <td>
                    <Button
                      variant="ghost"
                      size="icon"
                      aria-label={`Lihat ${e.name}`}
                      onClick={() => onEmployee(e)}
                    >
                      <ChevronRight size={17} />
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!rows.length && (
          <Empty
            text="Karyawan tidak ditemukan"
            description="Sesuaikan pencarian atau tambahkan karyawan baru."
          />
        )}
        <div className="panel-table-footer">
          Menampilkan {rows.length} dari {data.employees.length} karyawan
        </div>
      </section>
    </>
  );
}
export function AttendanceView({
  data,
  onAttendance,
  query,
  onQuery,
}: ViewProps) {
  const [date, setDate] = useState(localDate(data.settings.timezone));
  const rows = data.attendance.filter(
    (a) =>
      a.date === date &&
      a.employeeName.toLowerCase().includes(query.toLowerCase()),
  );
  return (
    <>
      <PageHeading
        eyebrow="TIME & ATTENDANCE"
        title="Kehadiran"
        subtitle="Pantau kehadiran tim dengan verifikasi lokasi dan wajah."
        actions={
          <Button onClick={onAttendance}>
            <ScanFace size={17} />
            Absen sekarang
          </Button>
        }
      />
      <div className="location-banner">
        <span className="location-icon">
          <MapPin size={24} />
        </span>
        <div>
          <strong>
            Absensi sesuai Service Point / HQ masing-masing karyawan
          </strong>
          <p>
            Radius dan zona waktu mengikuti lokasi penugasan. Koordinat masuk
            dan keluar tersimpan.
          </p>
        </div>
        <span className="badge blue">
          <ShieldCheck size={13} /> Lokasi & wajah
        </span>
      </div>
      {data.demo && (
        <div className="notice blue">
          <FileText size={18} />
          <span>
            Riwayat awal adalah data contoh. Label “Contoh” tidak menunjukkan
            verifikasi biometrik nyata.
          </span>
        </div>
      )}
      <div className="mini-stats three">
        <MiniStat
          title="Sudah absen"
          value={rows.length}
          icon={<Check size={20} />}
        />
        <MiniStat
          title="Tepat waktu"
          value={rows.filter((a) => a.status === "Hadir").length}
          icon={<Clock3 size={20} />}
        />
        <MiniStat
          title="Terlambat"
          value={rows.filter((a) => a.status === "Terlambat").length}
          icon={<AlertTriangle size={20} />}
        />
      </div>
      <section className="panel">
        <div className="table-toolbar">
          <SearchBox
            value={query}
            onChange={onQuery}
            placeholder="Cari karyawan…"
          />
          <div>
            <input
              aria-label="Tanggal kehadiran"
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
            />
            <Button
              variant="outline"
              disabled={!rows.length}
              onClick={() =>
                csv(
                  `kehadiran-${date}.csv`,
                  rows.map((r) => ({
                    Nama: r.employeeName,
                    Tanggal: r.date,
                    Masuk: r.checkIn,
                    Pulang: r.checkOut,
                    PulangAwal: r.earlyDeparture ? "YA" : "TIDAK",
                    MenitPulangAwal: r.earlyMinutes || 0,
                    AlasanPulangAwal: r.earlyReason || "",
                    Status: r.status,
                    Jarak: r.distance,
                    Verifikasi: r.faceVerified,
                    LokasiPenugasan: r.checkInLocation?.policy.name || "",
                    IzinBebasLokasi:
                      r.checkInLocation?.policy.allowAnyLocation ?? false,
                    LatitudeMasuk: r.checkInLocation?.latitude ?? r.latitude,
                    LongitudeMasuk: r.checkInLocation?.longitude ?? r.longitude,
                    LatitudeKeluar: r.checkOutLocation?.latitude ?? "",
                    LongitudeKeluar: r.checkOutLocation?.longitude ?? "",
                  })),
                )
              }
            >
              <ArrowDownToLine size={16} />
              Ekspor
            </Button>
          </div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Karyawan</th>
                <th>Tanggal</th>
                <th>Jam masuk</th>
                <th>Jam pulang</th>
                <th>Status</th>
                <th>Verifikasi</th>
                <th>Lokasi masuk / keluar</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td>
                    <div className="person">
                      <Avatar name={r.employeeName} size="sm" />
                      <strong>{r.employeeName}</strong>
                    </div>
                  </td>
                  <td>{displayDate(r.date)}</td>
                  <td>
                    {time(
                      r.checkIn,
                      r.checkInLocation?.policy.timezone ||
                        data.settings.timezone,
                    )}
                  </td>
                  <td>
                    {time(
                      r.checkOut,
                      r.checkOutLocation?.policy.timezone ||
                        data.settings.timezone,
                    )}
                  </td>
                  <td>
                    <Badge>{r.status}</Badge>
                    {r.earlyDeparture && (
                      <span className="table-sub" style={{ color: "#b42318" }}>
                        Pulang {r.earlyMinutes} menit lebih awal
                        <br />
                        {r.earlyReason}
                      </span>
                    )}
                  </td>
                  <td>
                    <span
                      className={r.faceVerified ? "verified-label" : "muted"}
                    >
                      {r.faceVerified ? (
                        <>
                          <ShieldCheck size={14} />
                          Wajah · {Math.round(r.distance)} m
                        </>
                      ) : (
                        "Contoh"
                      )}
                    </span>
                  </td>
                  <td>
                    <div>{r.checkInLocation?.policy.name || "Lokasi lama"}</div>
                    {r.checkIn && (
                      <MapLink
                        latitude={r.checkInLocation?.latitude ?? r.latitude}
                        longitude={r.checkInLocation?.longitude ?? r.longitude}
                        label="Peta masuk"
                      />
                    )}
                    {r.checkInLocation?.policy.allowAnyLocation && (
                      <div className="muted">Izin lokasi mana saja</div>
                    )}
                    {r.checkOutLocation && (
                      <div>
                        <MapLink
                          latitude={r.checkOutLocation.latitude}
                          longitude={r.checkOutLocation.longitude}
                          label="Peta keluar"
                        />
                        {r.checkOutLocation.policy.allowAnyLocation && (
                          <span> - Izin lokasi mana saja</span>
                        )}
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!rows.length && (
          <Empty
            text="Belum ada kehadiran"
            description="Pilih tanggal lain atau lakukan absensi."
          />
        )}
        <div className="panel-table-footer">
          {rows.length} catatan kehadiran · Jam mengikuti zona waktu lokasi saat
          absensi
        </div>
      </section>
    </>
  );
}
export function RequestsView({
  data,
  open,
  query,
  onQuery,
  onReview,
  kind,
}: { kind: string } & ViewProps) {
  const [filter, setFilter] = useState("Semua status");
  const [month, setMonth] = useState("");
  const [detail, setDetail] = useState<HRRequest | null>(null);
  const all = data.requests.filter(
    (r) =>
      (kind === "Pengajuan" || r.kind === kind) &&
      (data.actor.role === "admin" || r.employeeId === data.actor.employeeId) &&
      (!month ||
        localDate(data.settings.timezone, new Date(r.createdAt)).startsWith(
          month,
        )),
  );
  const rows = all.filter(
    (r) =>
      (filter === "Semua status" || r.status === filter) &&
      (!month ||
        localDate(data.settings.timezone, new Date(r.createdAt)).startsWith(
          month,
        )) &&
      `${r.title} ${r.employeeName}`
        .toLowerCase()
        .includes(query.toLowerCase()),
  );
  return (
    <>
      <PageHeading
        eyebrow="EMPLOYEE SELF SERVICE"
        title={
          kind === "Pengajuan"
            ? "Semua pengajuan"
            : kind === "Cuti"
              ? "Cuti & izin"
              : kind
        }
        subtitle={
          {
            Cuti: "Rencanakan waktu istirahat, kelola cuti dengan lebih mudah.",
            Reimbursement:
              "Penggantian biaya yang transparan dan mudah dilacak.",
            "Petty Cash":
              "Kelola pengajuan dana operasional dalam satu tempat.",
            Lembur: "Catat waktu tambahan dan pantau persetujuannya.",
            "General Affair": "Ajukan kebutuhan kantor dan fasilitas tim.",
          }[kind] || "Kelola kebutuhan operasional tim."
        }
        actions={
          <Button
            onClick={() =>
              open({
                type: "request",
                kind: kind === "Pengajuan" ? "Cuti" : kind,
              })
            }
          >
            <Plus size={17} />
            Buat pengajuan
          </Button>
        }
      />
      <div className="mini-stats three">
        <MiniStat
          title="Total pengajuan"
          value={all.length}
          icon={<FileText size={20} />}
        />
        <MiniStat
          title="Menunggu persetujuan"
          value={all.filter((r) => r.status === "Menunggu").length}
          icon={<Clock3 size={20} />}
        />
        <MiniStat
          title="Disetujui"
          value={all.filter((r) => r.status === "Disetujui").length}
          icon={<Check size={20} />}
        />
      </div>
      <section className="panel">
        <div className="table-toolbar">
          <SearchBox
            value={query}
            onChange={onQuery}
            placeholder="Cari nama atau pengajuan…"
          />
          <div>
            {kind === "Reimbursement" && (
              <label className="month-filter">
                Bulan pengajuan
                <input
                  type="month"
                  value={month}
                  onChange={(e) => setMonth(e.target.value)}
                />
              </label>
            )}
            <select
              aria-label="Status pengajuan"
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
            >
              <option>Semua status</option>
              <option>Menunggu</option>
              <option>Disetujui</option>
              <option>Ditolak</option>
              <option>Perlu revisi</option>
            </select>
            <Button
              variant="outline"
              size="icon"
              aria-label="Ekspor pengajuan"
              disabled={!rows.length}
              onClick={() =>
                csv(
                  `pengajuan-${kind}.csv`,
                  rows.map((r) => ({
                    Nama: r.employeeName,
                    Judul: r.title,
                    Mulai: r.startDate,
                    Selesai: r.endDate,
                    Nominal: r.amount,
                    Jam: r.hours,
                    Hari: r.days,
                    Status: r.status,
                    Peninjau: r.reviewedBy,
                    Catatan: r.reviewNote,
                  })),
                )
              }
            >
              <ArrowDownToLine size={16} />
            </Button>
          </div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Karyawan</th>
                <th>Keperluan</th>
                <th>Periode</th>
                <th>
                  {kind === "Pengajuan"
                    ? "Detail"
                    : kind === "Lembur"
                      ? "Durasi"
                      : kind === "Cuti"
                        ? "Hari"
                        : "Nominal"}
                </th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td>
                    <div className="person">
                      <Avatar name={r.employeeName} size="sm" />
                      <div>
                        <strong>{r.employeeName}</strong>
                        <span>{displayDate(r.createdAt)}</span>
                      </div>
                    </div>
                  </td>
                  <td>
                    <strong className="table-main">{r.title}</strong>
                    {kind === "Pengajuan" && (
                      <span className="table-sub">{r.kind}</span>
                    )}
                    <span
                      className="table-sub request-description"
                      title={r.description}
                    >
                      {r.description}
                    </span>
                    <Button
                      className="request-detail-trigger"
                      variant="outline"
                      onClick={() => setDetail(r)}
                    >
                      Rincian dan dokumen
                    </Button>
                    {r.status === "Perlu revisi" &&
                      r.employeeId === data.actor.employeeId && (
                        <Button
                          variant="outline"
                          onClick={() =>
                            open({ type: "request", kind: r.kind, request: r })
                          }
                        >
                          Perbaiki pengajuan
                        </Button>
                      )}
                    {r.reviewNote && (
                      <span className="table-sub">Catatan: {r.reviewNote}</span>
                    )}
                  </td>
                  <td>
                    <span className="table-main">
                      {displayDate(r.startDate)}
                    </span>
                    {r.endDate !== r.startDate && (
                      <span className="table-sub">
                        s.d. {displayDate(r.endDate)}
                      </span>
                    )}
                  </td>
                  <td>
                    {r.kind === "Lembur"
                      ? `${r.hours} jam`
                      : r.kind === "Cuti"
                        ? `${r.days} hari`
                        : r.amount > 0
                          ? rupiah(r.amount)
                          : "—"}
                  </td>
                  <td>
                    <Badge>{r.status}</Badge>
                    {r.status === "Menunggu" && r.pendingWith && (
                      <span className="table-sub request-next-actor">
                        {r.pendingWith}
                      </span>
                    )}
                  </td>
                  <td>
                    {(r.canReview ??
                    (data.actor.role === "admin" &&
                      !r.version &&
                      r.status === "Menunggu" &&
                      r.employeeId !== data.actor.employeeId)) ? (
                      <div className="review-actions">
                        <button
                          className="approve-action"
                          aria-label={`Setujui ${r.title}`}
                          onClick={() => onReview(r, "Disetujui")}
                        >
                          <Check size={16} />
                        </button>
                        <button
                          className="reject-action"
                          aria-label={`Tolak ${r.title}`}
                          onClick={() => onReview(r, "Ditolak")}
                        >
                          <X size={16} />
                        </button>
                      </div>
                    ) : (
                      <span className="request-next-actor">
                        {r.status === "Menunggu"
                          ? r.pendingWith || "Menunggu peninjauan"
                          : r.reviewedBy || "—"}
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!rows.length && (
          <Empty
            text="Belum ada pengajuan"
            description="Buat pengajuan baru untuk kebutuhan Anda."
          />
        )}
        <div className="panel-table-footer">
          {rows.length} pengajuan · Persetujuan mengikuti alur dan penugasan
        </div>
      </section>
      {detail && (
        <Modal
          title="Rincian dan dokumen"
          subtitle="Pengajuan reimbursement dan riwayat persetujuannya"
          onClose={() => setDetail(null)}
        >
          <RequestDetails
            request={data.requests.find((r) => r.id === detail.id) || detail}
          />
        </Modal>
      )}
    </>
  );
}
export function InventoryView(props: ViewProps) {
  const { data, open, query, onQuery } = props;
  const [tab, setTab] = useState("Stok barang");
  const rows = data.inventory.filter((i) =>
    `${i.name} ${i.category}`.toLowerCase().includes(query.toLowerCase()),
  );
  return (
    <>
      <PageHeading
        eyebrow="OFFICE OPERATIONS"
        title="General Affair"
        subtitle="Kebutuhan kantor tertata. Tim bekerja lebih nyaman."
        actions={
          <Button
            onClick={() =>
              open({
                type: tab === "Pengajuan" ? "request" : "item",
                kind: "General Affair",
              })
            }
          >
            <Plus size={17} />
            {tab === "Pengajuan" ? "Buat pengajuan" : "Tambah barang"}
          </Button>
        }
      />
      <div className="tabs">
        {["Stok barang", "Pengajuan", "Riwayat mutasi"].map((t) => (
          <button
            key={t}
            className={tab === t ? "active" : ""}
            onClick={() => setTab(t)}
          >
            {t}
          </button>
        ))}
      </div>
      {tab === "Pengajuan" ? (
        <RequestsView {...props} kind="General Affair" />
      ) : tab === "Riwayat mutasi" ? (
        <section className="panel">
          <div className="panel-heading">
            <h3>Riwayat barang masuk & keluar</h3>
          </div>
          {data.stockMovements.length ? (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Barang</th>
                    <th>Mutasi</th>
                    <th>Catatan</th>
                    <th>Waktu</th>
                  </tr>
                </thead>
                <tbody>
                  {[...data.stockMovements]
                    .sort((a, b) => b.createdAt.localeCompare(a.createdAt))
                    .map((m) => (
                      <tr key={m.id}>
                        <td>
                          {data.inventory.find((i) => i.id === m.itemId)
                            ?.name || m.itemId}
                        </td>
                        <td>
                          <span
                            className={
                              m.quantity > 0 ? "text-green" : "text-red"
                            }
                          >
                            {m.quantity > 0 ? "+" : ""}
                            {m.quantity}
                          </span>
                        </td>
                        <td>{m.note}</td>
                        <td>{displayDate(m.createdAt)}</td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>
          ) : (
            <Empty
              text="Belum ada mutasi"
              description="Perubahan stok akan dicatat otomatis di sini."
            />
          )}
        </section>
      ) : (
        <>
          <div className="mini-stats three">
            <MiniStat
              title="Jenis barang"
              value={data.inventory.length}
              icon={<Package size={20} />}
            />
            <MiniStat
              title="Perlu restock"
              value={data.inventory.filter((i) => i.stock <= i.minimum).length}
              icon={<AlertTriangle size={20} />}
            />
            <MiniStat
              title="Kategori"
              value={new Set(data.inventory.map((i) => i.category)).size}
              icon={<Filter size={20} />}
            />
          </div>
          <section className="panel">
            <div className="table-toolbar">
              <SearchBox
                value={query}
                onChange={onQuery}
                placeholder="Cari nama atau kategori barang…"
              />
              <Button
                variant="outline"
                disabled={!rows.length}
                onClick={() =>
                  csv(
                    "stok-ga.csv",
                    rows.map((i) => ({
                      Kode: i.id,
                      Barang: i.name,
                      Kategori: i.category,
                      Stok: i.stock,
                      Satuan: i.unit,
                      Minimum: i.minimum,
                    })),
                  )
                }
              >
                <ArrowDownToLine size={16} />
                Ekspor stok
              </Button>
            </div>
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Barang</th>
                    <th>Kategori</th>
                    <th>Stok tersedia</th>
                    <th>Minimum</th>
                    <th>Status</th>
                    <th>Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {rows.map((i) => (
                    <tr key={i.id}>
                      <td>
                        <div className="person">
                          <span className="item-icon">
                            <Package size={20} />
                          </span>
                          <div>
                            <strong>{i.name}</strong>
                            <span>{i.id}</span>
                          </div>
                        </div>
                      </td>
                      <td>{i.category}</td>
                      <td>
                        <strong>{i.stock}</strong> {i.unit}
                      </td>
                      <td>
                        {i.minimum} {i.unit}
                      </td>
                      <td>
                        <Badge>
                          {i.stock <= i.minimum ? "Perlu restock" : "Aktif"}
                        </Badge>
                      </td>
                      <td>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => open({ type: "stock", item: i })}
                        >
                          Mutasi stok <ArrowRight size={13} />
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {!rows.length && <Empty text="Barang tidak ditemukan" />}
          </section>
        </>
      )}
    </>
  );
}
export { PayrollView } from "./payroll";
export function MobileView({
  data,
  open,
  onAttendance,
  navigate,
  install,
}: {
  data: Workspace;
  open: (f: FormState) => void;
  onAttendance: () => void;
  navigate: (v: View) => void;
  install: () => void;
}) {
  const mine = data.employees.find((e) => e.id === data.actor.employeeId);
  const today = localDate(data.settings.timezone);
  const att = data.attendance.find(
    (a) => a.employeeId === mine?.id && a.date === today,
  );
  return (
    <>
      <PageHeading
        eyebrow="EMPLOYEE SELF SERVICE"
        title="Ruang karyawan"
        subtitle="Satu aplikasi untuk kebutuhan kerja Anda, di mana saja."
        actions={
          <Button variant="outline" onClick={install}>
            <Smartphone size={16} />
            Pasang aplikasi
          </Button>
        }
      />
      <div className="mobile-portal">
        <section className="mobile-profile">
          <div>
            <Avatar name={data.actor.name} size="lg" />
            <span>
              <small>Halo, selamat bekerja 👋</small>
              <h2>{data.actor.name}</h2>
              <p>
                {mine?.position} · {mine?.department}
              </p>
            </span>
          </div>
          <span className="mobile-employee-id">{mine?.id}</span>
        </section>
        <section className="panel mobile-attendance">
          <div className="panel-heading">
            <h3>Kehadiran hari ini</h3>
            <span className="muted">{displayDate(today)}</span>
          </div>
          <div className="punch-times">
            <div>
              <span>Jam masuk</span>
              <strong>
                {time(att?.checkIn || "", data.settings.timezone)}
              </strong>
            </div>
            <div>
              <span>Jam pulang</span>
              <strong>
                {time(att?.checkOut || "", data.settings.timezone)}
              </strong>
            </div>
          </div>
          <p>
            <MapPin size={15} />
            {data.attendancePolicy?.name || "Lokasi belum ditentukan"} ·{" "}
            {data.attendancePolicy?.allowAnyLocation
              ? "Izin lokasi mana saja"
              : `Radius ${data.attendancePolicy?.radius || 100} m`}
          </p>
          <Button onClick={onAttendance}>
            <ScanFace size={19} />
            Absen dengan wajah <ArrowUpRight size={16} />
          </Button>
        </section>
        <div className="mobile-services">
          {[
            { kind: "Cuti", icon: CalendarDays, color: "blue" },
            { kind: "Reimbursement", icon: Wallet, color: "green" },
            { kind: "Petty Cash", icon: FileText, color: "purple" },
            { kind: "General Affair", icon: Package, color: "orange" },
            { kind: "Lembur", icon: Clock3, color: "blue" },
            { kind: "Slip gaji", icon: Wallet, color: "green" },
          ].map(({ kind, icon: Icon, color }) => (
            <button
              key={kind}
              onClick={() =>
                kind === "Slip gaji"
                  ? navigate("Payroll")
                  : open({ type: "request", kind })
              }
            >
              <span className={`service-icon ${color}`}>
                <Icon size={24} />
              </span>
              <strong>{kind}</strong>
              <ChevronRight size={15} />
            </button>
          ))}
        </div>
        <div className="panel leave-balance-card">
          <span className="stat-icon blue">
            <CalendarDays size={23} />
          </span>
          <div>
            <h3>Waktunya menjaga keseimbangan</h3>
            <p>Saldo cuti tahunan Anda</p>
          </div>
          <strong>
            {mine?.leaveBalance || 0}
            <small>hari</small>
          </strong>
          <Button
            variant="outline"
            onClick={() => open({ type: "request", kind: "Cuti" })}
          >
            Ajukan cuti
          </Button>
        </div>
      </div>
    </>
  );
}
export function EmployeeDetail({
  employee: e,
  data,
  onClose,
  open,
  onEnroll,
}: {
  employee: Employee;
  data: Workspace;
  onClose: () => void;
  open: (f: FormState) => void;
  onEnroll: () => void;
}) {
  const [reference, setReference] = useState<{
    photo: string;
    enrolledAt: string;
  } | null>(null);
  const [referenceError, setReferenceError] = useState("");
  const [loadingReference, setLoadingReference] = useState(false);
  async function loadReference() {
    setLoadingReference(true);
    setReferenceError("");
    try {
      setReference(await api(`/employees/${encodeURIComponent(e.id)}/face`));
    } catch {
      setReferenceError(
        "Foto referensi belum tersedia. Minta karyawan mendaftarkan wajah dari HP atau daftarkan ulang melalui admin.",
      );
    } finally {
      setLoadingReference(false);
    }
  }
  return (
    <Modal title="Profil karyawan" onClose={onClose}>
      <div className="employee-detail">
        <div className="employee-profile">
          <Avatar name={e.name} size="lg" />
          <h2>{e.name}</h2>
          <p>{e.position}</p>
          <Badge>{e.status}</Badge>
        </div>
        <dl>
          {[
            ["ID karyawan", e.id],
            ["Departemen", e.department],
            [
              "Lokasi penugasan",
              data.servicePoints?.find((p) => p.id === e.servicePointId)
                ?.name || "Belum ditentukan",
            ],
            [
              "Izin lokasi absensi",
              e.allowAnyLocation
                ? "Dari lokasi mana saja"
                : "Wajib di lokasi penugasan",
            ],
            ["Email", e.email],
            ["Telepon", e.phone],
            ["Alamat", e.address],
            ["Tanggal lahir", displayDate(e.birthDate)],
            ["Bergabung", displayDate(e.joinDate)],
            ["Gaji pokok", rupiah(e.salary)],
            ["Status PTKP", e.ptkp || "Belum diisi"],
            ["NIK", e.employeeNumber || "Belum diisi"],
            ["Hubungan kerja", e.employmentType || "Belum diisi"],
            ["Saldo cuti", `${e.leaveBalance} hari`],
            ["Wajah", e.faceEnrolled ? "Sudah terdaftar" : "Belum terdaftar"],
          ].map(([k, v]) => (
            <div key={k}>
              <dt>{k}</dt>
              <dd>{v || "—"}</dd>
            </div>
          ))}
        </dl>
        {data.servicePoints
          ?.filter((p) => p.id === e.servicePointId)
          .map((p) => (
            <p key={p.id}>
              <MapLink
                latitude={p.latitude}
                longitude={p.longitude}
                label={`Peta ${p.name}`}
              />
            </p>
          ))}
        {e.faceEnrolled && (
          <div>
            {reference ? (
              <figure>
                <img
                  src={reference.photo}
                  alt={`Referensi wajah ${e.name}`}
                  width={180}
                  height={220}
                  style={{ objectFit: "cover", borderRadius: 12 }}
                />
                <figcaption>
                  Foto referensi absensi · {displayDate(reference.enrolledAt)}
                </figcaption>
              </figure>
            ) : (
              <Button
                variant="outline"
                disabled={loadingReference}
                onClick={loadReference}
              >
                {loadingReference
                  ? "Memuat foto…"
                  : "Lihat foto referensi wajah"}
              </Button>
            )}
            {referenceError && <p role="alert">{referenceError}</p>}
          </div>
        )}
        {data.actor.role === "admin" && (
          <div className="detail-actions">
            <Button
              onClick={() => {
                onClose();
                open({ type: "employee", employee: e });
              }}
            >
              Edit karyawan
            </Button>
            <Button
              variant="outline"
              onClick={() => {
                onClose();
                open({ type: "account", employee: e });
              }}
            >
              Buat akun
            </Button>
            <Button variant="outline" onClick={onEnroll}>
              <ScanFace size={16} />
              {e.faceEnrolled ? "Ganti referensi wajah" : "Daftarkan wajah"}
            </Button>
          </div>
        )}
      </div>
    </Modal>
  );
}
export function PageHeading({
  eyebrow,
  title,
  subtitle,
  actions,
}: {
  eyebrow: string;
  title: string;
  subtitle: string;
  actions?: React.ReactNode;
}) {
  return (
    <div className="page-heading">
      <div>
        <div className="eyebrow">{eyebrow}</div>
        <h1>{title}</h1>
        <p>{subtitle}</p>
      </div>
      <div className="heading-actions">{actions}</div>
    </div>
  );
}
function MiniStat({
  title,
  value,
  icon,
}: {
  title: string;
  value: string | number;
  icon: React.ReactNode;
}) {
  return (
    <div className="mini-stat">
      <span className="stat-icon blue">{icon}</span>
      <div>
        <span>{title}</span>
        <strong>{value}</strong>
      </div>
    </div>
  );
}
function SearchBox({
  value,
  onChange,
  placeholder,
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder: string;
}) {
  return (
    <label className="search-box">
      <Search size={17} />
      <input
        aria-label={placeholder}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
      />
      {value && (
        <button
          onClick={() => onChange("")}
          type="button"
          aria-label="Hapus pencarian"
        >
          <X size={14} />
        </button>
      )}
    </label>
  );
}
function time(s: string, tz: string) {
  return s
    ? new Date(s).toLocaleTimeString("id-ID", {
        hour: "2-digit",
        minute: "2-digit",
        timeZone: tz,
      })
    : "— : —";
}
