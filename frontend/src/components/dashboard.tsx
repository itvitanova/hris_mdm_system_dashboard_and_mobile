"use client";
import {
  ArrowDownToLine,
  ArrowRight,
  ArrowUpRight,
  CalendarDays,
  Check,
  ChevronRight,
  Clock3,
  Gift,
  Plus,
  ScanFace,
  Users,
  Wallet,
  FileClock,
  Building2,
  Sparkles,
} from "lucide-react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Button } from "./ui/button";
import { Avatar, Badge, Empty } from "./common";
import { csv, displayDate, localDate, rupiah } from "@/lib/api";
import type { HRRequest, View, Workspace } from "@/lib/types";
import type { FormState } from "./forms";
const palette = [
  "#2563eb",
  "#60a5fa",
  "#93c5fd",
  "#bfdbfe",
  "#c7d2fe",
  "#818cf8",
];
export function Dashboard({
  data,
  open,
  navigate,
  onAttendance,
  onReview,
}: {
  data: Workspace;
  open: (form: FormState) => void;
  navigate: (view: View) => void;
  onAttendance: () => void;
  onReview: (r: HRRequest, decision: string) => void;
}) {
  const { employees, requests, attendance, actor, settings } = data;
  const today = localDate(settings.timezone);
  const admin = actor.role === "admin";
  const active = employees.filter((e) => e.status !== "Nonaktif");
  const present = attendance.filter((a) => a.date === today);
  const pending = requests.filter((r) => r.status === "Menunggu");
  const onLeave = requests.filter(
    (r) =>
      r.kind === "Cuti" &&
      r.status === "Disetujui" &&
      r.startDate <= today &&
      r.endDate >= today,
  ).length;
  const salary = active.reduce((s, e) => s + e.salary, 0);
  const mine = employees.find((e) => e.id === actor.employeeId);
  const chart = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(today + "T12:00:00");
    d.setDate(d.getDate() - 6 + i);
    const date = localDate(settings.timezone, d);
    const records = attendance.filter((a) => a.date === date);
    return {
      day: d.toLocaleDateString("id-ID", { weekday: "short" }),
      Hadir: records.filter((a) => a.status === "Hadir").length,
      Terlambat: records.filter((a) => a.status === "Terlambat").length,
      date,
    };
  });
  const departments = Object.entries(
    active.reduce<Record<string, number>>((out, e) => {
      out[e.department] = (out[e.department] || 0) + 1;
      return out;
    }, {}),
  );
  let offset = 0;
  const gradient = departments
    .map(([, n], i) => {
      const start = offset;
      offset += (n / (active.length || 1)) * 100;
      return `${palette[i % palette.length]} ${start}% ${offset}%`;
    })
    .join(",");
  const birthdays = employees
    .filter((e) => e.birthDate.slice(5, 7) === today.slice(5, 7))
    .sort((a, b) => a.birthDate.slice(8).localeCompare(b.birthDate.slice(8)))
    .slice(0, 3);
  const dateLabel = new Date(today + "T12:00:00").toLocaleDateString("id-ID", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });
  return (
    <>
      <div className="page-heading">
        <div>
          <div className="eyebrow">WORKSPACE OVERVIEW</div>
          <h1>Dashboard</h1>
          <p>Semua tentang tim Anda, dalam satu tempat.</p>
        </div>
        <div className="heading-actions">
          <Button
            variant="outline"
            onClick={() =>
              csv(
                "ringkasan-kehadiran.csv",
                present.map((a) => ({
                  Nama: a.employeeName,
                  Tanggal: a.date,
                  Masuk: a.checkIn,
                  Pulang: a.checkOut,
                  Status: a.status,
                })),
              )
            }
            disabled={!present.length}
          >
            <ArrowDownToLine size={16} /> Ekspor laporan
          </Button>
          <Button
            onClick={() => open({ type: admin ? "employee" : "request" })}
          >
            <Plus size={17} />
            {admin ? "Tambah karyawan" : "Buat pengajuan"}
          </Button>
        </div>
      </div>
      <section className="welcome-banner">
        <div className="welcome-copy">
          <span className="welcome-date">
            <span className="live-dot" />
            {dateLabel}
          </span>
          <h2>
            Selamat datang, {actor.name.split(" ")[0]}{" "}
            <span className="wave">✦</span>
          </h2>
          <p>
            Tim yang hebat dimulai dari perhatian kecil.
            <br />
            Mari ciptakan hari kerja yang lebih baik.
          </p>
          <button onClick={() => navigate("Kehadiran")}>
            Lihat aktivitas hari ini <ArrowRight size={16} />
          </button>
        </div>
        <div className="welcome-art" aria-hidden="true">
          <div className="art-orbit orbit-one" />
          <div className="art-orbit orbit-two" />
          <div className="art-calendar">
            <div className="calendar-pins">
              <i />
              <i />
            </div>
            <div className="art-calendar-header">
              <span>HARI YANG PRODUKTIF</span>
              <CalendarDays size={15} />
            </div>
            <div className="calendar-today">
              <b>{today.slice(8)}</b>
              <span>
                {new Date(today + "T12:00:00").toLocaleDateString("id-ID", {
                  month: "long",
                })}
                <small>Let&apos;s make it count.</small>
              </span>
            </div>
            <div className="art-check">
              <span>
                <Check size={13} />
              </span>
              Great people, great things.
            </div>
          </div>
          <span className="art-float float-one">
            <Users size={21} />
          </span>
          <span className="art-float float-two">
            <Check size={18} />
          </span>
          <span className="art-spark spark-one">✦</span>
          <span className="art-spark spark-two">✧</span>
        </div>
        <div className="banner-aside">
          <span className="banner-aside-label">
            <Building2 size={14} /> {settings.company}
          </span>
          <span className="banner-clock">
            {settings.workStart}{" "}
            <small>
              {settings.timezone === "Asia/Makassar"
                ? "WITA"
                : settings.timezone === "Asia/Jayapura"
                  ? "WIT"
                  : "WIB"}
            </small>
          </span>
          <p>
            Jam mulai kerja
            <br />
            {settings.locationName}
          </p>
          <span className="banner-tag">
            <span />
            Workspace aktif
          </span>
        </div>
      </section>
      <div className="stats-grid">
        <Stat
          label={admin ? "Total karyawan" : "Saldo cuti Anda"}
          value={admin ? String(active.length) : `${mine?.leaveBalance || 0}`}
          suffix={admin ? "orang" : "hari"}
          icon={<Users size={21} />}
          foot={
            admin
              ? `${employees.filter((e) => e.status === "Probation").length} karyawan dalam masa probation`
              : "Ajukan cuti langsung dari aplikasi"
          }
          tag={admin ? "Tim Anda" : "Tahunan"}
          color="blue"
        />
        <Stat
          label="Kehadiran hari ini"
          value={String(present.length)}
          suffix={admin ? `/ ${active.length}` : "absensi"}
          icon={<CalendarDays size={21} />}
          foot={`${present.filter((a) => a.status === "Terlambat").length} terlambat · ${onLeave} sedang cuti`}
          tag={`${Math.round((present.length / (active.length || 1)) * 100)}% hadir`}
          color="green"
        />
        <Stat
          label="Menunggu persetujuan"
          value={String(pending.length)}
          suffix="pengajuan"
          icon={<FileClock size={21} />}
          foot="Cuti, reimbursement, dan operasional"
          tag="Perlu ditinjau"
          color="orange"
        />
        <Stat
          label={admin ? "Estimasi gaji pokok / bulan" : "Gaji pokok Anda"}
          value={
            salary >= 1000000
              ? (salary / 1000000).toLocaleString("id-ID", {
                  maximumFractionDigits: 1,
                })
              : String(salary)
          }
          suffix={salary >= 1000000 ? "jt" : "rupiah"}
          icon={<Wallet size={21} />}
          foot="Belum termasuk tunjangan & potongan"
          tag="IDR"
          color="purple"
        />
      </div>
      <div className="analytics-grid">
        <section className="panel attendance-chart">
          <div className="panel-heading">
            <div>
              <h3>Ringkasan kehadiran</h3>
              <p>Aktivitas tim selama 7 hari terakhir</p>
            </div>
            <span className="period-label">
              <CalendarDays size={14} /> 7 hari terakhir
            </span>
          </div>
          <div className="chart-legend">
            <span>
              <i style={{ background: "#3474ed" }} />
              Tepat waktu
            </span>
            <span>
              <i style={{ background: "#bfdbfe" }} />
              Terlambat
            </span>
            <div>
              <b>{attendance.filter((a) => a.date >= chart[0].date).length}</b>{" "}
              total kehadiran
            </div>
          </div>
          <div className="chart-container">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                data={chart}
                barGap={5}
                margin={{ top: 12, right: 8, left: -24, bottom: 0 }}
              >
                <CartesianGrid
                  vertical={false}
                  stroke="#eaf0f7"
                  strokeDasharray="4 4"
                />
                <XAxis
                  dataKey="day"
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "#8b97ac", fontSize: 11 }}
                  dy={7}
                />
                <YAxis
                  allowDecimals={false}
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "#8b97ac", fontSize: 11 }}
                />
                <Tooltip
                  contentStyle={{
                    borderRadius: 12,
                    border: "1px solid #edf0f5",
                    fontSize: 12,
                  }}
                  cursor={{ fill: "#f5f8fe" }}
                />
                <Bar
                  isAnimationActive={false}
                  dataKey="Hadir"
                  name="Tepat waktu"
                  fill="#3474ed"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={22}
                />
                <Bar
                  isAnimationActive={false}
                  dataKey="Terlambat"
                  fill="#bfdbfe"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={22}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </section>
        <section className="panel department-panel">
          <div className="panel-heading">
            <div>
              <h3>Komposisi tim</h3>
              <p>Karyawan per departemen</p>
            </div>
            <span className="subtle-icon">
              <Users size={18} />
            </span>
          </div>
          <div className="department-content">
            <div
              className="donut"
              style={{
                background: gradient
                  ? `conic-gradient(${gradient})`
                  : "#edf2fa",
              }}
              role="img"
              aria-label={`${active.length} karyawan di ${departments.length} departemen`}
            >
              <div>
                <b>{active.length}</b>
                <span>Karyawan</span>
              </div>
            </div>
            <div className="department-legend">
              {departments.slice(0, 6).map(([name, count], i) => (
                <div key={name}>
                  <span>
                    <i style={{ background: palette[i % palette.length] }} />
                    {name}
                  </span>
                  <b>{count}</b>
                </div>
              ))}
            </div>
          </div>
          <button className="panel-link" onClick={() => navigate("Karyawan")}>
            Lihat semua karyawan <ArrowRight size={14} />
          </button>
        </section>
      </div>
      <div className="dashboard-bottom">
        <section className="panel approvals-panel">
          <div className="panel-heading">
            <div className="inline-title">
              <h3>Pengajuan terbaru</h3>
              <span className="number-pill">{pending.length}</span>
            </div>
            <button
              className="text-button"
              onClick={() => navigate("Pengajuan")}
            >
              Lihat semua <ArrowRight size={14} />
            </button>
          </div>
          {requests.length ? (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Karyawan</th>
                    <th>Pengajuan</th>
                    <th>Status</th>
                    <th className="align-right">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {requests.slice(0, 4).map((r) => (
                    <tr key={r.id}>
                      <td>
                        <div className="person">
                          <Avatar name={r.employeeName} size="sm" />
                          <div>
                            <strong>{r.employeeName}</strong>
                            <span>
                              {employees.find((e) => e.id === r.employeeId)
                                ?.department || r.employeeId}
                            </span>
                          </div>
                        </div>
                      </td>
                      <td>
                        <strong className="table-main">{r.kind}</strong>
                        <span className="table-sub">
                          {displayDate(r.startDate, {
                            day: "numeric",
                            month: "short",
                          })}
                          {r.amount > 0 ? ` · ${rupiah(r.amount)}` : ""}
                        </span>
                      </td>
                      <td>
                        <Badge>{r.status}</Badge>
                      </td>
                      <td className="align-right">
                        {admin &&
                        r.status === "Menunggu" &&
                        r.employeeId !== actor.employeeId ? (
                          <button
                            className="review-btn"
                            onClick={() => onReview(r, "Disetujui")}
                          >
                            Tinjau <ChevronRight size={13} />
                          </button>
                        ) : (
                          <span className="muted">—</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <Empty
              text="Semua beres!"
              description="Belum ada pengajuan untuk ditinjau."
            />
          )}
          <div className="panel-table-footer">
            <span>{pending.length} pengajuan menunggu keputusan</span>
            <span className="tiny-dot" />
            Diperbarui dari server
          </div>
        </section>
        <section className="panel birthday-panel">
          <div className="panel-heading">
            <div className="inline-title">
              <span className="gift-icon">
                <Gift size={18} />
              </span>
              <h3>Ulang tahun bulan ini</h3>
            </div>
          </div>
          <div className="birthday-list">
            {birthdays.length ? (
              birthdays.map((e) => (
                <div className="birthday-row" key={e.id}>
                  <Avatar name={e.name} />
                  <div>
                    <strong>{e.name}</strong>
                    <span>{e.department}</span>
                  </div>
                  <span className="birthday-date">
                    {e.birthDate.slice(8)}{" "}
                    <small>
                      {new Date(today + "T12:00:00").toLocaleDateString(
                        "id-ID",
                        { month: "short" },
                      )}
                    </small>
                  </span>
                </div>
              ))
            ) : (
              <p className="muted">Tidak ada ulang tahun bulan ini.</p>
            )}
          </div>
          <div className="birthday-note">
            <Sparkles size={16} />
            <span>Hal kecil, berarti besar untuk tim.</span>
          </div>
        </section>
      </div>
      <div className="quick-attendance">
        <span className="quick-attendance-icon">
          <ScanFace size={23} />
        </span>
        <div>
          <strong>Hari yang produktif dimulai dari sini.</strong>
          <p>Absen dengan wajah, langsung dari perangkat Anda.</p>
        </div>
        <Button variant="outline" onClick={onAttendance}>
          Absen sekarang <ArrowUpRight size={15} />
        </Button>
      </div>
    </>
  );
}
function Stat({
  label,
  value,
  suffix,
  icon,
  foot,
  tag,
  color,
}: {
  label: string;
  value: string;
  suffix: string;
  icon: React.ReactNode;
  foot: string;
  tag: string;
  color: string;
}) {
  return (
    <section className="stat-card">
      <div className="stat-top">
        <span>{label}</span>
        <span className={`stat-icon ${color}`}>{icon}</span>
      </div>
      <div className="stat-value">
        {value}
        <small>{suffix}</small>
      </div>
      <div className="stat-foot">
        <span className={`stat-tag ${color}`}>{tag}</span>
        <p>{foot}</p>
      </div>
    </section>
  );
}
