export const ptkpOptions = [
  "TK/0",
  "TK/1",
  "TK/2",
  "TK/3",
  "K/0",
  "K/1",
  "K/2",
  "K/3",
];
export function taxCategory(ptkp: string) {
  return ["TK/0", "TK/1", "K/0"].includes(ptkp)
    ? "A"
    : ["TK/2", "TK/3", "K/1", "K/2"].includes(ptkp)
      ? "B"
      : ptkp === "K/3"
        ? "C"
        : "";
}
export async function downloadFile(path: string, filename: string) {
  const r = await fetch(`/api${path}`, {
    credentials: "same-origin",
    cache: "no-store",
  });
  if (!r.ok) {
    const b = await r.json().catch(() => ({ error: "Unduhan gagal" }));
    throw new Error(b.error || "Unduhan gagal");
  }
  const url = URL.createObjectURL(await r.blob());
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
export function readDataURL(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = () => reject(new Error("File tidak dapat dibaca"));
    reader.readAsDataURL(file);
  });
}
