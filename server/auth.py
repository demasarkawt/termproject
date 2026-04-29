"""Admin authentication helpers."""
from __future__ import annotations

import os
from typing import Optional

from fastapi import Header, HTTPException, status


def require_admin(x_admin_key: Optional[str] = Header(default=None)) -> None:
    """
    FastAPI dependency that gates an endpoint behind the X-Admin-Key header.

    The expected key is read from the ADMIN_KEY environment variable. If
    ADMIN_KEY is unset or blank the dependency rejects every request, so the
    service stays safe-by-default in production.
    """
    expected = (os.environ.get("ADMIN_KEY") or "").strip()
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="ADMIN_KEY is not configured on the server.",
        )
    if not x_admin_key or x_admin_key.strip() != expected:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing X-Admin-Key.",
            headers={"WWW-Authenticate": "AdminKey"},
        )
