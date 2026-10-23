package service

import (
	"bytes"
	"encoding/base64"
	"errors"
	"image"
	"strings"
)

func validateCompanyLogo(value string) error {
	if value == "" {
		return nil
	}
	parts := strings.SplitN(value, ",", 2)
	if len(parts) != 2 || (parts[0] != "data:image/png;base64" && parts[0] != "data:image/jpeg;base64") {
		return errors.New("logo harus berupa PNG/JPEG")
	}
	data, err := base64.StdEncoding.DecodeString(parts[1])
	if err != nil || len(data) > 300*1024 {
		return errors.New("logo maksimal 300 KB")
	}
	cfg, _, err := image.DecodeConfig(bytes.NewReader(data))
	if err != nil || cfg.Width < 1 || cfg.Height < 1 || cfg.Width > 4096 || cfg.Height > 4096 {
		return errors.New("gambar logo tidak valid")
	}
	return nil
}
