"use client";
import { useEffect, useRef, useState } from "react";
import {
  Camera,
  MapPin,
  ScanFace,
  CheckCircle2,
  Loader2,
  RotateCcw,
  ShieldCheck,
} from "lucide-react";
import { Modal } from "./common";
import { Button } from "./ui/button";
import { post } from "@/lib/api";
import type { Workspace } from "@/lib/types";
export function AttendanceCamera({
  data,
  enrollID,
  onClose,
  onSaved,
}: {
  data: Workspace;
  enrollID?: string;
  onClose: () => void;
  onSaved: (message: string) => Promise<void>;
}) {
  const video = useRef<HTMLVideoElement>(null),
    stream = useRef<MediaStream | null>(null),
    alive = useRef(true);
  const [started, setStarted] = useState(false),
    [earlyReason, setEarlyReason] = useState(""),
    [photo, setPhoto] = useState(""),
    [error, setError] = useState(""),
    [busy, setBusy] = useState(false),
    [position, setPosition] = useState<GeolocationPosition | null>(null),
    [locating, setLocating] = useState(false);
  useEffect(() => {
    alive.current = true;
    return () => {
      alive.current = false;
      stream.current?.getTracks().forEach((t) => t.stop());
    };
  }, []);
  useEffect(() => {
    if (started && video.current && stream.current) {
      video.current.srcObject = stream.current;
      void video.current
        .play()
        .catch(() => setError("Kamera tidak dapat diputar"));
    }
  }, [started, photo]);
  async function startCamera() {
    setError("");
    try {
      const media = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: "user",
          width: { ideal: 640 },
          height: { ideal: 640 },
        },
        audio: false,
      });
      if (!alive.current) {
        media.getTracks().forEach((t) => t.stop());
        return;
      }
      stream.current = media;
      setStarted(true);
    } catch {
      setError(
        "Akses kamera diperlukan. Izinkan kamera melalui pengaturan browser dan gunakan HTTPS atau localhost.",
      );
    }
  }
  function capture() {
    const v = video.current;
    if (!v || v.readyState < 2) {
      setError("Tunggu kamera siap sebelum mengambil foto.");
      return;
    }
    const c = document.createElement("canvas");
    c.width = v.videoWidth;
    c.height = v.videoHeight;
    c.getContext("2d")?.drawImage(v, 0, 0);
    setPhoto(c.toDataURL("image/jpeg", 0.85));
  }
  function locate() {
    setError("");
    if (!navigator.geolocation) {
      setError("Perangkat tidak mendukung GPS.");
      return;
    }
    setLocating(true);
    navigator.geolocation.getCurrentPosition(
      (p) => {
        if (alive.current) {
          setPosition(p);
          setLocating(false);
        }
      },
      () => {
        if (alive.current) {
          setLocating(false);
          setError(
            "Lokasi gagal diambil. Aktifkan GPS, izinkan lokasi, dan coba di area terbuka.",
          );
        }
      },
      { enableHighAccuracy: true, timeout: 20000, maximumAge: 0 },
    );
  }
  async function submit(type: "in" | "out") {
    setBusy(true);
    setError("");
    try {
      if (!photo) throw new Error("Ambil foto wajah terlebih dahulu");
      if (enrollID) {
        await post(`/employees/${enrollID}/face`, { photo });
      } else {
        if (!position || Date.now() - position.timestamp > 60000)
          throw new Error("Perbarui lokasi GPS sebelum absensi");
        await post("/attendance/punch", {
          type,
          earlyReason,
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
          photo,
        });
      }
      await onSaved(
        enrollID
          ? "Wajah berhasil didaftarkan"
          : `Absensi ${type === "in" ? "masuk" : "pulang"} berhasil`,
      );
      onClose();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <Modal
      title={enrollID ? "Pendaftaran wajah karyawan" : "Absensi dengan wajah"}
      subtitle={
        enrollID
          ? "Admin memastikan identitas karyawan sebelum pendaftaran."
          : `${data.attendancePolicy?.name || "Lokasi belum ditentukan"} · ${data.attendancePolicy?.allowAnyLocation ? "Izin lokasi mana saja; GPS tetap dicatat" : `Radius ${data.attendancePolicy?.radius || 100} meter`}`
      }
      onClose={() => {
        if (!busy) onClose();
      }}
    >
      <div className="camera-content">
        {!data.faceAvailable && (
          <div className="notice amber">
            <ShieldCheck size={20} />
            <span>
              Layanan wajah belum terhubung. Admin perlu mengatur provider
              verifikasi dan liveness sebelum absensi dapat digunakan.
            </span>
          </div>
        )}
        <div className="camera-stage">
          {started && !photo && (
            <video ref={video} autoPlay muted playsInline />
          )}
          {photo && <img src={photo} alt="Foto wajah untuk verifikasi" />}
          {!started && (
            <div>
              <ScanFace size={66} />
              <h3>Posisikan wajah di tengah</h3>
              <p>Pastikan pencahayaan cukup dan wajah terlihat jelas.</p>
            </div>
          )}
          {started && <div className="face-guide" />}
        </div>
        <div className="camera-buttons">
          {!started ? (
            <Button onClick={startCamera}>
              <Camera size={17} /> Aktifkan kamera
            </Button>
          ) : photo ? (
            <Button variant="outline" onClick={() => setPhoto("")}>
              <RotateCcw size={16} /> Ambil ulang
            </Button>
          ) : (
            <Button onClick={capture}>
              <Camera size={17} /> Ambil foto
            </Button>
          )}
          {!enrollID && (
            <Button variant="outline" onClick={locate} disabled={locating}>
              {locating ? (
                <Loader2 size={16} className="spin" />
              ) : (
                <MapPin size={16} />
              )}{" "}
              {position ? "Perbarui lokasi" : "Ambil lokasi GPS"}
            </Button>
          )}
        </div>
        {position && (
          <div className="gps-status">
            <CheckCircle2 size={17} />
            <span>
              GPS diperoleh · Akurasi ±{Math.round(position.coords.accuracy)} m
              <br />
              <small>
                {position.coords.latitude.toFixed(6)},{" "}
                {position.coords.longitude.toFixed(6)}
              </small>
            </span>
          </div>
        )}
        {!enrollID && data.attendancePolicy?.workEnd && (
          <label className="field">
            <span>Alasan pulang lebih awal</span>
            <textarea
              value={earlyReason}
              onChange={(e) => setEarlyReason(e.target.value)}
              maxLength={500}
              rows={3}
              placeholder={`Wajib jika pulang sebelum ${data.attendancePolicy.workEnd}`}
            />
            <small>
              Alasan dicatat bersama absensi jika pulang sebelum jadwal. Isi
              minimal 5 karakter.
            </small>
          </label>
        )}
        <p className="form-note">
          Foto dikirim ke layanan verifikasi untuk pencocokan wajah dan
          pemeriksaan liveness.{" "}
          {enrollID
            ? "Pastikan karyawan memahami dan menyetujui penggunaan data biometriknya."
            : data.attendancePolicy?.allowAnyLocation
              ? "Izin absensi dari lokasi mana saja aktif. GPS aktual dan verifikasi wajah tetap wajib."
              : `Absensi hanya diterima bila lokasi beserta batas akurasinya berada dalam radius ${data.attendancePolicy?.radius || 100} m dari lokasi penugasan.`}
        </p>
        {error && (
          <div role="alert" className="error-message">
            {error}
          </div>
        )}
        <footer className="modal-footer">
          {enrollID ? (
            <Button
              disabled={busy || !photo || !data.faceAvailable}
              onClick={() => submit("in")}
            >
              {busy ? "Memproses…" : "Daftarkan wajah"}
            </Button>
          ) : (
            <>
              <Button
                variant="outline"
                disabled={busy || !photo || !position || !data.faceAvailable}
                onClick={() => submit("out")}
              >
                Absen pulang
              </Button>
              <Button
                disabled={busy || !photo || !position || !data.faceAvailable}
                onClick={() => submit("in")}
              >
                {busy ? "Memverifikasi…" : "Absen masuk"}
              </Button>
            </>
          )}
        </footer>
      </div>
    </Modal>
  );
}
