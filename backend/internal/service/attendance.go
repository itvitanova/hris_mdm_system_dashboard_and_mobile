package service

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"hrismdm/backend/internal/domain"
	"image"
	_ "image/jpeg"
	_ "image/png"
	"math"
	"net/http"
	"strings"
	"time"
)

// FaceProvider must perform identity matching AND liveness. Never accept a client-provided match flag.
type FaceProvider interface {
	Enroll(context.Context, string, string) error
	Verify(context.Context, string, string) error
	Available() bool
}
type HTTPFaceProvider struct {
	URL, Key string
	Client   *http.Client
}

func (f *HTTPFaceProvider) Available() bool { return f.URL != "" && f.Key != "" }
func (f *HTTPFaceProvider) call(ctx context.Context, action, id, photo string) error {
	return f.callReference(ctx, action, id, photo, "")
}
func (f *HTTPFaceProvider) callReference(ctx context.Context, action, id, photo, reference string) error {
	if !f.Available() {
		return errors.New("layanan verifikasi wajah belum dikonfigurasi; hubungi admin")
	}
	body, _ := json.Marshal(map[string]string{"employeeId": id, "image": photo, "referenceImage": reference})
	req, err := http.NewRequestWithContext(ctx, "POST", strings.TrimRight(f.URL, "/")+"/"+action, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+f.Key)
	req.Header.Set("Content-Type", "application/json")
	res, err := f.Client.Do(req)
	if err != nil {
		return errors.New("layanan wajah tidak dapat dihubungi")
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return errors.New("verifikasi wajah ditolak layanan")
	}
	var result struct {
		Success bool `json:"success"`
		Matched bool `json:"matched"`
		Live    bool `json:"live"`
	}
	if json.NewDecoder(res.Body).Decode(&result) != nil || !result.Success || (action == "verify" && (!result.Matched || !result.Live)) {
		return errors.New("identitas atau liveness wajah tidak terverifikasi")
	}
	return nil
}
func (f *HTTPFaceProvider) Enroll(ctx context.Context, id, photo string) error {
	return f.call(ctx, "enroll", id, photo)
}
func (f *HTTPFaceProvider) Verify(ctx context.Context, id, photo string) error {
	return f.call(ctx, "verify", id, photo)
}
func (f *HTTPFaceProvider) VerifyReference(ctx context.Context, id, photo, reference string) error {
	return f.callReference(ctx, "verify", id, photo, reference)
}

// Kept outside Employee so workspace responses never contain biometric images.
type FaceReference struct {
	EmployeeID string `json:"employeeId"`
	Photo      string `json:"photo"`
	EnrolledAt string `json:"enrolledAt"`
}

func (a *App) FaceReference(ctx context.Context, actor domain.Actor, id string) (FaceReference, error) {
	if actor.Role != "admin" && actor.EmployeeID != id {
		return FaceReference{}, ErrForbidden
	}
	var ref FaceReference
	err := a.Store.Get(ctx, "face_references", id, &ref)
	return ref, err
}
func validatePhoto(photo string) error {
	parts := strings.SplitN(photo, ",", 2)
	if len(parts) != 2 || (parts[0] != "data:image/jpeg;base64" && parts[0] != "data:image/png;base64") {
		return errors.New("foto JPEG atau PNG wajib diambil")
	}
	b, err := base64.StdEncoding.DecodeString(parts[1])
	if err != nil || len(b) > 3*1024*1024 {
		return errors.New("foto tidak valid atau melebihi 3 MB")
	}
	cfg, _, err := image.DecodeConfig(bytes.NewReader(b))
	if err != nil || cfg.Width < 160 || cfg.Height < 160 || cfg.Width > 4096 || cfg.Height > 4096 {
		return errors.New("dimensi foto tidak valid (160–4096 piksel)")
	}
	return nil
}
func DistanceMeters(lat1, lon1, lat2, lon2 float64) float64 {
	r := math.Pi / 180
	dlat := (lat2 - lat1) * r
	dlon := (lon2 - lon1) * r
	a := math.Sin(dlat/2)*math.Sin(dlat/2) + math.Cos(lat1*r)*math.Cos(lat2*r)*math.Sin(dlon/2)*math.Sin(dlon/2)
	a = math.Max(0, math.Min(1, a))
	return 6371000 * 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
}
func (a *App) Enroll(ctx context.Context, actor domain.Actor, id, photo string) error {
	if actor.Role != "admin" && (actor.EmployeeID == "" || actor.EmployeeID != id) {
		return ErrForbidden
	}
	if err := validatePhoto(photo); err != nil {
		return err
	}
	var emp domain.Employee
	if err := a.Store.Get(ctx, "employees", id, &emp); err != nil {
		return errors.New("karyawan tidak ditemukan")
	}
	return a.write(ctx, func(s domain.Store) error {
		if err := s.Get(ctx, "employees", id, &emp); err != nil {
			return err
		}
		if emp.FaceEnrolled && actor.Role != "admin" {
			return errors.New("wajah sudah terdaftar; hubungi admin untuk mengganti referensi")
		}
		// Serialize registration with the reference write, including across API instances.
		if err := a.Face.Enroll(ctx, id, photo); err != nil {
			return err
		}
		if err := s.Put(ctx, "face_references", id, FaceReference{EmployeeID: id, Photo: photo, EnrolledAt: now()}); err != nil {
			return err
		}
		emp.FaceEnrolled = true
		if err := s.Put(ctx, "employees", id, emp); err != nil {
			return err
		}
		return audit(ctx, s, actor, "face.enroll", id)
	})
}

type Punch struct {
	EarlyReason string  `json:"earlyReason"`
	Type        string  `json:"type"`
	Latitude    float64 `json:"latitude"`
	Longitude   float64 `json:"longitude"`
	Accuracy    float64 `json:"accuracy"`
	Photo       string  `json:"photo"`
}

func (a *App) Punch(ctx context.Context, actor domain.Actor, p Punch) error {
	if p.Type != "in" && p.Type != "out" {
		return errors.New("jenis absensi tidak valid")
	}
	if !validCoordinates(p.Latitude, p.Longitude) || math.IsNaN(p.Accuracy) || math.IsInf(p.Accuracy, 0) || p.Accuracy <= 0 || p.Accuracy > 50 {
		return errors.New("GPS tidak valid atau akurasi lebih dari 50 meter; coba di area terbuka")
	}
	if err := validatePhoto(p.Photo); err != nil {
		return err
	}
	policy, err := policyFor(ctx, a.Store, actor.EmployeeID)
	if err != nil {
		return err
	}
	if !policy.Active {
		return errors.New("lokasi penugasan nonaktif; hubungi admin")
	}
	distance := DistanceMeters(policy.Latitude, policy.Longitude, p.Latitude, p.Longitude)
	if !policy.AllowAnyLocation && distance+p.Accuracy > policy.Radius {
		return fmt.Errorf("lokasi belum aman dalam radius %.0f m (jarak %.0f m +/- %.0f m)", policy.Radius, distance, p.Accuracy)
	}
	var emp domain.Employee
	if err = a.Store.Get(ctx, "employees", actor.EmployeeID, &emp); err != nil {
		return err
	}
	if !emp.FaceEnrolled {
		return errors.New("daftarkan wajah Anda dari HP terlebih dahulu")
	}
	if provider, ok := a.Face.(interface {
		VerifyReference(context.Context, string, string, string) error
	}); ok {
		ref, refErr := a.FaceReference(ctx, actor, actor.EmployeeID)
		if refErr != nil {
			return errors.New("referensi wajah belum tersedia; hubungi admin untuk pendaftaran ulang")
		}
		err = provider.VerifyReference(ctx, actor.EmployeeID, p.Photo, ref.Photo)
	} else {
		err = a.Face.Verify(ctx, actor.EmployeeID, p.Photo)
	}
	if err != nil {
		return err
	}
	return a.write(ctx, func(s domain.Store) error {
		// Read policy again under the write lock: admin changes during face verification apply.
		policy, err := policyFor(ctx, s, actor.EmployeeID)
		if err != nil {
			return err
		}
		if !policy.Active {
			return errors.New("lokasi penugasan nonaktif; hubungi admin")
		}
		distance := DistanceMeters(policy.Latitude, policy.Longitude, p.Latitude, p.Longitude)
		if !policy.AllowAnyLocation && distance+p.Accuracy > policy.Radius {
			return errors.New("lokasi di luar radius penugasan")
		}
		loc, err := time.LoadLocation(policy.Timezone)
		if err != nil {
			return err
		}
		t := time.Now().In(loc)
		date := t.Format("2006-01-02")
		id := date + "-" + actor.EmployeeID
		snapshot := &domain.AttendanceLocation{Latitude: p.Latitude, Longitude: p.Longitude, Accuracy: p.Accuracy, Distance: distance, Policy: policy}
		var records []domain.Attendance
		if err := s.List(ctx, "attendance", &records); err != nil {
			return err
		}
		var row domain.Attendance
		for _, v := range records {
			if v.ID == id {
				row = v
			}
		}
		if p.Type == "in" {
			if row.CheckIn != "" {
				return errors.New("sudah absen masuk hari ini")
			}
			status := "Hadir"
			if t.Format("15:04") > policy.WorkStart {
				status = "Terlambat"
			}
			row = domain.Attendance{ID: id, EmployeeID: actor.EmployeeID, EmployeeName: emp.Name, Date: date, CheckIn: t.Format(time.RFC3339), Status: status, Latitude: p.Latitude, Longitude: p.Longitude, Accuracy: p.Accuracy, Distance: distance, FaceVerified: true, CheckInLocation: snapshot}
		} else {
			if row.CheckIn == "" {
				return errors.New("belum absen masuk hari ini")
			}
			if row.CheckOut != "" {
				return errors.New("sudah absen pulang hari ini")
			}
			if err := applyDeparture(&row, t, policy, p.EarlyReason); err != nil {
				return err
			}
			row.CheckOut = t.Format(time.RFC3339)
			row.CheckOutLocation = snapshot
		}
		if err := s.Put(ctx, "attendance", id, row); err != nil {
			return err
		}
		return audit(ctx, s, actor, "attendance."+p.Type, id)
	})
}

func applyDeparture(row *domain.Attendance, t time.Time, policy domain.AttendancePolicy, reason string) error {
	if policy.WorkEnd == "" {
		return nil
	}
	end, err := time.ParseInLocation("2006-01-02 15:04", row.Date+" "+policy.WorkEnd, t.Location())
	if err != nil {
		return errors.New("jadwal pulang tidak valid; hubungi admin")
	}
	row.ScheduledEnd = end.Format(time.RFC3339)
	if !t.Before(end) {
		return nil
	}
	reason = strings.TrimSpace(reason)
	if len([]rune(reason)) < 5 || len([]rune(reason)) > 500 {
		return errors.New("pulang sebelum jadwal: isi alasan 5–500 karakter")
	}
	row.EarlyDeparture = true
	row.EarlyMinutes = int(math.Ceil(end.Sub(t).Minutes()))
	row.EarlyReason = reason
	return nil
}
func (a *App) Attendance(ctx context.Context, actor domain.Actor) ([]domain.Attendance, error) {
	var all []domain.Attendance
	if err := a.Store.List(ctx, "attendance", &all); err != nil {
		return nil, err
	}
	out := []domain.Attendance{}
	for _, r := range all {
		if actor.Role == "admin" || r.EmployeeID == actor.EmployeeID {
			out = append(out, r)
		}
	}
	return out, nil
}
