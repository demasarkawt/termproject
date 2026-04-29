from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

import models
import schemas
from auth import require_admin
from database import get_db

router = APIRouter(prefix="/api/settings", tags=["Settings"])


def _get_or_create_settings(db: Session) -> models.SiteSettings:
    s = db.query(models.SiteSettings).first()
    if not s:
        s = models.SiteSettings(site_name="Kurdistan Go")
        db.add(s)
        db.commit()
        db.refresh(s)
    return s


@router.get("/site", response_model=schemas.SiteSettingsOut)
def get_site_settings(db: Session = Depends(get_db)):
    return _get_or_create_settings(db)


@router.patch(
    "/site",
    response_model=schemas.SiteSettingsOut,
    dependencies=[Depends(require_admin)],
)
def update_site_settings(
    data: schemas.SiteSettingsUpdate,
    db: Session = Depends(get_db),
):
    settings = _get_or_create_settings(db)
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(settings, k, v)
    db.commit()
    db.refresh(settings)
    return settings
