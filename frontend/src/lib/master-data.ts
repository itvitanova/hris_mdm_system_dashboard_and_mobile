import { Building2, BriefcaseBusiness } from "lucide-react";
// Register future master-data submenus here and their backend kind in masterKinds.
export const masterMenus = [
  {
    view: "Departemen",
    kind: "departments",
    title: "Departemen",
    description: "Kelola struktur departemen untuk penempatan karyawan.",
    icon: Building2,
  },
  {
    view: "Jabatan",
    kind: "positions",
    title: "Jabatan",
    description: "Kelola daftar jabatan yang digunakan di seluruh perusahaan.",
    icon: BriefcaseBusiness,
  },
] as const;
export type MasterMenu = (typeof masterMenus)[number];
