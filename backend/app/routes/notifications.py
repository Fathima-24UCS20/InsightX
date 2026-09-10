from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Notification

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("")
def get_notifications(
    db: Session = Depends(get_db),
):
    notifications = (
        db.query(Notification)
        .order_by(Notification.id.desc())
        .limit(50)
        .all()
    )

    return [
        {
            "id": n.id,
            "scheduled_post_id": n.scheduled_post_id,
            "title": n.title,
            "message": n.message,
            "notification_type": n.notification_type,
            "is_read": n.is_read,
            "created_at": n.created_at.isoformat() if n.created_at else None,
        }
        for n in notifications
    ]


@router.get("/unread")
def get_unread_notifications(
    db: Session = Depends(get_db),
):
    notifications = (
        db.query(Notification)
        .filter(Notification.is_read == False)
        .order_by(Notification.id.asc())
        .all()
    )

    return [
        {
            "id": n.id,
            "scheduled_post_id": n.scheduled_post_id,
            "title": n.title,
            "message": n.message,
            "notification_type": n.notification_type,
            "is_read": n.is_read,
            "created_at": n.created_at.isoformat() if n.created_at else None,
        }
        for n in notifications
    ]


@router.patch("/{notification_id}/read")
def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db),
):
    notification = (
        db.query(Notification)
        .filter(Notification.id == notification_id)
        .first()
    )

    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found.")

    notification.is_read = True
    db.commit()

    return {"id": notification.id, "is_read": True}
