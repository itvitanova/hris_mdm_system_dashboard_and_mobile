"use client";
import { useEffect, useId, useRef, type ReactNode } from "react";
import { X, Inbox } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge as BadgeUI } from "@/components/ui/badge";
export function Avatar({
  name,
  size = "md",
}: {
  name: string;
  size?: "sm" | "md" | "lg";
}) {
  const colors = ["#e9efff", "#f2eaff", "#e4f5f0", "#fff0e3", "#e7f2fc"];
  const n = name.split("").reduce((s, c) => s + c.charCodeAt(0), 0);
  return (
    <span
      className={`avatar avatar-${size}`}
      style={{ background: colors[n % colors.length] }}
    >
      {name
        .split(" ")
        .slice(0, 2)
        .map((x) => x[0])
        .join("")}
    </span>
  );
}
export function Badge({ children }: { children: ReactNode }) {
  const value = String(children);
  const cls = ["Aktif", "Hadir", "Disetujui", "Final"].includes(value)
    ? "green"
    : ["Menunggu", "Terlambat", "Probation", "Draft", "Perlu restock"].includes(
          value,
        )
      ? "amber"
      : ["Ditolak", "Nonaktif"].includes(value)
        ? "red"
        : "blue";
  return (
    <BadgeUI
      variant="outline"
      className={`badge ${cls} border-0 font-medium shadow-none`}
    >
      <i />
      {children}
    </BadgeUI>
  );
}
export function Empty({
  text = "Belum ada data",
  description = "Data akan muncul di sini setelah ditambahkan.",
}: {
  text?: string;
  description?: string;
}) {
  return (
    <div className="empty">
      <Inbox size={30} />
      <strong>{text}</strong>
      <span>{description}</span>
    </div>
  );
}
export function Modal({
  title,
  subtitle,
  children,
  onClose,
}: {
  title: string;
  subtitle?: string;
  children: ReactNode;
  onClose: () => void;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  useEffect(() => {
    const d = ref.current;
    d?.showModal();
    const old = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      d?.close();
      document.body.style.overflow = old;
    };
  }, []);
  return (
    <dialog
      ref={ref}
      className="modal"
      aria-labelledby={titleId}
      onCancel={(e) => {
        e.preventDefault();
        onClose();
      }}
      onClick={(e) => {
        if (e.target === ref.current) onClose();
      }}
    >
      <div className="modal-body">
        <header>
          <div>
            <h2 id={titleId}>{title}</h2>
            {subtitle && <p>{subtitle}</p>}
          </div>
          <Button
            variant="ghost"
            size="icon"
            aria-label="Tutup dialog"
            onClick={onClose}
          >
            <X size={19} />
          </Button>
        </header>
        {children}
      </div>
    </dialog>
  );
}
export function Field({
  label,
  children,
  wide = false,
}: {
  label: string;
  children: ReactNode;
  wide?: boolean;
}) {
  return (
    <label className={wide ? "field full" : "field"}>
      <span>{label}</span>
      {children}
    </label>
  );
}
