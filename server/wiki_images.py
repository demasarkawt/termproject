"""Best-effort Wikipedia thumbnail fetcher.

Used by `seed.py` to populate cover images for places and cities the
first time the database is seeded. If anything fails the caller logs
and continues — the bundled Flutter assets are the runtime fallback.
"""

from __future__ import annotations

import io
import logging
from typing import Optional

import requests

logger = logging.getLogger(__name__)

REST_SUMMARY = "https://en.wikipedia.org/api/rest_v1/page/summary/{title}"
DEFAULT_HEADERS = {
    "User-Agent": "KurdistanGo/1.0 (https://kurdistango.app)",
    "Accept": "application/json",
}


def fetch_thumbnail(title: str, *, min_width: int = 600) -> Optional[tuple[bytes, str]]:
    """Look up a Wikipedia article and return its primary image bytes.

    Returns ``None`` when the page or thumbnail can't be resolved.
    """
    if not title:
        return None
    try:
        # Wikipedia uses underscores in URLs.
        url = REST_SUMMARY.format(title=title.replace(" ", "_"))
        resp = requests.get(url, headers=DEFAULT_HEADERS, timeout=8)
        if resp.status_code != 200:
            logger.info("wiki summary %s: HTTP %s", title, resp.status_code)
            return None
        payload = resp.json()
    except requests.RequestException as exc:
        logger.info("wiki summary %s failed: %s", title, exc)
        return None

    # Prefer original image, fall back to thumbnail.
    candidates = []
    if isinstance(payload.get("originalimage"), dict):
        candidates.append(payload["originalimage"].get("source"))
    if isinstance(payload.get("thumbnail"), dict):
        candidates.append(payload["thumbnail"].get("source"))
    image_url = next((c for c in candidates if c), None)
    if not image_url:
        return None

    try:
        # Bump width if possible — Wikipedia uses /thumb/.../<width>px-...
        if "/thumb/" in image_url:
            parts = image_url.rsplit("/", 1)
            tail = parts[1]
            if "px-" in tail:
                tail = tail.split("px-", 1)[1]
                image_url = f"{parts[0]}/{max(min_width, 800)}px-{tail}"

        img_resp = requests.get(image_url, headers=DEFAULT_HEADERS, timeout=12)
        if img_resp.status_code != 200:
            logger.info("wiki image %s: HTTP %s", image_url, img_resp.status_code)
            return None
        content_type = img_resp.headers.get("Content-Type", "image/jpeg").split(";")[0]
        return img_resp.content, content_type
    except requests.RequestException as exc:
        logger.info("wiki image fetch %s failed: %s", image_url, exc)
        return None


def upload_to_r2(
    title: str,
    *,
    folder: str,
    filename_hint: str = "cover.jpg",
) -> Optional[tuple[str, str, int, str]]:
    """Fetch the article image and upload it to Cloudflare R2.

    Returns ``(public_url, r2_key, size_bytes, content_type)`` on success.
    """
    import r2_client  # local import so this module is import-safe without R2

    if not r2_client.is_configured():
        return None

    fetched = fetch_thumbnail(title)
    if fetched is None:
        return None
    data, content_type = fetched
    ext = ".jpg"
    ct = (content_type or "").lower()
    if "png" in ct:
        ext = ".png"
    elif "webp" in ct:
        ext = ".webp"
    safe_hint = filename_hint or "cover"
    if "." in safe_hint:
        safe_hint = safe_hint.rsplit(".", 1)[0]
    key = r2_client.build_key(f"{safe_hint}{ext}", folder=folder)

    try:
        r2_client.upload_fileobj(io.BytesIO(data), key, content_type=content_type)
    except RuntimeError as exc:
        logger.warning("R2 upload for %s failed: %s", title, exc)
        return None

    return r2_client.url_for(key), key, len(data), content_type
