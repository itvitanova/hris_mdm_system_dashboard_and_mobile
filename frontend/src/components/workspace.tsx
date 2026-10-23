"use client";
import { useCallback, useEffect, useState } from "react";
import {
  ArrowRight,
  Bell,
  CalendarDays,
  CheckCircle2,
  ChevronDown,
  ChevronRight,
  Clock3,
  FileText,
  Headphones,
  LayoutDashboard,
  Loader2,
  LogOut,
  Menu,
  Package,
  Plus,
  RefreshCw,
  Search,
  Settings,
  ShieldCheck,
  Smartphone,
  Users,
  Wallet,
  X,
  AlertCircle,
  Building2,
  ScanFace,
  ArrowUpRight,
  Database,
} from "lucide-react";
import { api, post } from "@/lib/api";
import type {
  Employee,
  HRRequest,
  View,
  Workspace as WorkspaceData,
} from "@/lib/types";
import { Avatar, Modal } from "./common";
import { Button } from "./ui/button";
import { Dashboard } from "./dashboard";
import { Forms, SettingsForm, type FormState } from "./forms";
import { AttendanceCamera } from "./attendance-camera";
import { masterMenus } from "@/lib/master-data";
import { ServicePointsView } from "./service-points";
import { MasterDataView } from "./master-data";
import {
  AttendanceView,
  EmployeeDetail,
  EmployeesView,
  InventoryView,
  MobileView,
  PageHeading,
  PayrollView,
  RequestsView,
} from "./data-views";
const nav = [
  {
    group: "WORKSPACE",
    items: [
      { name: "Dashboard", icon: LayoutDashboard },
      { name: "Karyawan", icon: Users },
      { name: "Kehadiran", icon: CalendarDays },
      { name: "Cuti", icon: FileText },
    ],
  },
  {
    group: "KEUANGAN",
    items: [
      { name: "Payroll", icon: Wallet },
      { name: "Reimbursement", icon: FileText },
      { name: "Petty Cash", icon: Wallet },
    ],
  },
  {
    group: "OPERASIONAL",
    items: [
      { name: "General Affair", icon: Package },
      { name: "Lembur", icon: Clock3 },
    ],
  },
] as const;
const navigationMasters = [
  ...masterMenus,
  {
    view: "Service Point" as const,
    kind: "service-points",
    title: "Service Point / HQ",
    icon: Building2,
  },
];
const views: View[] = [
  "Service Point",
  ...masterMenus.map((m) => m.view),
  "Pengajuan",
  "Dashboard",
  "Karyawan",
  "Kehadiran",
  "Cuti",
  "Payroll",
  "Reimbursement",
  "Petty Cash",
  "General Affair",
  "Lembur",
  "Pengaturan",
  "Mobile",
];
interface InstallPrompt extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: string }>;
}
export default function Workspace() {
  const [data, setData] = useState<WorkspaceData | null>(null),
    [loading, setLoading] = useState(true),
    [error, setError] = useState(""),
    [view, setView] = useState<View>("Dashboard"),
    [menu, setMenu] = useState(false),
    [masterOpen, setMasterOpen] = useState(true),
    [query, setQuery] = useState(""),
    [form, setForm] = useState<FormState | null>(null),
    [employee, setEmployee] = useState<Employee | null>(null),
    [camera, setCamera] = useState<{ enrollID?: string } | null>(null),
    [toast, setToast] = useState(""),
    [notifications, setNotifications] = useState(false),
    [installPrompt, setInstallPrompt] = useState<InstallPrompt | null>(null),
    [installHelp, setInstallHelp] = useState(false),
    [demo, setDemo] = useState(false),
    [refreshing, setRefreshing] = useState(false);
  const load = useCallback(async () => {
    const value = await api<WorkspaceData>("/workspace");
    setData(value);
    setError("");
    return value;
  }, []);
  useEffect(() => {
    let active = true;
    void api<{ demo: boolean }>("/health")
      .then((d) => {
        if (active) setDemo(d.demo);
      })
      .catch(() => {});
    void load()
      .catch((e) => {
        if (active && !(e as Error).message.includes("Sesi berakhir"))
          setError((e as Error).message);
      })
      .finally(() => {
        if (active) setLoading(false);
      });
    const sync = () => {
      const v = new URLSearchParams(location.search).get("view") as View;
      if (views.includes(v)) setView(v);
      else setView("Dashboard");
    };
    sync();
    window.addEventListener("popstate", sync);
    if ("serviceWorker" in navigator)
      void navigator.serviceWorker.register("/sw.js").catch(() => {});
    const install = (event: Event) => {
      event.preventDefault();
      setInstallPrompt(event as InstallPrompt);
    };
    window.addEventListener("beforeinstallprompt", install);
    return () => {
      active = false;
      window.removeEventListener("popstate", sync);
      window.removeEventListener("beforeinstallprompt", install);
    };
  }, [load]);
  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(""), 4500);
    return () => clearTimeout(t);
  }, [toast]);
  const navigate = (v: View) => {
    setView(v);
    setMenu(false);
    setQuery("");
    history.pushState({}, "", `/?view=${encodeURIComponent(v)}`);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };
  async function saved(message: string) {
    setToast(message);
    try {
      await load();
    } catch {
      setError(
        "Data tersimpan, tetapi tampilan belum diperbarui. Muat ulang untuk mengambil data terbaru.",
      );
    }
  }
  async function refresh() {
    setRefreshing(true);
    try {
      await load();
      setToast("Data sudah diperbarui");
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setRefreshing(false);
    }
  }
  async function logout() {
    try {
      await post("/auth/logout", {});
      setData(null);
      setView("Dashboard");
      setQuery("");
      setEmployee(null);
      setForm(null);
      setNotifications(false);
      setCamera(null);
      setError("");
      history.replaceState({}, "", "/");
    } catch (e) {
      setToast((e as Error).message);
    }
  }
  async function install() {
    if (window.matchMedia("(display-mode: standalone)").matches) {
      setToast("Aplikasi sudah berjalan dalam mode terpasang");
      return;
    }
    if (installPrompt) {
      await installPrompt.prompt();
      const choice = await installPrompt.userChoice;
      if (choice.outcome === "accepted")
        setToast("Aplikasi berhasil ditambahkan");
      setInstallPrompt(null);
    } else setInstallHelp(true);
  }
  function review(r: HRRequest, decision: string) {
    setNotifications(false);
    setForm({ type: "review", request: r, decision });
  }
  if (loading)
    return (
      <div className="app-loading">
        <Brand />
        <Loader2 className="spin" />
        <p>Menyiapkan ruang kerja Anda…</p>
      </div>
    );
  if (!data)
    return (
      <Login
        demo={demo}
        initialError={error}
        onLogin={async () => {
          await load();
          setView(
            new URLSearchParams(location.search).get("view") === "Mobile"
              ? "Mobile"
              : "Dashboard",
          );
        }}
      />
    );
  const admin = data.actor.role === "admin";
  const pending = data.requests.filter((r) => r.status === "Menunggu");
  const props = {
    data,
    open: setForm,
    query,
    onQuery: setQuery,
    onAttendance: () => setCamera({}),
    onEmployee: setEmployee,
    onReview: review,
  };
  return (
    <div className="app-shell">
      {menu && (
        <button
          className="sidebar-backdrop"
          aria-label="Tutup menu"
          onClick={() => setMenu(false)}
        />
      )}
      <aside className={`sidebar ${menu ? "is-open" : ""}`}>
        <div className="sidebar-brand">
          <Brand />
          <span className="workspace-tier">HR WORKSPACE</span>
        </div>
        <button
          className="workspace-selector"
          onClick={() => navigate(admin ? "Pengaturan" : "Mobile")}
        >
          <span className="company-mark">
            <Building2 size={17} />
          </span>
          <span>
            <strong>{data.settings.company}</strong>
            <small>Company workspace</small>
          </span>
          <ChevronDown size={14} />
        </button>
        <nav>
          {nav.map((group) => (
            <div className="nav-group" key={group.group}>
              <span className="nav-label">{group.group}</span>
              {group.items.map((item) => (
                <button
                  key={item.name}
                  className={`nav-item ${view === item.name ? "active" : ""}`}
                  onClick={() => navigate(item.name)}
                >
                  <item.icon size={18} strokeWidth={1.8} />
                  <span>
                    {item.name === "Karyawan" && !admin
                      ? "Profil saya"
                      : item.name}
                  </span>
                  {item.name === "Cuti" &&
                    pending.filter((r) => r.kind === "Cuti").length > 0 && (
                      <b>{pending.filter((r) => r.kind === "Cuti").length}</b>
                    )}
                </button>
              ))}
            </div>
          ))}
          {admin && (
            <div className="nav-group master-nav">
              <button
                className={`nav-item master-nav-parent ${navigationMasters.some((m) => m.view === view) ? "master-current" : ""}`}
                aria-expanded={masterOpen}
                aria-controls="master-data-submenu"
                onClick={() => setMasterOpen(!masterOpen)}
              >
                <Database size={18} />
                <span>Master Data</span>
                <ChevronDown
                  size={14}
                  className={
                    masterOpen ? "master-chevron open" : "master-chevron"
                  }
                />
              </button>
              {masterOpen && (
                <div id="master-data-submenu" className="master-submenu">
                  {navigationMasters.map((m) => (
                    <button
                      key={m.kind}
                      className={`nav-item ${view === m.view ? "active" : ""}`}
                      onClick={() => navigate(m.view)}
                    >
                      <m.icon size={16} />
                      <span>{m.title}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}
        </nav>
        <div className="sidebar-bottom">
          <div className="pwa-promo">
            <span className="pwa-promo-icon">
              <Smartphone size={23} />
            </span>
            <strong>HR dalam genggaman</strong>
            <p>
              Absen & ajukan kebutuhan
              <br />
              langsung dari ponsel Anda.
            </p>
            <button onClick={() => navigate("Mobile")}>
              Buka ruang karyawan <ArrowUpRight size={14} />
            </button>
          </div>
          {admin && (
            <button
              className={`nav-item ${view === "Pengaturan" ? "active" : ""}`}
              onClick={() => navigate("Pengaturan")}
            >
              <Settings size={18} />
              <span>Pengaturan</span>
            </button>
          )}
          <div className="sidebar-user">
            <Avatar name={data.actor.name} />
            <button
              className="user-profile-button"
              onClick={() => navigate("Mobile")}
            >
              <strong>{data.actor.name}</strong>
              <span>{admin ? "Administrator" : "Karyawan"}</span>
            </button>
            <button
              className="logout-button"
              onClick={logout}
              title="Keluar"
              aria-label="Keluar"
            >
              <LogOut size={16} />
            </button>
          </div>
        </div>
      </aside>
      <div className="main-shell">
        <header className="topbar">
          <div className="breadcrumb">
            <button
              className="mobile-menu"
              onClick={() => setMenu(true)}
              aria-label="Buka menu"
            >
              <Menu size={21} />
            </button>
            <span>Workspace</span>
            <ChevronRight size={13} />
            <strong>{view}</strong>
            {data.demo && <span className="demo-label">DEMO</span>}
          </div>
          <div className="topbar-right">
            <label className="global-search">
              <Search size={16} />
              <input
                aria-label="Cari karyawan"
                placeholder="Cari karyawan…"
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  if (view !== "Karyawan") setView("Karyawan");
                }}
              />
              <kbd>⌕</kbd>
            </label>
            <button
              className="topbar-icon"
              onClick={refresh}
              aria-label="Perbarui data"
            >
              <RefreshCw size={17} className={refreshing ? "spin" : ""} />
            </button>
            <button
              className="notification-button topbar-icon"
              aria-label={`Notifikasi, ${pending.length} pengajuan menunggu`}
              onClick={() => setNotifications(true)}
            >
              <Bell size={19} />
              {pending.length > 0 && <i />}
            </button>
            <div className="topbar-divider" />
            <button
              className="topbar-profile"
              onClick={() => navigate("Mobile")}
              aria-label="Buka profil"
            >
              <Avatar name={data.actor.name} size="sm" />
              <span>{data.actor.name.split(" ")[0]}</span>
              <ChevronDown size={13} />
            </button>
          </div>
        </header>
        <main className="main-content">
          {error && (
            <div role="alert" className="error-message">
              <AlertCircle size={18} />
              {error}
              <button onClick={refresh}>Muat ulang</button>
            </div>
          )}
          {view === "Dashboard" && (
            <Dashboard
              data={data}
              open={setForm}
              navigate={navigate}
              onAttendance={() => setCamera({})}
              onReview={review}
            />
          )}
          {view === "Karyawan" && <EmployeesView {...props} />}
          {view === "Service Point" && admin && (
            <ServicePointsView data={data} onSaved={saved} />
          )}
          {masterMenus.map(
            (config) =>
              view === config.view &&
              (admin ? (
                <MasterDataView
                  key={config.kind}
                  config={config}
                  data={data}
                  onSaved={saved}
                />
              ) : (
                <div key={config.kind} className="notice amber">
                  Master Data hanya dapat diakses administrator.
                </div>
              )),
          )}
          {view === "Kehadiran" && <AttendanceView {...props} />}
          {[
            "Pengajuan",
            "Cuti",
            "Reimbursement",
            "Petty Cash",
            "Lembur",
          ].includes(view) && (
            <RequestsView key={view} {...props} kind={view} />
          )}
          {view === "General Affair" &&
            (admin ? (
              <InventoryView {...props} />
            ) : (
              <RequestsView {...props} kind="General Affair" />
            ))}
          {view === "Payroll" && <PayrollView {...props} onSaved={saved} />}
          {view === "Mobile" && (
            <MobileView
              data={data}
              open={setForm}
              onAttendance={() => setCamera({})}
              navigate={navigate}
              install={() => void install()}
            />
          )}
          {view === "Pengaturan" &&
            (admin ? (
              <>
                <PageHeading
                  eyebrow="WORKSPACE SETTINGS"
                  title="Pengaturan"
                  subtitle="Atur identitas perusahaan dan kebijakan absensi."
                />
                <div className="settings-layout">
                  <SettingsForm data={data} onSaved={saved} />
                  <section className="panel settings-info">
                    <span className="stat-icon blue">
                      <ShieldCheck size={24} />
                    </span>
                    <h3>Absensi yang terverifikasi</h3>
                    <p>
                      Lokasi diperiksa di server sesuai Service Point / HQ dan
                      izin karyawan. GPS masuk dan keluar tetap dicatat.
                    </p>
                    <div
                      className={`provider-status ${data.faceAvailable ? "connected" : ""}`}
                    >
                      <i />
                      {data.faceAvailable
                        ? "Provider wajah terhubung"
                        : "Provider wajah belum dikonfigurasi"}
                    </div>
                    <p>
                      Karyawan mendaftarkan wajah awal melalui HP setelah akun
                      dibuat admin. Verifikasi wajah tetap wajib untuk semua
                      izin lokasi.
                    </p>
                    <span className="settings-info-note">
                      Lokasi awal adalah contoh. Sesuaikan koordinat kantor
                      sebelum digunakan.
                    </span>
                  </section>
                </div>
              </>
            ) : (
              <MobileView
                data={data}
                open={setForm}
                onAttendance={() => setCamera({})}
                navigate={navigate}
                install={() => void install()}
              />
            ))}
          <footer className="app-footer">
            <span>
              © {new Date().getFullYear()} PeopleOS{" "}
              <span className="footer-dot">·</span> Dibuat untuk tim yang hebat.
            </span>
            <span>
              <span className="live-dot" /> {data.settings.company}
            </span>
          </footer>
        </main>
      </div>
      <nav className="mobile-bottom-nav">
        {[
          { v: "Dashboard", label: "Beranda", icon: LayoutDashboard },
          { v: "Kehadiran", label: "Absensi", icon: ScanFace },
          { v: "Pengajuan", label: "Pengajuan", icon: FileText },
          { v: "Mobile", label: "Saya", icon: Users },
        ].map(({ v, label, icon: Icon }) => (
          <button
            key={v}
            onClick={() => navigate(v as View)}
            className={view === v ? "active" : ""}
          >
            <Icon size={21} />
            <span>{label}</span>
          </button>
        ))}
      </nav>
      {form && (
        <Forms
          form={form}
          data={data}
          onClose={() => setForm(null)}
          onSaved={saved}
        />
      )}
      {employee && (
        <EmployeeDetail
          employee={
            data.employees.find((e) => e.id === employee.id) || employee
          }
          data={data}
          onClose={() => setEmployee(null)}
          open={setForm}
          onEnroll={() => {
            setCamera({ enrollID: employee.id });
            setEmployee(null);
          }}
        />
      )}
      {camera && (
        <AttendanceCamera
          data={data}
          enrollID={camera.enrollID}
          onClose={() => setCamera(null)}
          onSaved={saved}
        />
      )}
      {notifications && (
        <Modal
          title="Pusat notifikasi"
          subtitle={`${pending.length} pengajuan menunggu persetujuan`}
          onClose={() => setNotifications(false)}
        >
          <div className="notification-list">
            {pending.length ? (
              pending.map((r) => (
                <button
                  key={r.id}
                  onClick={() => {
                    if (admin && r.employeeId !== data.actor.employeeId)
                      review(r, "Disetujui");
                    else {
                      setNotifications(false);
                      navigate(r.kind as View);
                    }
                  }}
                >
                  <span className="stat-icon blue">
                    <FileText size={19} />
                  </span>
                  <span>
                    <strong>{r.title}</strong>
                    <small>
                      {r.employeeName} · {r.kind}
                    </small>
                  </span>
                  <ChevronRight size={15} />
                </button>
              ))
            ) : (
              <p className="muted">
                Semua beres. Tidak ada pengajuan menunggu.
              </p>
            )}
          </div>
        </Modal>
      )}
      {installHelp && (
        <Modal
          title="Pasang PeopleOS di ponsel"
          subtitle="Gunakan aplikasi langsung dari layar utama."
          onClose={() => setInstallHelp(false)}
        >
          <div className="install-help">
            <Smartphone size={42} />
            <h3>Android / Chrome</h3>
            <p>
              Buka menu browser (⋮), lalu pilih <strong>Install app</strong>{" "}
              atau <strong>Tambahkan ke layar utama</strong>.
            </p>
            <h3>iPhone / Safari</h3>
            <p>
              Ketuk tombol <strong>Bagikan</strong>, pilih{" "}
              <strong>Tambahkan ke Layar Utama</strong>, lalu ketuk Tambah.
            </p>
            <p className="form-note">
              Pemasangan dan akses kamera/GPS memerlukan HTTPS, kecuali pada
              localhost untuk pengembangan.
            </p>
          </div>
        </Modal>
      )}
      {toast && (
        <div role="status" className="toast">
          <CheckCircle2 size={19} />
          <span>{toast}</span>
          <button onClick={() => setToast("")} aria-label="Tutup pemberitahuan">
            <X size={15} />
          </button>
        </div>
      )}
    </div>
  );
}
function Brand() {
  return (
    <div className="brand">
      <span>
        <Users size={23} fill="currentColor" strokeWidth={1.5} />
      </span>
      <strong>
        people<span>OS</span>
        <i />
      </strong>
    </div>
  );
}
function Login({
  demo,
  initialError,
  onLogin,
}: {
  demo: boolean;
  initialError: string;
  onLogin: () => Promise<void>;
}) {
  const [email, setEmail] = useState(""),
    [password, setPassword] = useState(""),
    [busy, setBusy] = useState(false),
    [error, setError] = useState(initialError);
  async function signIn(e?: React.FormEvent, demoRole?: string) {
    e?.preventDefault();
    setBusy(true);
    setError("");
    try {
      await post("/auth/login", {
        email: demoRole
          ? demoRole === "admin"
            ? "admin@mdm.local"
            : "nadia@mdm.local"
          : email,
        password: demoRole ? "DemoHris2026!" : password,
      });
      await onLogin();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <div className="login-page">
      <section className="login-story">
        <Brand />
        <div className="login-story-content">
          <span className="login-pill">
            <span className="live-dot" /> PEOPLE FIRST. ALWAYS.
          </span>
          <h1>
            Tim yang hebat.
            <br />
            Pengelolaan yang
            <br />
            <em>lebih sederhana.</em>
          </h1>
          <p>
            Satu ruang untuk mengelola karyawan,
            <br />
            mendukung tim, dan tumbuh bersama.
          </p>
          <div className="login-mock">
            <div className="login-mock-heading">
              <span className="stat-icon blue">
                <Users size={21} />
              </span>
              <span>
                <strong>A better day at work</strong>
                <small>Every person. Every possibility.</small>
              </span>
              <span className="mock-check">
                <CheckCircle2 size={24} />
              </span>
            </div>
            <div className="login-avatars">
              {[
                "Aditya Pratama",
                "Nadia Putri",
                "Sarah Wijaya",
                "Bima Santoso",
              ].map((n) => (
                <Avatar key={n} name={n} />
              ))}
              <span>Built around your people.</span>
            </div>
            <div className="login-mock-bars">
              {[45, 65, 52, 80, 68, 92, 76, 100, 85, 95, 78, 90].map((h, i) => (
                <i
                  key={i}
                  style={{ height: `${h}%`, opacity: 0.35 + i * 0.05 }}
                />
              ))}
            </div>
            <span className="login-mock-caption">
              <span className="live-dot" /> Semua terhubung. Semua lebih mudah.
            </span>
          </div>
        </div>
        <footer>EMPLOYEE EXPERIENCE, REIMAGINED.</footer>
        <div className="login-orbit one" />
        <div className="login-orbit two" />
      </section>
      <section className="login-form-section">
        <div className="login-mobile-brand">
          <Brand />
        </div>
        <form className="login-form" onSubmit={signIn}>
          <span className="login-eyebrow">SELAMAT DATANG DI PEOPLEOS</span>
          <h2>Masuk ke ruang kerja</h2>
          <p>Kelola hari kerja Anda dengan lebih mudah.</p>
          <label className="field">
            <span>Email kantor</span>
            <input
              type="email"
              autoComplete="username"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="nama@perusahaan.com"
            />
          </label>
          <label className="field">
            <span>Kata sandi</span>
            <input
              type="password"
              required
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Masukkan kata sandi"
            />
          </label>
          {error && (
            <div role="alert" className="error-message">
              <AlertCircle size={16} />
              {error}
            </div>
          )}
          <Button disabled={busy} className="login-submit">
            {busy ? (
              <Loader2 className="spin" size={18} />
            ) : (
              <>
                Masuk <ArrowRight size={17} />
              </>
            )}
          </Button>
          <span className="login-secure">
            <ShieldCheck size={14} /> Sesi aman · Akses sesuai peran Anda
          </span>
          {demo && (
            <div className="demo-access">
              <div>
                <span />
                Jelajahi dengan data contoh
              </div>
              <p>Coba pengalaman admin atau karyawan.</p>
              <div className="demo-buttons">
                <Button
                  type="button"
                  variant="outline"
                  disabled={busy}
                  onClick={() => void signIn(undefined, "admin")}
                >
                  <Building2 size={16} />
                  Admin demo
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  disabled={busy}
                  onClick={() => void signIn(undefined, "employee")}
                >
                  <Users size={16} />
                  Karyawan demo
                </Button>
              </div>
            </div>
          )}
          <div className="login-support">
            Butuh akses? Hubungi administrator HR Anda.
          </div>
        </form>
        <div className="login-copyright">
          © {new Date().getFullYear()} PeopleOS. Your people, your priority.
        </div>
      </section>
    </div>
  );
}
