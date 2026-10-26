export type Actor = {
  id: string;
  employeeId: string;
  email: string;
  role: "admin" | "employee";
  name: string;
};
export type Employee = {
  employeeNumber?: string;
  employmentType?: string;
  managerId?: string;
  bankName?: string;
  bankAccountName?: string;
  bankAccountNumber?: string;
  financeVerifier?: boolean;
  servicePointId: string;
  allowAnyLocation: boolean;
  id: string;
  name: string;
  email: string;
  department: string;
  position: string;
  departmentId: string;
  positionId: string;
  status: string;
  phone: string;
  address: string;
  birthDate: string;
  joinDate: string;
  salary: number;
  ptkp: string;
  leaveBalance: number;
  faceEnrolled: boolean;
};
export type HRRequest = {
  pendingWith?: string;
  unread?: boolean;
  updateToken?: string;
  version?: number;
  revision?: number;
  items?: ExpenseItem[];
  snapshot?: {
    name: string;
    employeeId: string;
    department: string;
    position: string;
    phone: string;
    bankName: string;
    bankAccountName: string;
    bankAccountNumber: string;
    submittedAt: string;
  };
  steps?: ApprovalStep[];
  currentStep?: number;
  history?: ApprovalEvent[];
  finalizedAt?: string;
  canReview?: boolean;
  canDownload?: boolean;
  id: string;
  employeeId: string;
  employeeName: string;
  kind: string;
  title: string;
  description: string;
  amount: number;
  startDate: string;
  endDate: string;
  hours: number;
  days: number;
  status: string;
  createdAt: string;
  reviewedBy: string;
  reviewNote: string;
};
export type Attendance = {
  earlyDeparture?: boolean;
  earlyMinutes?: number;
  earlyReason?: string;
  scheduledEnd?: string;
  checkInLocation?: AttendanceLocation;
  checkOutLocation?: AttendanceLocation;
  id: string;
  employeeId: string;
  employeeName: string;
  date: string;
  checkIn: string;
  checkOut: string;
  status: string;
  latitude: number;
  longitude: number;
  distance: number;
  accuracy: number;
  faceVerified: boolean;
};
export type Inventory = {
  id: string;
  name: string;
  category: string;
  unit: string;
  stock: number;
  minimum: number;
};
export type Payroll = {
  version: number;
  revision: number;
  position: string;
  companyName: string;
  companyAddress: string;
  companyLogo: string;
  allowance: number;
  bonus: number;
  grossSalary: number;
  ptkp: string;
  taxCategory: string;
  taxRateBps: number;
  pph21: number;
  taxMode: "auto" | "manual";
  manualPph21: number | null;
  taxNote: string;
  taxReady: boolean;
  lastTaxPeriod: boolean;
  bpjsHealth: number;
  jht: number;
  jp: number;
  finalizedAt: string;
  finalizedBy: string;
  id: string;
  employeeId: string;
  employeeName: string;
  department: string;
  period: string;
  baseSalary: number;
  overtime: number;
  reimbursement: number;
  deductions: number;
  netSalary: number;
  status: string;
};
export type Settings = {
  companyAddress: string;
  companyLogo: string;
  id: string;
  company: string;
  locationName: string;
  latitude: number;
  longitude: number;
  radius: number;
  workStart: string;
  workEnd?: string;
  timezone: string;
};
export type ServicePoint = {
  id: string;
  code: string;
  name: string;
  kind: string;
  address: string;
  latitude: number;
  longitude: number;
  radius: number;
  timezone: string;
  workStart: string;
  workEnd?: string;
  active: boolean;
};
export type AttendancePolicy = ServicePoint & { allowAnyLocation: boolean };
export type AttendanceLocation = {
  latitude: number;
  longitude: number;
  accuracy: number;
  distance: number;
  policy: AttendancePolicy;
};
export type Workspace = {
  approvalAccess?: boolean;
  approvalPolicies?: ApprovalPolicy[];
  servicePoints?: ServicePoint[];
  attendancePolicy?: AttendancePolicy;
  attendanceDate?: string;
  masterData: Partial<Record<"departments" | "positions", MasterData[]>>;
  actor: Actor;
  employees: Employee[];
  requests: HRRequest[];
  attendance: Attendance[];
  inventory: Inventory[];
  payroll: Payroll[];
  settings: Settings;
  faceAvailable: boolean;
  demo: boolean;
  stockMovements: {
    id: string;
    itemId: string;
    quantity: number;
    note: string;
    createdAt: string;
  }[];
};
export type View =
  | "Persetujuan"
  | "Alur Persetujuan"
  | "Service Point"
  | "Departemen"
  | "Jabatan"
  | "Pengajuan"
  | "Dashboard"
  | "Karyawan"
  | "Kehadiran"
  | "Cuti"
  | "Payroll"
  | "Reimbursement"
  | "General Affair"
  | "Petty Cash"
  | "Lembur"
  | "Pengaturan"
  | "Mobile";

export type MasterData = {
  departmentId?: string;
  id: string;
  code: string;
  name: string;
  description: string;
  active: boolean;
};
export type ExpenseItem = {
  date: string;
  description: string;
  category: string;
  amount: number;
  receiptId: string;
};
export type ApprovalEvent = {
  revision: number;
  step: number;
  employeeId: string;
  name: string;
  decision: string;
  note: string;
  at: string;
};
export type ApprovalStep = {
  name: string;
  source: string;
  mode: string;
  status: string;
  approvers: { employeeId: string; name: string }[];
  decisions: ApprovalEvent[];
};
export type ApprovalStage = {
  name: string;
  source: string;
  level: number;
  employeeIds: string[];
  mode: string;
};
export type ApprovalPolicy = { id: string; stages: ApprovalStage[] };
