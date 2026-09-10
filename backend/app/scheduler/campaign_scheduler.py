from datetime import datetime, date
from zoneinfo import ZoneInfo

from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models import Campaign, SocialPost, Notification
from app.routes.social_post import (
    _generate_caption,
    _create_social_image,
)


IST = ZoneInfo("Asia/Kolkata")


def parse_post_time(post_time: str):
    """Convert a stored campaign time into a Python time object."""
    if not post_time:
        return None

    post_time = post_time.strip()

    for fmt in ("%H:%M", "%I:%M %p", "%I:%M%p"):
        try:
            return datetime.strptime(post_time, fmt).time()
        except ValueError:
            continue

    return None


def get_day_number(campaign: Campaign, today: date) -> int:
    return (today - campaign.start_date).days + 1


def normalize_platform(platform: str) -> str:
    platform = platform.lower().strip()
    mapping = {
        "instagram": "instagram",
        "facebook": "facebook",
        "linkedin": "linkedin",
        "twitter": "twitter",
        "x": "twitter",
    }
    return mapping.get(platform, platform)


def process_campaigns():
    """
    At/after each campaign's scheduled IST time, automatically:
      1. Generate a fresh Gemini caption for each selected platform.
      2. Generate the poster using the same AI poster pipeline as the
         manual Social Media Generator (including Hugging Face/FLUX).
      3. Save the completed SocialPost.
      4. Create an in-app notification for the user.

    The unique (campaign, day, platform) check prevents duplicate posts
    if the scheduler runs more than once during the same minute.
    """

    db: Session = SessionLocal()

    try:
        now_ist = datetime.now(IST)
        today = now_ist.date()
        current_time = now_ist.time().replace(second=0, microsecond=0)

        campaigns = (
            db.query(Campaign)
            .filter(
                Campaign.start_date.isnot(None),
                Campaign.end_date.isnot(None),
                Campaign.post_time.isnot(None),
            )
            .all()
        )

        for campaign in campaigns:
            if today < campaign.start_date or today > campaign.end_date:
                continue

            scheduled_time = parse_post_time(campaign.post_time)
            if scheduled_time is None:
                print(
                    f"[Scheduler] Invalid post_time for campaign "
                    f"{campaign.campaign_id}: {campaign.post_time}"
                )
                continue

            scheduled_time = scheduled_time.replace(
                second=0,
                microsecond=0,
            )

            # Run once the scheduled time has arrived. If the backend was
            # restarted after the scheduled time, it will catch up.
            if current_time < scheduled_time:
                continue

            day_number = get_day_number(campaign, today)

            channels = campaign.channels or []
            if isinstance(channels, str):
                channels = [channels]

            for channel in channels:
                platform = normalize_platform(channel)

                existing_post = (
                    db.query(SocialPost)
                    .filter(
                        SocialPost.campaign_id == campaign.campaign_id,
                        SocialPost.day_number == day_number,
                        SocialPost.platform == platform,
                    )
                    .first()
                )

                if existing_post:
                    continue

                try:
                    print(
                        f"[Scheduler] Generating {platform} post for "
                        f"campaign {campaign.campaign_id}, day {day_number}..."
                    )

                    content = _generate_caption(
                        campaign=campaign,
                        day_number=day_number,
                        platform=platform,
                    )

                    image_url = _create_social_image(
                        campaign=campaign,
                        day_number=day_number,
                        platform=platform,
                    )

                    scheduled_at = datetime.combine(
                        today,
                        scheduled_time,
                    )

                    post = SocialPost(
                        campaign_id=campaign.campaign_id,
                        day_number=day_number,
                        platform=platform,
                        content=content,
                        image_url=image_url,
                        status="Generated",
                        scheduled_at=scheduled_at,
                    )

                    db.add(post)
                    db.flush()

                    notification = Notification(
                        scheduled_post_id=post.id,
                        title="Scheduled post is ready",
                        message=(
                            f"Your Day {day_number} {platform.title()} post "
                            f"for '{campaign.campaign_name}' has been "
                            f"generated successfully."
                        ),
                        notification_type="post_generated",
                        is_read=False,
                    )

                    db.add(notification)
                    db.commit()

                    print(
                        f"[Scheduler] ✓ Generated {platform} post "
                        f"and notification for campaign "
                        f"{campaign.campaign_id}, day {day_number}."
                    )

                except Exception as e:
                    # Do not create a SocialPost when generation fails.
                    # This allows the next scheduler cycle to retry.
                    db.rollback()

                    print(
                        f"[Scheduler] ✗ Failed to generate {platform} "
                        f"post for campaign {campaign.campaign_id}, "
                        f"day {day_number}: {e}"
                    )

    except Exception as e:
        db.rollback()
        print(f"[Scheduler] Campaign scheduler error: {e}")

    finally:
        db.close()


async def scheduler_loop():
    """Run the campaign scheduler continuously, checking once per minute."""

    print("Campaign scheduler started.")
    print("Timezone: Asia/Kolkata (IST)")
    print("Scheduled posts will be generated automatically at their campaign time.")

    while True:
        try:
            process_campaigns()
        except Exception as e:
            print(f"[Scheduler] Loop error: {e}")

        await __import__("asyncio").sleep(60)
