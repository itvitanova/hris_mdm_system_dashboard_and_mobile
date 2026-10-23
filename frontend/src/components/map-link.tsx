export function MapLink({
  latitude,
  longitude,
  label = "Buka Google Maps",
}: {
  latitude: number;
  longitude: number;
  label?: string;
}) {
  if (
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude) ||
    Math.abs(latitude) > 90 ||
    Math.abs(longitude) > 180
  )
    return null;
  return (
    <a
      href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${latitude},${longitude}`)}`}
      target="_blank"
      rel="noopener noreferrer"
      title={`${latitude}, ${longitude}`}
    >
      {label} ↗
    </a>
  );
}
