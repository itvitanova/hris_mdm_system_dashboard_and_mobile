"use client";
import { SearchSelect } from "./ui/search-select";
import { useEffect, useState } from "react";
import { Button } from "./ui/button";
import { Badge, Empty, Modal } from "./common";
import { displayDate, post, rupiah } from "@/lib/api";
import type {
  ApprovalPolicy,
  ApprovalStage,
  ExpenseItem,
  HRRequest,
  Workspace,
} from "@/lib/types";

export async function downloadRequest(path: string, filename: string) {
  const response = await fetch(`/api${path}`, {
    credentials: "same-origin",
    cache: "no-store",
  });
  if (!response.ok) {
    const body = await response
      .json()
      .catch(() => ({ error: "Dokumen tidak dapat diunduh" }));
    throw new Error(body.error);
  }
  const blob = await response.blob();
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  const extension = blob.type.includes("pdf")
    ? ".pdf"
    : blob.type.includes("png")
      ? ".png"
      : blob.type.includes("jpeg")
        ? ".jpg"
        : "";
  link.download = filename.includes(".") ? filename : filename + extension;
  link.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
export function RequestDetails({ request: r }: { request: HRRequest }) {
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [preview, setPreview] = useState<{
    url: string;
    image: boolean;
    path: string;
  } | null>(null);
  async function download(path: string, name: string) {
    setBusy(true);
    setError("");
    try {
      await downloadRequest(path, name);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  async function showReceipt(path: string) {
    setBusy(true);
    setError("");
    try {
      const response = await fetch(`/api${path}`, {
        credentials: "same-origin",
        cache: "no-store",
      });
      if (!response.ok)
        throw new Error("Bukti tidak dapat dibuka atau akses telah berubah.");
      const blob = await response.blob();
      setPreview({
        url: URL.createObjectURL(blob),
        image: blob.type.startsWith("image/"),
        path,
      });
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  useEffect(
    () => () => {
      if (preview) URL.revokeObjectURL(preview.url);
    },
    [preview],
  );
  useEffect(() => {
    if (r.unread && r.updateToken)
      void post(`/requests/${encodeURIComponent(r.id)}/seen`, {
        token: r.updateToken,
      }).catch(() => {});
  }, [r.id, r.updateToken, r.unread]);
  function closePreview() {
    if (preview) URL.revokeObjectURL(preview.url);
    setPreview(null);
  }
  return (
    <div className="request-details">
      <section className="request-summary-banner">
        <div>
          <Badge>{r.status}</Badge>
          <h3>{r.title}</h3>
          <p>
            {r.employeeName} · {r.kind}
          </p>
        </div>
        {r.amount > 0 && (
          <div>
            <span>Total pengajuan</span>
            <strong>{rupiah(r.amount)}</strong>
          </div>
        )}
      </section>
      {r.pendingWith && (
        <p className="request-pending" role="status">
          {r.pendingWith}
        </p>
      )}
      <dl className="request-info-grid">
        <div>
          <dt>Diajukan</dt>
          <dd>{displayDate(r.createdAt)}</dd>
        </div>
        <div>
          <dt>Periode transaksi / pengajuan</dt>
          <dd>
            {displayDate(r.startDate)}
            {r.endDate !== r.startDate ? ` – ${displayDate(r.endDate)}` : ""}
          </dd>
        </div>
        <div className="full">
          <dt>Keperluan</dt>
          <dd>{r.description}</dd>
        </div>
      </dl>
      {r.reviewNote && (
        <div className="request-review-note">
          <strong>
            {r.status === "Perlu revisi"
              ? "Perlu diperbaiki"
              : "Catatan peninjau"}
          </strong>
          <p>{r.reviewNote}</p>
        </div>
      )}
      {!!r.items?.length && (
        <section>
          <h3>Rincian pengeluaran</h3>
          <div className="expense-detail-list">
            {r.items.map((item, i) => (
              <article key={i} className="expense-detail-card">
                <header>
                  <span className="expense-number">{i + 1}</span>
                  <div>
                    <strong>{item.description}</strong>
                    <p>
                      {displayDate(item.date)} · {item.category}
                    </p>
                  </div>
                  <strong className="expense-detail-amount">
                    {rupiah(item.amount)}
                  </strong>
                </header>
                <Button
                  className="request-proof-button"
                  variant="outline"
                  disabled={busy}
                  onClick={() =>
                    void showReceipt(
                      `/requests/${encodeURIComponent(r.id)}/receipts/${encodeURIComponent(item.receiptId)}`,
                    )
                  }
                >
                  Lihat bukti transaksi {i + 1}
                </Button>
              </article>
            ))}
          </div>
        </section>
      )}
      {r.snapshot && (
        <details className="request-identity">
          <summary>Data pemohon dan rekening</summary>
          <dl className="request-info-grid">
            <div>
              <dt>Pemohon</dt>
              <dd>{r.snapshot.name}</dd>
            </div>
            <div>
              <dt>Departemen / jabatan</dt>
              <dd>
                {r.snapshot.department} · {r.snapshot.position}
              </dd>
            </div>
            <div>
              <dt>Telepon</dt>
              <dd>{r.snapshot.phone || "—"}</dd>
            </div>
            <div>
              <dt>Bank</dt>
              <dd>{r.snapshot.bankName || "—"}</dd>
            </div>
            <div>
              <dt>Pemilik rekening</dt>
              <dd>{r.snapshot.bankAccountName || "—"}</dd>
            </div>
            <div>
              <dt>Nomor rekening</dt>
              <dd>{r.snapshot.bankAccountNumber || "—"}</dd>
            </div>
          </dl>
        </details>
      )}
      {!!r.steps?.length && (
        <section>
          <h3>Alur persetujuan</h3>
          <div className="approval-timeline">
            {r.steps.map((step, i) => (
              <section
                className={`approval-step ${r.status === "Menunggu" && r.currentStep === i ? "is-current" : ""}`}
                key={i}
              >
                <header>
                  <strong>
                    {i + 1}. {step.name}
                  </strong>
                  <Badge>{step.status}</Badge>
                </header>
                <p>{step.approvers.map((a) => a.name).join(", ")}</p>
                {step.status === "Menunggu" && r.status === "Menunggu" && (
                  <small>
                    {r.currentStep === i
                      ? r.pendingWith ||
                        "Menunggu tindakan petugas yang ditugaskan"
                      : "Menunggu tahap sebelumnya"}
                    {r.currentStep === i &&
                    step.approvers.length > 1 &&
                    step.mode === "all"
                      ? ` (${step.decisions.filter((d) => d.decision === "Disetujui").length}/${step.approvers.length} persetujuan)`
                      : ""}
                  </small>
                )}
                {step.decisions.map((d, n) => (
                  <div className="approval-decision" key={n}>
                    <strong>
                      {d.name} · {d.decision}
                    </strong>
                    <time>{new Date(d.at).toLocaleString("id-ID")}</time>
                    {d.note && <p>{d.note}</p>}
                  </div>
                ))}
              </section>
            ))}
          </div>
        </section>
      )}
      {!!r.history?.length && (
        <details className="request-history">
          <summary>Riwayat pengajuan dan keputusan</summary>
          {r.history.map((h, i) => (
            <div className="approval-decision" key={i}>
              <strong>
                {h.name} · {h.decision}
              </strong>
              <time>{new Date(h.at).toLocaleString("id-ID")}</time>
              {h.note && <p>{h.note}</p>}
            </div>
          ))}
        </details>
      )}
      {r.kind === "Reimbursement" && (
        <section className="request-documents">
          <h3>Dokumen reimbursement</h3>
          {r.canDownload ? (
            <div className="approval-actions">
              <Button
                disabled={busy}
                onClick={() =>
                  void download(
                    `/requests/${encodeURIComponent(r.id)}/document/pdf`,
                    `reimbursement-${r.id}.pdf`,
                  )
                }
              >
                Unduh PDF final
              </Button>
              <Button
                variant="outline"
                disabled={busy}
                onClick={() =>
                  void download(
                    `/requests/${encodeURIComponent(r.id)}/document/xlsx`,
                    `reimbursement-${r.id}.xlsx`,
                  )
                }
              >
                Unduh Excel final
              </Button>
            </div>
          ) : (
            <p>
              Dokumen final tersedia setelah persetujuan atasan dan verifikasi
              finance selesai.
            </p>
          )}
          <small>Persetujuan bukan bukti pembayaran.</small>
        </section>
      )}
      {error && (
        <p role="alert" className="error-message">
          {error}
        </p>
      )}
      {preview && (
        <Modal title="Bukti transaksi" onClose={closePreview}>
          <div className="receipt-preview">
            {preview.image ? (
              <img
                src={preview.url}
                alt="Bukti transaksi yang diunggah pemohon"
              />
            ) : (
              <p>Bukti berupa PDF. Buka dokumen untuk memeriksa isinya.</p>
            )}
          </div>
          <div className="modal-footer">
            <a
              className="proof-open-link"
              href={preview.url}
              target="_blank"
              rel="noreferrer"
            >
              {preview.image ? "Buka foto ukuran penuh" : "Buka PDF"}
            </a>
            <Button
              variant="outline"
              onClick={() => void download(preview.path, "bukti-transaksi")}
            >
              Unduh bukti
            </Button>
          </div>
        </Modal>
      )}
    </div>
  );
}
export function ApprovalCenter({
  data,
  onReview,
}: {
  data: Workspace;
  onReview: (r: HRRequest, decision: string) => void;
}) {
  const [tab, setTab] = useState("pending");
  const [query, setQuery] = useState("");
  const rows = data.requests
    .filter(
      (r) =>
        r.employeeId !== data.actor.employeeId &&
        (tab === "pending"
          ? r.canReview
          : (r.steps || []).some((s) =>
              s.decisions.some((d) => d.employeeId === data.actor.employeeId),
            )),
    )
    .filter((r) =>
      `${r.employeeName} ${r.title} ${r.kind}`
        .toLowerCase()
        .includes(query.toLowerCase()),
    );
  if (!data.approvalAccess)
    return (
      <div className="notice amber">
        Anda belum ditetapkan sebagai pemberi persetujuan.
      </div>
    );
  return (
    <>
      <header className="approval-page-heading">
        <h1>Persetujuan</h1>
      </header>
      <p>Tinjau pengajuan yang menjadi tanggung jawab Anda.</p>
      <div className="approval-actions">
        <Button
          variant={tab === "pending" ? "default" : "outline"}
          onClick={() => setTab("pending")}
        >
          Menunggu tindakan saya
        </Button>
        <Button
          variant={tab === "history" ? "default" : "outline"}
          onClick={() => setTab("history")}
        >
          Riwayat keputusan saya
        </Button>
        <input
          aria-label="Cari persetujuan"
          placeholder="Cari pemohon atau pengajuan"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
      </div>
      {!rows.length && (
        <Empty
          text="Tidak ada pengajuan"
          description="Pengajuan yang sesuai akan tampil di sini."
        />
      )}
      {rows.map((r) => (
        <article className="panel approval-request" key={r.id}>
          <div className="approval-title">
            <h2>{r.title}</h2>
            <Badge>{r.status}</Badge>
          </div>
          <p>
            {r.employeeName} · {r.kind} · {displayDate(r.createdAt)}
          </p>
          <p>{r.description}</p>
          <RequestDetails request={r} />
          {r.canReview && (
            <div className="approval-actions">
              <Button onClick={() => onReview(r, "Disetujui")}>
                {r.steps?.[r.currentStep || 0]?.source === "finance"
                  ? "Verifikasi finance"
                  : "Setujui"}
              </Button>
              {r.version === 2 && (
                <Button
                  variant="outline"
                  onClick={() => onReview(r, "Perlu revisi")}
                >
                  Minta revisi
                </Button>
              )}
              <Button variant="outline" onClick={() => onReview(r, "Ditolak")}>
                Tolak
              </Button>
            </div>
          )}
        </article>
      ))}
    </>
  );
}
export function ExpenseEditor({
  items,
  onChange,
  disabled,
  onBusy,
}: {
  items: ExpenseItem[];
  onChange: (items: ExpenseItem[]) => void;
  disabled: boolean;
  onBusy: (busy: boolean) => void;
}) {
  const [error, setError] = useState("");
  const [uploading, setUploading] = useState(-1);
  function update(i: number, patch: Partial<ExpenseItem>) {
    onChange(items.map((v, n) => (n === i ? { ...v, ...patch } : v)));
  }
  async function upload(i: number, file?: File) {
    if (!file) return;
    setError("");
    if (file.size > 2 * 1024 * 1024) {
      setError("Bukti transaksi maksimal 2 MB");
      return;
    }
    setUploading(i);
    onBusy(true);
    try {
      const b64 = await new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(String(reader.result).split(",")[1]);
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });
      const result = await post<{ id: string }>("/request-receipts", {
        name: file.name,
        fileBase64: b64,
      });
      update(i, { receiptId: result.id });
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setUploading(-1);
      onBusy(false);
    }
  }
  return (
    <div className="expense-editor full">
      <h3>Rincian pengeluaran</h3>
      {items.map((item, i) => (
        <fieldset key={i} disabled={disabled || uploading >= 0}>
          <legend>Pengeluaran {i + 1}</legend>
          <div className="form-grid">
            <label>
              Tanggal transaksi *
              <input
                aria-label={`Tanggal transaksi ${i + 1}`}
                type="date"
                required
                value={item.date}
                onChange={(e) => update(i, { date: e.target.value })}
              />
            </label>
            <label>
              Kategori *
              <input
                aria-label={`Kategori ${i + 1}`}
                required
                maxLength={80}
                value={item.category}
                onChange={(e) => update(i, { category: e.target.value })}
              />
            </label>
            <label className="full">
              Deskripsi *
              <input
                aria-label={`Deskripsi ${i + 1}`}
                required
                maxLength={500}
                value={item.description}
                onChange={(e) => update(i, { description: e.target.value })}
              />
            </label>
            <label>
              Jumlah (Rp) *
              <input
                aria-label={`Jumlah ${i + 1}`}
                required
                type="number"
                min={1}
                max={1000000000000}
                step={1}
                value={item.amount || ""}
                onChange={(e) => update(i, { amount: Number(e.target.value) })}
              />
            </label>
            <label>
              Bukti transaksi *
              <input
                aria-label={`Bukti transaksi ${i + 1}`}
                type="file"
                accept="image/png,image/jpeg,application/pdf"
                onChange={(e) => void upload(i, e.target.files?.[0])}
              />
              <small>
                {uploading === i
                  ? "Mengunggah…"
                  : item.receiptId
                    ? "Bukti tersimpan"
                    : "JPEG, PNG, PDF; maksimal 2 MB"}
              </small>
            </label>
          </div>
          <Button
            type="button"
            variant="outline"
            disabled={items.length === 1}
            onClick={() => onChange(items.filter((_, n) => n !== i))}
          >
            Hapus rincian {i + 1}
          </Button>
        </fieldset>
      ))}
      <Button
        type="button"
        variant="outline"
        disabled={disabled || uploading >= 0 || items.length >= 150}
        onClick={() =>
          onChange([
            ...items,
            {
              date: new Date().toLocaleDateString("en-CA"),
              description: "",
              category: "",
              amount: 0,
              receiptId: "",
            },
          ])
        }
      >
        Tambah rincian
      </Button>
      <p>
        <strong>
          Total: {rupiah(items.reduce((n, i) => n + i.amount, 0))}
        </strong>
      </p>
      <small>
        Bukti transaksi wajib. Ketentuan template: pengajuan maksimal 14 hari
        kerja setelah transaksi; peninjau memeriksa kesesuaiannya.
      </small>
      {error && (
        <p role="alert" className="error-message">
          {error}
        </p>
      )}
    </div>
  );
}
export function ApprovalPolicyView({
  data,
  onSaved,
}: {
  data: Workspace;
  onSaved: (message: string) => Promise<void>;
}) {
  return (
    <>
      <header className="approval-page-heading">
        <h1>Alur Persetujuan</h1>
      </header>
      <p>
        Atasan berasal dari data karyawan. Finance berasal dari petugas yang
        ditandai pada data karyawan dan memiliki akun aktif.
      </p>
      {data.approvalPolicies?.map((p) => (
        <PolicyEditor key={p.id} policy={p} data={data} onSaved={onSaved} />
      ))}
    </>
  );
}
function PolicyEditor({
  policy,
  data,
  onSaved,
}: {
  policy: ApprovalPolicy;
  data: Workspace;
  onSaved: (message: string) => Promise<void>;
}) {
  const [stages, setStages] = useState<ApprovalStage[]>(
    policy.stages.map((s) => ({ ...s, employeeIds: s.employeeIds || [] })),
  );
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  function change(i: number, patch: Partial<ApprovalStage>) {
    setStages(stages.map((s, n) => (i === n ? { ...s, ...patch } : s)));
  }
  async function save() {
    setBusy(true);
    setError("");
    try {
      await post("/approval-policies", { id: policy.id, stages });
      await onSaved("Alur persetujuan disimpan");
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <section className="panel approval-request">
      <h2>{policy.id}</h2>
      <fieldset disabled={busy}>
        {stages.map((st, i) => (
          <div className="policy-stage" key={i}>
            <label>
              Nama tahap {i + 1}
              <input
                value={st.name}
                maxLength={100}
                onChange={(e) => change(i, { name: e.target.value })}
              />
            </label>
            <label>
              Sumber approver
              <SearchSelect
                value={st.source}
                onChange={(e) =>
                  change(i, {
                    source: e.target.value,
                    level: 1,
                    employeeIds: [],
                  })
                }
              >
                <option value="manager">Atasan dalam struktur</option>
                <option value="employees">Karyawan tertentu</option>
                {policy.id === "Reimbursement" && (
                  <option value="finance">Kelompok finance</option>
                )}
              </SearchSelect>
            </label>
            {st.source === "manager" && (
              <label>
                Tingkat atasan
                <input
                  type="number"
                  min={1}
                  max={10}
                  value={st.level}
                  onChange={(e) => change(i, { level: Number(e.target.value) })}
                />
              </label>
            )}
            {st.source === "employees" && (
              <label>
                Approver (bisa lebih dari satu)
                <SearchSelect
                  multiple
                  value={st.employeeIds}
                  onChange={(e) =>
                    change(i, {
                      employeeIds: Array.from(
                        e.target.selectedOptions,
                        (o) => o.value,
                      ),
                    })
                  }
                >
                  {data.employees
                    .filter((e) => e.status !== "Nonaktif")
                    .map((e) => (
                      <option key={e.id} value={e.id}>
                        {e.name} · {e.position}
                      </option>
                    ))}
                </SearchSelect>
              </label>
            )}
            <label>
              Aturan tahap
              <SearchSelect
                value={st.mode}
                onChange={(e) => change(i, { mode: e.target.value })}
              >
                <option value="all">Semua wajib menyetujui</option>
                <option value="any">Cukup salah satu</option>
              </SearchSelect>
            </label>
            <Button
              variant="outline"
              onClick={() => setStages(stages.filter((_, n) => n !== i))}
            >
              Hapus tahap {i + 1}
            </Button>
          </div>
        ))}
        <div className="approval-actions">
          <Button
            variant="outline"
            disabled={stages.length >= 10}
            onClick={() => {
              const extra = {
                name: "Persetujuan tambahan",
                source: "manager",
                level: 2,
                mode: "all",
                employeeIds: [],
              };
              setStages(
                policy.id === "Reimbursement"
                  ? [...stages.slice(0, -1), extra, ...stages.slice(-1)]
                  : [...stages, extra],
              );
            }}
          >
            Tambah tahap
          </Button>
          <Button onClick={() => void save()}>Simpan alur {policy.id}</Button>
        </div>
      </fieldset>
      {error && (
        <p role="alert" className="error-message">
          {error}
        </p>
      )}
      <small>
        Perubahan alur berlaku untuk pengajuan baru atau yang dikirim ulang
        setelah revisi.
      </small>
    </section>
  );
}
