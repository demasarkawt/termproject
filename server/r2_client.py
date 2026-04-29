"""
Cloudflare R2 (S3-compatible) helper.

R2 endpoint format:
    https://<ACCOUNT_ID>.r2.cloudflarestorage.com

Required env vars:
    R2_ACCOUNT_ID
    R2_BUCKET_NAME
    R2_ACCESS_KEY_ID
    R2_SECRET_ACCESS_KEY

Optional:
    R2_PUBLIC_URL        Custom domain or r2.dev URL serving the bucket publicly.
                         If set, public_url() returns "<R2_PUBLIC_URL>/<key>".
                         If empty, callers should fall back to presigned URLs.
    R2_PRESIGN_EXPIRES   Lifetime (seconds) of presigned URLs. Default 3600.
"""

from __future__ import annotations

import os
import uuid
from typing import Optional

import boto3
from botocore.client import Config
from botocore.exceptions import BotoCoreError, ClientError


def _env(name: str, default: str = "") -> str:
    return (os.getenv(name) or default).strip()


R2_ACCOUNT_ID = _env("R2_ACCOUNT_ID")
R2_BUCKET_NAME = _env("R2_BUCKET_NAME")
R2_ACCESS_KEY_ID = _env("R2_ACCESS_KEY_ID")
R2_SECRET_ACCESS_KEY = _env("R2_SECRET_ACCESS_KEY")
R2_PUBLIC_URL = _env("R2_PUBLIC_URL").rstrip("/")
R2_PRESIGN_EXPIRES = int(_env("R2_PRESIGN_EXPIRES", "3600") or 3600)

R2_ENDPOINT = (
    f"https://{R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
    if R2_ACCOUNT_ID
    else ""
)


def is_configured() -> bool:
    """True when all credentials needed to talk to R2 are present."""
    return bool(
        R2_ACCOUNT_ID
        and R2_BUCKET_NAME
        and R2_ACCESS_KEY_ID
        and R2_SECRET_ACCESS_KEY
    )


_client = None


def get_client():
    """Lazy singleton boto3 S3 client pointed at R2."""
    global _client
    if _client is not None:
        return _client
    if not is_configured():
        raise RuntimeError(
            "R2 is not configured. Set R2_ACCOUNT_ID, R2_BUCKET_NAME, "
            "R2_ACCESS_KEY_ID and R2_SECRET_ACCESS_KEY in the environment."
        )
    _client = boto3.client(
        "s3",
        endpoint_url=R2_ENDPOINT,
        aws_access_key_id=R2_ACCESS_KEY_ID,
        aws_secret_access_key=R2_SECRET_ACCESS_KEY,
        # R2 expects SigV4 with the "auto" region.
        region_name="auto",
        config=Config(signature_version="s3v4"),
    )
    return _client


def build_key(filename: str, folder: Optional[str] = None) -> str:
    """Generate a unique object key while preserving the file extension."""
    safe_name = (filename or "file").replace("\\", "/").split("/")[-1]
    ext = ""
    if "." in safe_name:
        ext = "." + safe_name.rsplit(".", 1)[-1].lower()
    unique = uuid.uuid4().hex
    if folder:
        folder = folder.strip("/").replace("\\", "/")
        return f"{folder}/{unique}{ext}"
    return f"{unique}{ext}"


def upload_fileobj(
    fileobj,
    key: str,
    content_type: Optional[str] = None,
) -> str:
    """Upload a file-like object to R2 under the given key. Returns the key."""
    client = get_client()
    extra = {}
    if content_type:
        extra["ContentType"] = content_type
    try:
        client.upload_fileobj(
            Fileobj=fileobj,
            Bucket=R2_BUCKET_NAME,
            Key=key,
            ExtraArgs=extra or None,
        )
    except (BotoCoreError, ClientError) as exc:
        raise RuntimeError(f"R2 upload failed: {exc}") from exc
    return key


def delete_object(key: str) -> None:
    """Best-effort delete; raises RuntimeError on transport failure."""
    if not key:
        return
    client = get_client()
    try:
        client.delete_object(Bucket=R2_BUCKET_NAME, Key=key)
    except (BotoCoreError, ClientError) as exc:
        raise RuntimeError(f"R2 delete failed: {exc}") from exc


def public_url(key: str) -> Optional[str]:
    """Return a public URL if R2_PUBLIC_URL is configured, else None."""
    if not R2_PUBLIC_URL or not key:
        return None
    return f"{R2_PUBLIC_URL}/{key.lstrip('/')}"


def presigned_get_url(key: str, expires: Optional[int] = None) -> str:
    """Presigned GET URL valid for `expires` seconds (default R2_PRESIGN_EXPIRES)."""
    client = get_client()
    try:
        return client.generate_presigned_url(
            "get_object",
            Params={"Bucket": R2_BUCKET_NAME, "Key": key},
            ExpiresIn=expires or R2_PRESIGN_EXPIRES,
        )
    except (BotoCoreError, ClientError) as exc:
        raise RuntimeError(f"R2 presign failed: {exc}") from exc


def url_for(key: str) -> str:
    """Public URL when configured, otherwise a presigned URL."""
    return public_url(key) or presigned_get_url(key)
