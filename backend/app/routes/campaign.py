from datetime import datetime, timezone
from fastapi import Depends
from sqlalchemy.orm import Session
import os
import json
from google import genai
from fastapi import Depends, HTTPException
from app.database import get_db
from app.models import Campaign, SocialPost, Notification
from fastapi import APIRouter

from app.schemas.campaigns import CampaignCreate
from zoneinfo import ZoneInfo

IST = ZoneInfo("Asia/Kolkata")

router = APIRouter(prefix="/campaigns", tags=["Campaigns"])

OBJECTIVE_COPY = {
    "brand_awareness": {
        "headline_verb": "Discover",
        "key_message": "Building recognition and trust with your audience.",
        "cta": "Learn More",
    },
    "product_launch": {
        "headline_verb": "Introducing",
        "key_message": "Announcing something new your audience won't want to miss.",
        "cta": "Get Started Today",
    },
    "seasonal_sale": {
        "headline_verb": "Don't Miss",
        "key_message": "A limited-time offer designed to drive urgency and conversions.",
        "cta": "Shop the Sale",
    },
    "re_engagement": {
        "headline_verb": "We Miss You —",
        "key_message": "Reminding past customers why they loved working with you.",
        "cta": "Come Back and Save",
    },
    "lead_nurture": {
        "headline_verb": "Still Thinking About",
        "key_message": "Guiding interested prospects gently toward a decision.",
        "cta": "See Why It's Worth It",
    },
}

TONE_ADJECTIVES = {
    "Professional": "reliable, results-driven",
    "Friendly": "warm, approachable",
    "Playful": "fun, energetic",
    "Bold": "confident, attention-grabbing",
    "Luxury": "elevated, premium",
}



def _generate_with_llm(data: dict) -> dict:
    """
    Calls Gemini to generate campaign copy. Raises on any failure
    (missing key, network, timeout, bad JSON) so the caller falls
    back to _build_content(data).
    """
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY not set")

    gemini_client = genai.Client(api_key=api_key)

    channels = data.get("channels") or []
    prompt = f"""You are a marketing copywriter. Generate campaign content.

Campaign brief:
- Objective: {data.get('objective')}
- Goal: {data.get('goal')}
- Product: {data.get('product_label')}
- Audience: {data.get('audience_description')}
- Tone: {data.get('tone')}
- Channels: {channels}
- Additional info: {data.get('additional_info') or 'none'}

Return JSON with exactly these keys: headline, summary, key_message,
call_to_action, email_subject, email_body, ad_copy, hashtags (array of
3 strings). Also include ONLY these per-platform keys for channels
present in the list above: facebook_post, instagram_caption,
linkedin_post, twitter_post."""

    response = gemini_client.models.generate_content(
    model="gemini-flash-latest", 
    contents=prompt,
    config={"response_mime_type": "application/json"},
)
    parsed = json.loads(response.text)  # raises if not valid JSON
    parsed["generated_at"] = datetime.now(timezone.utc).isoformat()
    return parsed

def _objective_copy(objective: str) -> dict:
    return OBJECTIVE_COPY.get(objective, OBJECTIVE_COPY["brand_awareness"])


def _build_content(data: dict) -> dict:
    objective = data.get("objective", "brand_awareness")
    product_label = data.get("product_label") or "your product"
    tone = data.get("tone", "Professional")
    audience_description = data.get("audience_description") or "your target audience"
    additional_info = data.get("additional_info")
    channels = data.get("channels") or ["facebook", "instagram", "linkedin", "twitter"]

    copy = _objective_copy(objective)
    adjectives = TONE_ADJECTIVES.get(tone, "compelling")

    headline = f"{copy['headline_verb']} {product_label}"
    summary = (
        f"A {tone.lower()} campaign for {product_label}, targeting "
        f"{audience_description} with a focus on {objective.replace('_', ' ')}."
    )
    key_message = copy["key_message"]
    call_to_action = copy["cta"]

    if additional_info:
        summary += f" {additional_info.strip().rstrip('.')}."

    email_subject = f"{copy['headline_verb']} {product_label}"
    email_body = (
        f"Hi there,\n\n{headline} — built to be {adjectives}. {key_message}\n\n"
        f"{call_to_action} and see what {product_label} can do for you.\n\n"
        f"Best,\nThe Team"
    )
    ad_copy = f"{headline}. {key_message} {call_to_action} now."

    social_posts = {
        "facebook_post": f"🚀 {headline}! {key_message} {call_to_action} →",
        "instagram_caption": f"✨ {headline} ✨\n{key_message}",
        "linkedin_post": f"{headline}: {key_message}",
        "twitter_post": f"{headline} — {call_to_action} #Marketing",
    }
    # Only include the platforms the user actually selected as channels.
    filtered_posts = {
        k: v
        for k, v in social_posts.items()
        if any(ch in k for ch in channels) or not channels
    }

    hashtags = [
        f"#{product_label.split()[0]}" if product_label else "#Marketing",
        f"#{objective.replace('_', '').title()}",
        "#Marketing",
    ]

    return {
        "headline": headline,
        "summary": summary,
        "key_message": key_message,
        "call_to_action": call_to_action,
        "email_subject": email_subject,
        "email_body": email_body,
        "ad_copy": ad_copy,
        "hashtags": hashtags,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        **filtered_posts,
    }


@router.post("/generate")
def generate_campaign(data: dict):
    """
    Tries Gemini first for richer, tone-aware copy. Falls back to the
    deterministic template builder if the API key is missing, the
    request fails, or the model doesn't return valid JSON — so the
    endpoint never hard-fails from the frontend's perspective.
    """
    try:
        return _generate_with_llm(data)
    except Exception as e:
        print(f"LLM generation failed, falling back to template: {e}")
        return _build_content(data)



@router.post("")
def save_campaign(
    data: CampaignCreate,
    db: Session = Depends(get_db),
):
    print("SAVE REQUEST:", data)
    campaign = Campaign(
    campaign_name=data.campaign_name,
    objective=data.objective,
    goal=data.goal,

    product_id=data.product_id,
    product_label=data.product_label,

    target_segment=data.target_segment,
    channels=data.channels,      # <-- ADD THIS

    tone=data.tone,
    post_time=data.post_time,
    additional_info=data.additional_info,

    budget=data.budget,
    discount=data.discount,

    start_date=data.start_date.date() if data.start_date else None,
    end_date=data.end_date.date() if data.end_date else None,

    generated_copy=data.generated_copy,

    status=data.status,

    revenue=data.revenue,
    change_pct=data.change_pct,
)

    db.add(campaign)
    db.commit()
    db.refresh(campaign)

    return {
        "campaign_id": campaign.campaign_id,
        "campaign_name": campaign.campaign_name,
        "objective": campaign.objective,
        "goal": campaign.goal,
        "product_id": campaign.product_id,
        "product_label": campaign.product_label,
        "target_segment": campaign.target_segment,
        "tone": campaign.tone,
        "post_time": campaign.post_time,
        "additional_info": campaign.additional_info,
        "budget": float(campaign.budget)
        if campaign.budget
        else None,
        "discount": campaign.discount,
        "start_date": campaign.start_date.isoformat()
        if campaign.start_date
        else None,
        "end_date": campaign.end_date.isoformat()
        if campaign.end_date
        else None,
        "generated_copy": campaign.generated_copy,
        "status": campaign.status,
        "channels": campaign.channels,
        "created_at": campaign.created_at.isoformat(),
    }


@router.get("")
def get_campaigns(
    db: Session = Depends(get_db),
):
    campaigns = db.query(Campaign).all()

    return [
        {
            "campaign_id": c.campaign_id,
            "campaign_name": c.campaign_name,
            "objective": c.objective,
            "goal": c.goal,
            "product_id": c.product_id,
            "product_label": c.product_label,
            "target_segment": c.target_segment,
            "tone": c.tone,
            "post_time": c.post_time,
            "additional_info": c.additional_info,
            "budget": float(c.budget)
            if c.budget
            else None,
            "discount": c.discount,
            "start_date": c.start_date.isoformat()
            if c.start_date
            else None,
            "end_date": c.end_date.isoformat()
            if c.end_date
            else None,
            "generated_copy": c.generated_copy,
            "status": c.status,
            "created_at": c.created_at.isoformat(),
            "channels": c.channels
        }
        for c in campaigns
    ]
@router.delete("/{campaign_id}")
def delete_campaign(
    campaign_id: int,
    db: Session = Depends(get_db),
):
    campaign = (
        db.query(Campaign)
        .filter(Campaign.campaign_id == campaign_id)
        .first()
    )

    if not campaign:
        raise HTTPException(
            status_code=404,
            detail="Campaign not found",
        )

    try:
        # 1. Find all social posts belonging to this campaign
        posts = (
            db.query(SocialPost)
            .filter(
                SocialPost.campaign_id == campaign_id
            )
            .all()
        )

        # 2. Delete notifications linked to those posts
        for post in posts:
            db.query(Notification).filter(
                Notification.scheduled_post_id == post.id
            ).delete(
                synchronize_session=False
            )

        # 3. Delete social posts
        db.query(SocialPost).filter(
            SocialPost.campaign_id == campaign_id
        ).delete(
            synchronize_session=False
        )

        # 4. Delete campaign
        db.delete(campaign)

        # 5. Commit everything together
        db.commit()

        return {
            "detail": "Campaign deleted successfully",
            "campaign_id": campaign_id,
        }

    except Exception as e:
        db.rollback()

        print(
            f"Failed to delete campaign "
            f"{campaign_id}: {e}"
        )

        raise HTTPException(
            status_code=500,
            detail="Failed to delete campaign and its related data.",
        )