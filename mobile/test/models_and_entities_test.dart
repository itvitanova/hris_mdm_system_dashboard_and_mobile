import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/features/auth/data/models/user_model.dart';
import 'package:mdm_hris/features/auth/data/models/employee_model.dart';
import 'package:mdm_hris/features/attendance/data/models/attendance_model.dart';
import 'package:mdm_hris/features/attendance/data/models/attendance_policy_model.dart';
import 'package:mdm_hris/features/requests/data/models/request_model.dart';
import 'package:mdm_hris/features/payroll/data/models/payroll_model.dart';

void main() {
  group('Auth Models & Entities', () {
    test('UserModel serialization and deserialization', () {
      final json = {
        'id': 'user-1',
        'email': 'user@example.com',
        'name': 'Test User',
        'role': 'employee',
        'employeeId': 'EMP-001',
      };
      final model = UserModel.fromJson(json);
      expect(model.id, 'user-1');
      expect(model.email, 'user@example.com');
      expect(model.name, 'Test User');
      expect(model.role, 'employee');
      expect(model.employeeId, 'EMP-001');

      final map = model.toJson();
      expect(map['email'], 'user@example.com');
      expect(map['role'], 'employee');
    });

    test('EmployeeModel serialization and deserialization', () {
      final json = {
        'id': 'EMP-001',
        'employeeNumber': '2026001',
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'department': 'Engineering',
        'position': 'Software Engineer',
        'status': 'Aktif',
        'phone': '081234567890',
        'address': 'Jakarta',
        'birthDate': '1995-01-01',
        'joinDate': '2022-01-01',
        'salary': 15000000,
        'ptkp': 'TK/0',
        'leaveBalance': 12,
        'faceEnrolled': true,
        'employmentType': 'Tetap',
        'bankName': 'BCA',
        'bankAccountName': 'Budi Santoso',
        'bankAccountNumber': '1234567890',
        'financeVerifier': false,
        'allowAnyLocation': false,
      };
      final model = EmployeeModel.fromJson(json);
      expect(model.id, 'EMP-001');
      expect(model.salary, 15000000);
      expect(model.faceEnrolled, isTrue);

      final map = model.toJson();
      expect(map['employeeNumber'], '2026001');
      expect(map['salary'], 15000000);
    });
  });

  group('Attendance Models & Entities', () {
    test('AttendanceModel and AttendancePolicyModel serialization', () {
      final policyJson = {
        'id': 'LOC-1',
        'code': 'HQ',
        'name': 'Head Office',
        'kind': 'Office',
        'address': 'Sudirman',
        'latitude': -6.2,
        'longitude': 106.8,
        'radius': 100.0,
        'timezone': 'Asia/Jakarta',
        'workStart': '08:00',
        'workEnd': '17:00',
        'active': true,
        'allowAnyLocation': false,
      };
      final policy = AttendancePolicyModel.fromJson(policyJson);
      expect(policy.name, 'Head Office');
      expect(policy.radius, 100.0);

      final attendanceJson = {
        'id': 'ATT-001',
        'employeeId': 'EMP-001',
        'employeeName': 'Budi Santoso',
        'date': '2026-10-28',
        'checkIn': '08:05:00',
        'checkOut': '17:02:00',
        'status': 'Tepat Waktu',
        'latitude': -6.2001,
        'longitude': 106.8001,
        'accuracy': 12.5,
        'distance': 15.0,
        'faceVerified': true,
        'earlyDeparture': false,
        'earlyMinutes': 0,
        'checkInLocation': {
          'latitude': -6.2001,
          'longitude': 106.8001,
          'accuracy': 12.5,
          'distance': 15.0,
          'policy': policyJson,
        },
      };
      final attendance = AttendanceModel.fromJson(attendanceJson);
      expect(attendance.id, 'ATT-001');
      expect(attendance.faceVerified, isTrue);
      expect(attendance.checkInLocation?.policy?.name, 'Head Office');

      final map = attendance.toJson();
      expect(map['date'], '2026-10-28');
      expect(map['status'], 'Tepat Waktu');
    });
  });

  group('Requests Models & Entities', () {
    test('RequestModel serialization with items and steps', () {
      final requestJson = {
        'id': 'REQ-001',
        'employeeId': 'EMP-001',
        'employeeName': 'Budi Santoso',
        'kind': 'Reimbursement',
        'title': 'Transportasi Klien',
        'description': 'Kunjungan kerja ke kantor klien',
        'amount': 150000,
        'startDate': '2026-10-28',
        'endDate': '2026-10-28',
        'hours': 0.0,
        'days': 1,
        'status': 'Menunggu',
        'createdAt': '2026-10-28T09:00:00+07:00',
        'reviewedBy': '',
        'reviewNote': '',
        'unread': true,
        'updateToken': 'token123',
        'pendingWith': 'Manager',
        'version': 1,
        'revision': 1,
        'currentStep': 0,
        'canReview': false,
        'canDownload': false,
        'items': [
          {
            'date': '2026-10-28',
            'description': 'Taksi online',
            'category': 'Transportasi',
            'amount': 150000,
            'receiptId': 'RCP-001',
          }
        ],
        'steps': [
          {
            'name': 'Manager Approval',
            'source': 'manager',
            'mode': 'any',
            'status': 'Menunggu',
            'approvers': [
              {'employeeId': 'EMP-MGR', 'name': 'Atasan'}
            ],
            'decisions': [],
          }
        ],
        'history': [],
      };

      final model = RequestModel.fromJson(requestJson);
      expect(model.id, 'REQ-001');
      expect(model.amount, 150000);
      expect(model.items.length, 1);
      expect(model.items.first.amount, 150000);
      expect(model.steps.first.approvers.first.name, 'Atasan');

      final map = model.toJson();
      expect(map['title'], 'Transportasi Klien');
      expect(map['items'], isNotEmpty);
    });
  });

  group('Payroll Models & Entities', () {
    test('PayrollModel serialization and deserialization', () {
      final payrollJson = {
        'id': 'PAY-001',
        'employeeId': 'EMP-001',
        'employeeName': 'Budi Santoso',
        'department': 'Engineering',
        'position': 'Software Engineer',
        'companyName': 'PT MDM',
        'companyAddress': 'Jakarta',
        'companyLogo': 'logo.png',
        'period': '2026-10',
        'baseSalary': 15000000,
        'allowance': 2000000,
        'bonus': 1000000,
        'grossSalary': 18000000,
        'ptkp': 'TK/0',
        'taxCategory': 'A',
        'taxRateBps': 500,
        'pph21': 250000,
        'taxMode': 'auto',
        'taxNote': '',
        'taxReady': true,
        'lastTaxPeriod': false,
        'bpjsHealth': 150000,
        'jht': 300000,
        'jp': 150000,
        'finalizedAt': '2026-10-27T17:00:00+07:00',
        'finalizedBy': 'HR Admin',
        'overtime': 500000,
        'reimbursement': 150000,
        'deductions': 850000,
        'netSalary': 17150000,
        'status': 'Final',
        'version': 2,
        'revision': 1,
      };

      final model = PayrollModel.fromJson(payrollJson);
      expect(model.id, 'PAY-001');
      expect(model.netSalary, 17150000);
      expect(model.taxReady, isTrue);

      final map = model.toJson();
      expect(map['period'], '2026-10');
      expect(map['netSalary'], 17150000);
    });
  });
}
