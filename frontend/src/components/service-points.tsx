"use client";
import { SearchSelect } from "./ui/search-select";
import { useState, type FormEvent } from "react";
import { Plus, Pencil, Trash2 } from "lucide-react";
import { api, post } from "@/lib/api";
import type { ServicePoint, Workspace } from "@/lib/types";
import { Field, Modal, Badge, Empty } from "./common";
import { PageHeading } from "./data-views";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { MapLink } from "./map-link";

export function ServicePointsView({
  data,
  onSaved,
}: {
  data: Workspace;
  onSaved: (message: string) => Promise<void>;
}) {
  const [editing, setEditing] = useState<ServicePoint | null>(null),
    [deleting, setDeleting] = useState<ServicePoint | null>(null),
    [busy, setBusy] = useState(false),
    [error, setError] = useState(""),
    [query, setQuery] = useState("");
  const all = data.servicePoints || [];
  const rows = all.filter((p) =>
    `${p.code} ${p.name} ${p.address}`
      .toLowerCase()
      .includes(query.toLowerCase()),
  );
  const edit = (p?: ServicePoint) => {
    setError("");
    setEditing(
      p || {
        id: "",
        code: "",
        name: "",
        kind: "Service Point",
        address: "",
        latitude: 0,
        longitude: 0,
        radius: 100,
        timezone: "Asia/Jakarta",
        workStart: "09:00",
        active: true,
      },
    );
  };
  async function save(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (busy) return;
    setBusy(true);
    setError("");
    const f = new FormData(e.currentTarget);
    try {
      await post("/service-points", {
        ...editing,
        ...Object.fromEntries(f),
        latitude: Number(f.get("latitude")),
        longitude: Number(f.get("longitude")),
        radius: Number(f.get("radius")),
        active: true,
      });
      await onSaved("Lokasi penugasan berhasil disimpan");
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
      await api(`/service-points/${encodeURIComponent(deleting.id)}`, {
        method: "DELETE",
      });
      await onSaved("Lokasi dihapus");
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
        title="Service Point / HQ"
        subtitle="Tentukan lokasi, radius, zona waktu, dan jam masuk untuk setiap penugasan."
      />
      <section className="panel">
        <div className="table-toolbar">
          <Input
            aria-label="Cari lokasi"
            placeholder="Cari kode, lokasi, atau alamat…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
          <Button onClick={() => edit()}>
            <Plus size={16} />
            Tambah lokasi
          </Button>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Lokasi</th>
                <th>Alamat & koordinat</th>
                <th>Kebijakan</th>
                <th>Karyawan</th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((p) => {
                const usage = data.employees.filter(
                  (e) => e.servicePointId === p.id,
                ).length;
                return (
                  <tr key={p.id}>
                    <td>
                      <strong>{p.name}</strong>
                      <div className="muted">
                        {p.code} · {p.kind}
                      </div>
                    </td>
                    <td>
                      {p.address || "—"}
                      <div>
                        <MapLink
                          latitude={p.latitude}
                          longitude={p.longitude}
                        />
                      </div>
                    </td>
                    <td>
                      {p.radius} m · {p.timezone}
                      <div>Masuk {p.workStart}</div>
                      <div>Pulang {p.workEnd || "Belum diatur"}</div>
                    </td>
                    <td>{usage}</td>
                    <td>
                      <Badge>{p.active ? "Aktif" : "Nonaktif"}</Badge>
                    </td>
                    <td>
                      <Button
                        variant="ghost"
                        aria-label={`Edit ${p.name}`}
                        onClick={() => edit(p)}
                      >
                        <Pencil size={16} />
                      </Button>
                      <Button
                        variant="ghost"
                        disabled={usage > 0 || p.id === "HQ"}
                        aria-label={`Hapus ${p.name}`}
                        onClick={() => {
                          setError("");
                          setDeleting(p);
                        }}
                      >
                        <Trash2 size={16} />
                      </Button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        {!rows.length && (
          <Empty
            text="Belum ada lokasi"
            description="Tambahkan Service Point untuk penempatan karyawan."
          />
        )}
      </section>
      {editing && (
        <Modal
          title={
            editing.id ? "Edit lokasi penugasan" : "Tambah lokasi penugasan"
          }
          subtitle="Gunakan titik lokasi yang sesuai di Google Maps. Koordinat memakai titik desimal."
          onClose={() => {
            if (!busy) setEditing(null);
          }}
        >
          <form onSubmit={save}>
            <div className="form-grid">
              <Field label="Kode *">
                <Input
                  name="code"
                  required
                  maxLength={30}
                  defaultValue={editing.code}
                />
              </Field>
              <Field label="Nama lokasi *">
                <Input
                  name="name"
                  required
                  maxLength={120}
                  defaultValue={editing.name}
                />
              </Field>
              <Field label="Jenis lokasi">
                <SearchSelect name="kind" defaultValue={editing.kind}>
                  <option>Service Point</option>
                  <option>HQ</option>
                </SearchSelect>
              </Field>
              <Field label="Zona waktu">
                <SearchSelect name="timezone" defaultValue={editing.timezone}>
                  <option value="Asia/Jakarta">WIB</option>
                  <option value="Asia/Makassar">WITA</option>
                  <option value="Asia/Jayapura">WIT</option>
                </SearchSelect>
              </Field>
              <Field label="Latitude *">
                <Input
                  name="latitude"
                  type="number"
                  step="any"
                  min={-90}
                  max={90}
                  required
                  defaultValue={editing.latitude}
                />
              </Field>
              <Field label="Longitude *">
                <Input
                  name="longitude"
                  type="number"
                  step="any"
                  min={-180}
                  max={180}
                  required
                  defaultValue={editing.longitude}
                />
              </Field>
              <Field label="Radius absensi (meter) *">
                <Input
                  name="radius"
                  type="number"
                  min={10}
                  max={10000}
                  required
                  defaultValue={editing.radius}
                />
              </Field>
              <Field label="Jam masuk *">
                <Input
                  name="workStart"
                  type="time"
                  required
                  defaultValue={editing.workStart}
                />
              </Field>
              <Field label="Jam pulang">
                <Input
                  name="workEnd"
                  type="time"
                  defaultValue={editing.workEnd || ""}
                />
                <small>
                  Isi untuk mencatat pulang lebih awal beserta alasannya. Jadwal
                  pada hari yang sama.
                </small>
              </Field>
              <Field label="Alamat" wide>
                <Input
                  name="address"
                  maxLength={1000}
                  defaultValue={editing.address}
                />
              </Field>
            </div>
            {error && (
              <p role="alert" className="notice amber">
                {error}
              </p>
            )}
            <div className="form-actions">
              <Button
                type="button"
                variant="outline"
                disabled={busy}
                onClick={() => setEditing(null)}
              >
                Batal
              </Button>
              <Button disabled={busy}>
                {busy ? "Menyimpan…" : "Simpan lokasi"}
              </Button>
            </div>
          </form>
        </Modal>
      )}
      {deleting && (
        <Modal
          title="Hapus lokasi?"
          subtitle={deleting.name}
          onClose={() => {
            if (!busy) setDeleting(null);
          }}
        >
          <p>Lokasi yang masih digunakan karyawan tidak dapat dihapus.</p>
          {error && <p role="alert">{error}</p>}
          <div className="form-actions">
            <Button
              variant="outline"
              disabled={busy}
              onClick={() => setDeleting(null)}
            >
              Batal
            </Button>
            <Button disabled={busy} onClick={() => void remove()}>
              Hapus lokasi
            </Button>
          </div>
        </Modal>
      )}
    </>
  );
}
