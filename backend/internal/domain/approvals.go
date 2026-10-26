package domain

type ExpenseItem struct {
	Date        string `json:"date"`
	Description string `json:"description"`
	Category    string `json:"category"`
	Amount      int64  `json:"amount"`
	ReceiptID   string `json:"receiptId"`
}
type RequestSnapshot struct {
	EmployeeID        string `json:"employeeId"`
	Name              string `json:"name"`
	Department        string `json:"department"`
	Position          string `json:"position"`
	Phone             string `json:"phone"`
	BankName          string `json:"bankName"`
	BankAccountName   string `json:"bankAccountName"`
	BankAccountNumber string `json:"bankAccountNumber"`
	SubmittedAt       string `json:"submittedAt"`
	Timezone          string `json:"timezone"`
	TemplateVersion   string `json:"templateVersion"`
}
type ApprovalStage struct {
	Name        string   `json:"name"`
	Source      string   `json:"source"` // manager, employees, finance
	Level       int      `json:"level"`
	EmployeeIDs []string `json:"employeeIds"`
	Mode        string   `json:"mode"` // any, all
}
type ApprovalPolicy struct {
	ID     string          `json:"id"`
	Stages []ApprovalStage `json:"stages"`
}
type Approver struct {
	EmployeeID string `json:"employeeId"`
	Name       string `json:"name"`
}
type ApprovalEvent struct {
	Revision   int    `json:"revision"`
	Step       int    `json:"step"`
	EmployeeID string `json:"employeeId"`
	Name       string `json:"name"`
	Decision   string `json:"decision"`
	Note       string `json:"note"`
	At         string `json:"at"`
}
type ApprovalStep struct {
	Name      string          `json:"name"`
	Source    string          `json:"source"`
	Mode      string          `json:"mode"`
	Approvers []Approver      `json:"approvers"`
	Decisions []ApprovalEvent `json:"decisions"`
	Status    string          `json:"status"`
}
type RequestReceipt struct {
	ID          string `json:"id"`
	EmployeeID  string `json:"employeeId"`
	Name        string `json:"name"`
	ContentType string `json:"contentType"`
	Data        []byte `json:"data"`
}
type RequestDocument struct {
	ID       string `json:"id"`
	Workbook []byte `json:"workbook"`
	PDF      []byte `json:"pdf"`
}
