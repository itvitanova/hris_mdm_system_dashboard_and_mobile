"use client";
import { SearchSelect } from "./ui/search-select";
import { useState, type FormEvent } from "react";
import { Pencil, Plus, Search, Trash2, Loader2, Database } from "lucide-react";
import type { MasterData, Workspace } from "@/lib/types";
import type { MasterMenu } from "@/lib/master-data";
import { api, post } from "@/lib/api";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Textarea } from "./ui/textarea";
import { Badge, Empty, Field, Modal } from "./common";
import { PageHeading } from "./data-views";

export function MasterDataView({
  config,
  data,
  onSaved,
}: {
  config: MasterMenu;
  data: Workspace;
  onSaved: (message: string) => Promise<void>;
}) {
  const [query, setQuery] = useState(""),
    [filter, setFilter] = useState("all"),
    [editing, setEditing] = useState<MasterData | null>(null),
    [deleting, setDeleting] = useState<MasterData | null>(null),
    [busy, setBusy] = useState(false),
    [error, setError] = useState("");
  const all = data.masterData[config.kind] || [];
  const usage = (id: string) =>
    data.employees.filter(
      (e) =>
        (config.kind === "departments" ? e.departmentId : e.positionId) === id,
    ).length;
  const rows = all.filter(
    (r) =>
      `${r.name} ${r.code} ${r.description}`
        .toLowerCase()
        .includes(query.toLowerCase()) &&
      (filter === "all" || (filter === "active" ? r.active : !r.active)),
  );
  const edit = (row?: MasterData) => {
    setError("");
    setEditing(
      row || { id: "", name: "", code: "", description: "", active: true },
    );
  };
  async function save(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (busy) return;
    setBusy(true);
    setError("");
    const f = new FormData(e.currentTarget);
    try {
      await post(`/master-data/${config.kind}`, {
        id: editing?.id || "",
        code: f.get("code"),
        name: f.get("name"),
        departmentId: f.get("departmentId") || "",
        description: f.get("description"),
        active: f.get("active") === "on",
      });
      await onSaved(`${config.title} berhasil disimpan`);
      setEditing(null);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  async function remove() {
    if (!deleting || busy) return;
    setBusy(true);
    setError("");
    try {
      await api(`/master-data/${config.kind}/${deleting.id}`, {
        method: "DELETE",
      });
      await onSaved(`${config.title} berhasil dihapus`);
      setDeleting(null);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <>
      <PageHeading
        eyebrow="MASTER DATA"
        title={config.title}
        subtitle={config.description}
        actions={
          <Button onClick={() => edit()}>
            <Plus size={17} />
            Tambah {config.title.toLowerCase()}
          </Button>
        }
      />
      <div className="master-summary">
        <div>
          <span className="stat-icon blue">
            <config.icon size={22} />
          </span>
          <span>
            <strong>{all.length}</strong>
            <small>Total {config.title.toLowerCase()}</small>
          </span>
        </div>
        <div>
          <span className="master-summary-dot" />
          <span>
            <strong>{all.filter((r) => r.active).length}</strong>
            <small>Aktif dan dapat dipilih</small>
          </span>
        </div>
        <p>
          Data ini menjadi pilihan pada formulir karyawan. Perubahan nama
          mengikuti profil karyawan yang terhubung.
        </p>
      </div>
      <section className="panel">
        <div className="table-toolbar">
          <label className="search-box">
            <Search size={17} />
            <input
              aria-label={`Cari ${config.title.toLowerCase()}`}
              placeholder="Cari kode atau nama…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </label>
          <div>
            <SearchSelect
              aria-label="Filter status master"
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
            >
              <option value="all">Semua status</option>
              <option value="active">Aktif</option>
              <option value="inactive">Nonaktif</option>
            </SearchSelect>
          </div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Kode</th>
                <th>Nama {config.title.toLowerCase()}</th>
                <th>Keterangan</th>
                <th>Karyawan</th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.id}>
                  <td>
                    <span className="master-code">{row.code}</span>
                  </td>
                  <td>
                    <strong className="table-main">{row.name}</strong>
                    {config.kind === "positions" && (
                      <span className="table-sub">
                        {data.masterData.departments?.find(
                          (d) => d.id === row.departmentId,
                        )?.name || "Departemen belum dihubungkan"}
                      </span>
                    )}
                  </td>
                  <td>
                    <span className="master-description">
                      {row.description || "—"}
                    </span>
                  </td>
                  <td>{usage(row.id)} karyawan</td>
                  <td>
                    <Badge>{row.active ? "Aktif" : "Nonaktif"}</Badge>
                  </td>
                  <td>
                    <div className="inline-actions">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => edit(row)}
                        aria-label={`Edit ${row.name}`}
                      >
                        <Pencil size={14} />
                        Edit
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        aria-label={`Hapus ${row.name}`}
                        title={
                          usage(row.id)
                            ? "Masih digunakan karyawan; nonaktifkan melalui Edit"
                            : "Hapus master"
                        }
                        disabled={usage(row.id) > 0}
                        onClick={() => {
                          setError("");
                          setDeleting(row);
                        }}
                      >
                        <Trash2 size={15} />
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!rows.length && (
          <Empty
            text={
              all.length
                ? "Data tidak ditemukan"
                : `Belum ada ${config.title.toLowerCase()}`
            }
            description="Tambahkan data master atau sesuaikan pencarian Anda."
          />
        )}
        <div className="panel-table-footer">
          {rows.length} dari {all.length} data · Data yang masih digunakan dapat
          dinonaktifkan melalui Edit.
        </div>
      </section>
      {editing && (
        <Modal
          title={`${editing.id ? "Edit" : "Tambah"} ${config.title.toLowerCase()}`}
          subtitle={
            config.kind === "positions"
              ? "Kode jabatan harus unik. Nama yang sama boleh digunakan pada departemen berbeda."
              : "Kode dan nama departemen harus unik."
          }
          onClose={() => {
            if (!busy) setEditing(null);
          }}
        >
          <form onSubmit={save}>
            <div className="form-grid">
              {config.kind === "positions" && (
                <Field label="Departemen *" wide>
                  <SearchSelect
                    name="departmentId"
                    required
                    defaultValue={editing.departmentId || ""}
                  >
                    <option value="" disabled>
                      Pilih departemen
                    </option>
                    {(data.masterData.departments || [])
                      .filter((d) => d.active || d.id === editing.departmentId)
                      .map((d) => (
                        <option key={d.id} value={d.id}>
                          {d.name}
                        </option>
                      ))}
                  </SearchSelect>
                  <small>
                    Jabatan ini hanya tersedia bagi karyawan pada departemen
                    tersebut.
                  </small>
                </Field>
              )}
              <Field label="Kode *">
                <Input
                  name="code"
                  required
                  maxLength={30}
                  defaultValue={editing.code}
                  placeholder={
                    config.kind === "departments"
                      ? "Contoh: DEP-HR"
                      : "Contoh: POS-HRM"
                  }
                />
              </Field>
              <Field label={`Nama ${config.title.toLowerCase()} *`}>
                <Input
                  name="name"
                  required
                  maxLength={120}
                  defaultValue={editing.name}
                  placeholder={
                    config.kind === "departments"
                      ? "Contoh: Human Resources"
                      : "Contoh: HR Manager"
                  }
                />
              </Field>
              <Field label="Keterangan" wide>
                <Textarea
                  name="description"
                  rows={3}
                  maxLength={1000}
                  defaultValue={editing.description}
                  placeholder="Keterangan tambahan (opsional)"
                />
              </Field>
              <label className="master-active-toggle full">
                <input
                  type="checkbox"
                  name="active"
                  defaultChecked={editing.active}
                />
                <span>
                  <strong>Aktif</strong>
                  <small>
                    Tersedia untuk dipilih pada penempatan karyawan baru.
                  </small>
                </span>
              </label>
              {editing.id && usage(editing.id) > 0 && (
                <p className="form-note full">
                  Digunakan oleh {usage(editing.id)} karyawan. Menonaktifkan
                  master tetap mempertahankan penempatan yang sudah ada.
                </p>
              )}
            </div>
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
                onClick={() => setEditing(null)}
              >
                Batal
              </Button>
              <Button disabled={busy} type="submit">
                {busy && <Loader2 size={15} className="spin" />}Simpan
              </Button>
            </footer>
          </form>
        </Modal>
      )}
      {deleting && (
        <Modal
          title={`Hapus ${config.title.toLowerCase()}?`}
          subtitle={deleting.name}
          onClose={() => {
            if (!busy) setDeleting(null);
          }}
        >
          <p className="form-note">
            Data ini belum digunakan karyawan dan akan dihapus dari daftar
            pilihan.
          </p>
          {error && (
            <div className="error-message" role="alert">
              {error}
            </div>
          )}
          <footer className="modal-footer">
            <Button
              variant="outline"
              disabled={busy}
              onClick={() => setDeleting(null)}
            >
              Batal
            </Button>
            <Button disabled={busy} onClick={remove}>
              {busy ? "Menghapus…" : "Hapus data"}
            </Button>
          </footer>
        </Modal>
      )}
    </>
  );
}
