package domain

import "context"

type Employee struct {
	EmployeeNumber    string `json:"employeeNumber"`
	EmploymentType    string `json:"employmentType"`
	ManagerID         string `json:"managerId"`
	BankName          string `json:"bankName"`
	BankAccountName   string `json:"bankAccountName"`
	BankAccountNumber string `json:"bankAccountNumber"`
	FinanceVerifier   bool   `json:"financeVerifier"`
	ServicePointID    string `json:"servicePointId"`
	AllowAnyLocation  bool   `json:"allowAnyLocation"`
	ID                string `json:"id"`
	Name              string `json:"name"`
	Email             string `json:"email"`
	Department        string `json:"department"`
	Position          string `json:"position"`
	DepartmentID      string `json:"departmentId"`
	PositionID        string `json:"positionId"`
	Status            string `json:"status"`
	Phone             string `json:"phone"`
	Address           string `json:"address"`
	BirthDate         string `json:"birthDate"`
	JoinDate          string `json:"joinDate"`
	Salary            int64  `json:"salary"`
	PTKP              string `json:"ptkp"`
	LeaveBalance      int    `json:"leaveBalance"`
	FaceEnrolled      bool   `json:"faceEnrolled"`
}
type MasterData struct {
	DepartmentID string `json:"departmentId,omitempty"`
	ID           string `json:"id"`
	Code         string `json:"code"`
	Name         string `json:"name"`
	Description  string `json:"description"`
	Active       bool   `json:"active"`
}
type User struct {
	ID           string `json:"id"`
	EmployeeID   string `json:"employeeId"`
	Email        string `json:"email"`
	Role         string `json:"role"`
	PasswordHash string `json:"passwordHash"`
}
type Actor struct {
	ID         string `json:"id"`
	EmployeeID string `json:"employeeId"`
	Email      string `json:"email"`
	Role       string `json:"role"`
	Name       string `json:"name"`
}
type Session struct {
	ID        string `json:"id"`
	UserID    string `json:"userId"`
	ExpiresAt int64  `json:"expiresAt"`
}
type Request struct {
	Unread       bool            `json:"unread"`
	UpdateToken  string          `json:"updateToken"`
	PendingWith  string          `json:"pendingWith"`
	Version      int             `json:"version"`
	Revision     int             `json:"revision"`
	Items        []ExpenseItem   `json:"items"`
	Snapshot     RequestSnapshot `json:"snapshot"`
	Steps        []ApprovalStep  `json:"steps"`
	CurrentStep  int             `json:"currentStep"`
	History      []ApprovalEvent `json:"history"`
	FinalizedAt  string          `json:"finalizedAt"`
	CanReview    bool            `json:"canReview"`
	CanDownload  bool            `json:"canDownload"`
	ID           string          `json:"id"`
	EmployeeID   string          `json:"employeeId"`
	EmployeeName string          `json:"employeeName"`
	Kind         string          `json:"kind"`
	Title        string          `json:"title"`
	Description  string          `json:"description"`
	Amount       int64           `json:"amount"`
	StartDate    string          `json:"startDate"`
	EndDate      string          `json:"endDate"`
	Hours        float64         `json:"hours"`
	Days         int             `json:"days"`
	Status       string          `json:"status"`
	CreatedAt    string          `json:"createdAt"`
	ReviewedBy   string          `json:"reviewedBy"`
	ReviewNote   string          `json:"reviewNote"`
}
type Inventory struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Category string `json:"category"`
	Unit     string `json:"unit"`
	Stock    int    `json:"stock"`
	Minimum  int    `json:"minimum"`
}
type StockMovement struct {
	ID        string `json:"id"`
	ItemID    string `json:"itemId"`
	Quantity  int    `json:"quantity"`
	Note      string `json:"note"`
	ActorID   string `json:"actorId"`
	CreatedAt string `json:"createdAt"`
}
type Attendance struct {
	EarlyDeparture   bool                `json:"earlyDeparture"`
	EarlyMinutes     int                 `json:"earlyMinutes"`
	EarlyReason      string              `json:"earlyReason"`
	ScheduledEnd     string              `json:"scheduledEnd"`
	CheckInLocation  *AttendanceLocation `json:"checkInLocation,omitempty"`
	CheckOutLocation *AttendanceLocation `json:"checkOutLocation,omitempty"`
	ID               string              `json:"id"`
	EmployeeID       string              `json:"employeeId"`
	EmployeeName     string              `json:"employeeName"`
	Date             string              `json:"date"`
	CheckIn          string              `json:"checkIn"`
	CheckOut         string              `json:"checkOut"`
	Status           string              `json:"status"`
	Latitude         float64             `json:"latitude"`
	Longitude        float64             `json:"longitude"`
	Accuracy         float64             `json:"accuracy"`
	Distance         float64             `json:"distance"`
	FaceVerified     bool                `json:"faceVerified"`
}
type ServicePoint struct {
	WorkEnd   string  `json:"workEnd"`
	ID        string  `json:"id"`
	Code      string  `json:"code"`
	Name      string  `json:"name"`
	Kind      string  `json:"kind"`
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Radius    float64 `json:"radius"`
	Timezone  string  `json:"timezone"`
	WorkStart string  `json:"workStart"`
	Active    bool    `json:"active"`
}
type AttendancePolicy struct {
	ServicePoint
	AllowAnyLocation bool `json:"allowAnyLocation"`
}

// Immutable snapshots retain the actual coordinates and policy used at each punch.
type AttendanceLocation struct {
	Latitude  float64          `json:"latitude"`
	Longitude float64          `json:"longitude"`
	Accuracy  float64          `json:"accuracy"`
	Distance  float64          `json:"distance"`
	Policy    AttendancePolicy `json:"policy"`
}
type Payroll struct {
	Version        int    `json:"version"`
	Revision       int    `json:"revision"`
	ID             string `json:"id"`
	EmployeeID     string `json:"employeeId"`
	EmployeeName   string `json:"employeeName"`
	Department     string `json:"department"`
	Position       string `json:"position"`
	CompanyName    string `json:"companyName"`
	CompanyAddress string `json:"companyAddress"`
	CompanyLogo    string `json:"companyLogo"`
	Period         string `json:"period"`
	BaseSalary     int64  `json:"baseSalary"`
	Allowance      int64  `json:"allowance"`
	Bonus          int64  `json:"bonus"`
	GrossSalary    int64  `json:"grossSalary"`
	PTKP           string `json:"ptkp"`
	TaxCategory    string `json:"taxCategory"`
	TaxRateBps     int64  `json:"taxRateBps"`
	PPh21          int64  `json:"pph21"`
	TaxMode        string `json:"taxMode"`
	ManualPPh21    *int64 `json:"manualPph21"`
	TaxNote        string `json:"taxNote"`
	TaxReady       bool   `json:"taxReady"`
	LastTaxPeriod  bool   `json:"lastTaxPeriod"`
	BPJSHealth     int64  `json:"bpjsHealth"`
	JHT            int64  `json:"jht"`
	JP             int64  `json:"jp"`
	FinalizedAt    string `json:"finalizedAt"`
	FinalizedBy    string `json:"finalizedBy"`
	Overtime       int64  `json:"overtime"`
	Reimbursement  int64  `json:"reimbursement"`
	Deductions     int64  `json:"deductions"`
	NetSalary      int64  `json:"netSalary"`
	Status         string `json:"status"`
}
type Settings struct {
	WorkEnd        string  `json:"workEnd"`
	ID             string  `json:"id"`
	Company        string  `json:"company"`
	CompanyAddress string  `json:"companyAddress"`
	CompanyLogo    string  `json:"companyLogo"`
	LocationName   string  `json:"locationName"`
	Latitude       float64 `json:"latitude"`
	Longitude      float64 `json:"longitude"`
	Radius         float64 `json:"radius"`
	WorkStart      string  `json:"workStart"`
	Timezone       string  `json:"timezone"`
}
type Audit struct {
	ID        string `json:"id"`
	ActorID   string `json:"actorId"`
	Action    string `json:"action"`
	Target    string `json:"target"`
	CreatedAt string `json:"createdAt"`
}

// Store separates business modules from persistence. Within commits all changes atomically.
type Store interface {
	List(context.Context, string, any) error
	Get(context.Context, string, string, any) error
	Put(context.Context, string, string, any) error
	Delete(context.Context, string, string) error
	Within(context.Context, func(Store) error) error
}
