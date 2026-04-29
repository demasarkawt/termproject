import { MapContainer, TileLayer, Marker, useMap, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { useEffect } from 'react';

// Fix Leaflet's default icon URLs (Vite bundles assets differently).
// Using emerald-colored CDN icons keeps things consistent without bundling assets.
const defaultIcon = L.icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});
L.Marker.prototype.options.icon = defaultIcon;

interface MapPickerProps {
  value: { lat: number | null; lng: number | null };
  onChange: (next: { lat: number; lng: number }) => void;
  height?: number;
  // Default center used when value is null. Defaults to Erbil.
  fallbackCenter?: { lat: number; lng: number };
  zoom?: number;
}

function ClickHandler({ onPick }: { onPick: (lat: number, lng: number) => void }) {
  useMapEvents({
    click(e) {
      onPick(e.latlng.lat, e.latlng.lng);
    },
  });
  return null;
}

function Recenter({ lat, lng }: { lat: number; lng: number }) {
  const map = useMap();
  useEffect(() => {
    map.setView([lat, lng], map.getZoom(), { animate: true });
  }, [lat, lng, map]);
  return null;
}

export function MapPicker({
  value,
  onChange,
  height = 280,
  fallbackCenter = { lat: 36.1911, lng: 44.0092 },
  zoom = 8,
}: MapPickerProps) {
  const lat = value.lat ?? fallbackCenter.lat;
  const lng = value.lng ?? fallbackCenter.lng;
  const hasValue = value.lat != null && value.lng != null;

  return (
    <div className="overflow-hidden rounded-xl border border-slate-200">
      <MapContainer
        center={[lat, lng]}
        zoom={zoom}
        style={{ height, width: '100%' }}
        scrollWheelZoom={false}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        <ClickHandler onPick={(la, ln) => onChange({ lat: la, lng: ln })} />
        {hasValue && (
          <>
            <Marker
              position={[lat, lng]}
              draggable
              eventHandlers={{
                dragend: (e) => {
                  const m = e.target as L.Marker;
                  const p = m.getLatLng();
                  onChange({ lat: p.lat, lng: p.lng });
                },
              }}
            />
            <Recenter lat={lat} lng={lng} />
          </>
        )}
      </MapContainer>
      <div className="flex items-center justify-between gap-3 border-t border-slate-200 bg-slate-50/60 px-3 py-2 text-xs text-slate-600">
        <span>Click to place. Drag the marker to adjust.</span>
        <span className="font-mono">
          {hasValue ? `${lat.toFixed(5)}, ${lng.toFixed(5)}` : 'no location'}
        </span>
      </div>
    </div>
  );
}
