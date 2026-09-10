import os
import json
import uuid
import textwrap
import math
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from google import genai
from huggingface_hub import InferenceClient

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageOps

from app.database import get_db
from app.models import SocialPost, Campaign
from app.schemas.social_post import (
    SocialPostCreate,
    SocialPostResponse,
)


router = APIRouter(
    prefix="/social-posts",
    tags=["Social Posts"],
)


# =========================================================
# GENERATED IMAGE FOLDER
# =========================================================

GENERATED_POSTS_DIR = Path("generated_posts")
GENERATED_POSTS_DIR.mkdir(exist_ok=True)


# =========================================================
# DAY THEMES
# =========================================================

DAY_THEMES = {
    1: "Campaign Introduction",
    2: "Product Highlight",
    3: "Benefits & Value",
    4: "Special Offer",
    5: "Final Reminder",
}


# =========================================================
# GEMINI CLIENT
# =========================================================

def _get_gemini_client():

    api_key = os.environ.get("GEMINI_API_KEY")

    if not api_key:
        raise RuntimeError(
            "GEMINI_API_KEY not set"
        )

    return genai.Client(
        api_key=api_key
    )


# =========================================================
# HUGGING FACE IMAGE GENERATION
# =========================================================

HF_IMAGE_MODEL = os.environ.get(
    "HF_IMAGE_MODEL",
    "black-forest-labs/FLUX.1-schnell",
)

HF_PROVIDER = os.environ.get(
    "HF_PROVIDER",
    "auto",
)


def _get_hf_client():
    """
    Create the Hugging Face Inference Providers client.

    The token stays on the backend. It is never sent to Flutter.
    """

    token = os.environ.get("HF_TOKEN")

    if not token:
        raise RuntimeError(
            "HF_TOKEN not set. Add a Hugging Face User Access Token "
            "with Inference Providers permission to the backend .env file."
        )

    return InferenceClient(
        provider=HF_PROVIDER,
        api_key=token,
    )


def _generate_ai_visual(
    campaign: Campaign,
    design: dict,
    platform: str,
) -> Image.Image:
    """
    Generate a text-free marketing visual with Hugging Face.

    Gemini remains responsible for the copy/design specification.
    Hugging Face is responsible only for the visual artwork.
    """

    client = _get_hf_client()

    product_name = (
        campaign.product_label
        or "the featured product or service"
    )

    layout = design.get("layout", "product_right")

    if layout == "product_left":
        subject_position = "left side"
    elif layout == "centered":
        subject_position = "center"
    else:
        subject_position = "right side"

    prompt = f"""
Create a premium commercial advertising visual for:
{product_name}

Campaign style:
{design.get("theme_style", "modern premium advertising")}

Background direction:
{design.get("background_style", "clean premium studio background")}

Decorative direction:
{design.get("decoration", "subtle modern shapes and lighting")}

Color palette:
primary {design.get("primary_color", "#24163A")},
secondary {design.get("secondary_color", "#F5F3FF")},
accent {design.get("accent_color", "#FFB703")}

Composition:
- Square 1:1 social media advertisement.
- Main subject/product visually positioned toward the {subject_position}.
- Leave clean negative space where marketing copy can be placed.
- Strong visual hierarchy.
- Professional commercial advertising photography.
- High-quality lighting, depth, realistic materials and polished composition.
- Match the campaign style rather than using a generic template.

CRITICAL:
- This is the visual layer only.
- Do NOT render any text.
- Do NOT render letters, numbers, typography, captions, slogans or UI.
- Do NOT render logos, brand marks or watermarks.
- Do NOT put fake words on the product or background.
- Do not invent product specifications.
- Keep the subject visually recognizable when the product type is clear.
"""

    negative_prompt = """
text, words, letters, numbers, typography, slogan, caption,
logo, watermark, brand mark, UI, labels, poster text,
misspelled text, blurry image, low resolution, distorted object,
deformed product, duplicate product, cropped main subject
"""

    image = client.text_to_image(
        prompt=prompt,
        negative_prompt=negative_prompt,
        width=1024,
        height=1024,
        model=HF_IMAGE_MODEL,
    )

    if image.mode != "RGB":
        image = image.convert("RGB")

    return image


def _cover_resize(
    image: Image.Image,
    width: int,
    height: int,
) -> Image.Image:
    """Resize an image to cover the target rectangle without distortion."""

    return ImageOps.fit(
        image.convert("RGB"),
        (width, height),
        method=Image.Resampling.LANCZOS,
        centering=(0.5, 0.5),
    )


def _paste_ai_product_visual(
    canvas: Image.Image,
    ai_visual: Image.Image,
    box,
    accent_color: str,
):
    """
    Put a cropped AI visual inside the existing product card.
    This preserves the current poster layout while replacing the
    abstract initials placeholder with a real generated visual.
    """

    x1, y1, x2, y2 = box
    width = x2 - x1
    height = y2 - y1

    visual = _cover_resize(
        ai_visual,
        width - 16,
        height - 16,
    )

    mask = Image.new(
        "L",
        visual.size,
        0,
    )

    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        (0, 0, visual.width, visual.height),
        radius=38,
        fill=255,
    )

    canvas.paste(
        visual,
        (x1 + 8, y1 + 8),
        mask,
    )

    draw = ImageDraw.Draw(canvas)

    draw.rounded_rectangle(
        (x1, y1, x2, y2),
        radius=45,
        outline=accent_color,
        width=5,
    )


def _add_readability_overlay(
    image: Image.Image,
    primary_color: str,
):
    """
    Add a subtle left-to-right overlay so generated visuals do not
    compromise the readability of our exact marketing copy.
    """

    overlay = Image.new(
        "RGBA",
        image.size,
        (0, 0, 0, 0),
    )

    pixels = overlay.load()

    rgb = tuple(
        int(primary_color[i:i + 2], 16)
        for i in (1, 3, 5)
    )

    width, height = image.size

    for x in range(width):
        # Strongest behind the copy, transparent around the visual.
        ratio = min(max(x / 760.0, 0.0), 1.0)
        alpha = int(105 * (1.0 - ratio))

        if x > 760:
            alpha = 0

        for y in range(height):
            pixels[x, y] = (
                rgb[0],
                rgb[1],
                rgb[2],
                alpha,
            )

    image.alpha_composite(overlay)


# =========================================================
# GENERATE CAPTION USING GEMINI
# =========================================================

def _generate_caption(
    campaign: Campaign,
    day_number: int,
    platform: str,
) -> str:

    client = _get_gemini_client()

    theme = DAY_THEMES.get(
        day_number,
        "Engagement",
    )

    prompt = f"""
You are an expert social media marketing copywriter.

Create ONE unique social media caption.

CAMPAIGN:
- Campaign name: {campaign.campaign_name}
- Objective: {campaign.objective}
- Goal: {campaign.goal}
- Product / Service: {campaign.product_label}
- Target audience: {campaign.target_segment}
- Tone: {campaign.tone}
- Discount: {campaign.discount or "None"}
- Additional information: {campaign.additional_info or "None"}

POST:
- Day: {day_number}
- Theme: {theme}
- Platform: {platform}

REQUIREMENTS:
1. Make the caption unique for this day.
2. Make it appropriate for {platform}.
3. Match the theme "{theme}".
4. Match the tone "{campaign.tone}".
5. Mention the product naturally.
6. Include a clear marketing message.
7. Include a suitable call-to-action.
8. Include relevant hashtags.
9. Do not mention AI.
10. Return ONLY valid JSON.

Return exactly:

{{
    "content": "complete social media caption"
}}
"""

    response = client.models.generate_content(
        model="gemini-3.5-flash-lite",
        contents=prompt,
        config={
            "response_mime_type": "application/json"
        },
    )

    result = json.loads(response.text)

    content = result.get("content")

    if not content:
        raise RuntimeError(
            "Gemini returned empty caption."
        )

    return content


# =========================================================
# GENERATE VISUAL DESIGN SPECIFICATION
# =========================================================

def _generate_design_spec(
    campaign: Campaign,
    day_number: int,
    platform: str,
) -> dict:

    client = _get_gemini_client()

    theme = DAY_THEMES.get(
        day_number,
        "Engagement",
    )

    prompt = f"""
You are a professional social media graphic designer.

Create a visual design specification for ONE square
social media advertisement.

The final image will be rendered by a Python Pillow
renderer, so you are NOT generating the image itself.

CAMPAIGN:
- Campaign name: {campaign.campaign_name}
- Objective: {campaign.objective}
- Goal: {campaign.goal}
- Product / Service: {campaign.product_label}
- Target audience: {campaign.target_segment}
- Tone: {campaign.tone}
- Discount: {campaign.discount or "None"}
- Additional information: {campaign.additional_info or "None"}

POST:
- Day: {day_number}
- Theme: {theme}
- Platform: {platform}

DESIGN GOAL:
Create a polished marketing advertisement similar in quality
to a professional Instagram promotional poster.

IMPORTANT:
- The design must match the campaign.
- Do not always use the same style.
- Festive campaigns should look festive.
- Technology products can use premium modern styling.
- Fashion campaigns can use stylish editorial styling.
- Food campaigns can use energetic appetizing styling.
- Corporate campaigns should be clean and professional.
- Choose the visual direction based on the actual campaign.
- Do not invent factual product specifications.
- Only use product facts explicitly available in the campaign.
- Keep all text short enough to fit in a social media graphic.
- The main offer should have strong visual emphasis when a
  discount exists.
- The product name must remain accurate.

Return ONLY valid JSON.

Return exactly this structure:

{{
    "headline": "short main headline",
    "subheadline": "short supporting message",
    "offer_text": "offer text or empty string",
    "cta": "short CTA",
    "theme_style": "description of visual style",
    "background_style": "description of background",
    "layout": "one of: product_right, product_left, centered, split",
    "primary_color": "#hexcolor",
    "secondary_color": "#hexcolor",
    "accent_color": "#hexcolor",
    "text_color": "#hexcolor",
    "feature_points": [
        "short feature or benefit",
        "short feature or benefit",
        "short feature or benefit"
    ],
    "decoration": "short description of decorative elements",
    "badge_style": "one of: circle, seal, ribbon, rectangle, none"
}}

RULES:
- Use valid 6-digit HEX colors.
- Do not include markdown.
- Do not include explanations outside JSON.
"""

    response = client.models.generate_content(
        model="gemini-3.5-flash-lite",
        contents=prompt,
        config={
            "response_mime_type": "application/json"
        },
    )

    result = json.loads(response.text)

    if not isinstance(result, dict):
        raise RuntimeError(
            "Gemini returned invalid design specification."
        )

    return _sanitize_design_spec(
        result,
        campaign,
    )


# =========================================================
# DESIGN SPEC SANITIZATION
# =========================================================

def _valid_hex(value, fallback):

    if not isinstance(value, str):
        return fallback

    value = value.strip()

    if (
        len(value) == 7
        and value.startswith("#")
    ):
        try:
            int(value[1:], 16)
            return value
        except ValueError:
            pass

    return fallback


def _sanitize_design_spec(
    spec: dict,
    campaign: Campaign,
) -> dict:

    # Safe defaults
    defaults = {
        "headline": "DISCOVER SOMETHING BETTER",
        "subheadline": "Made for what matters.",
        "offer_text": "",
        "cta": "SHOP NOW",
        "theme_style": "modern premium",
        "background_style": "clean gradient",
        "layout": "split",
        "primary_color": "#24163A",
        "secondary_color": "#F5F3FF",
        "accent_color": "#FFB703",
        "text_color": "#24163A",
        "feature_points": [],
        "decoration": "",
        "badge_style": "circle",
    }

    cleaned = {}

    for key, default in defaults.items():

        value = spec.get(key)

        if value is None:
            cleaned[key] = default
        else:
            cleaned[key] = value

    # -----------------------------------------------------
    # Text safety
    # -----------------------------------------------------

    for key in [
        "headline",
        "subheadline",
        "offer_text",
        "cta",
        "theme_style",
        "background_style",
        "decoration",
    ]:

        if not isinstance(cleaned[key], str):
            cleaned[key] = defaults[key]

        cleaned[key] = cleaned[key].strip()

    # -----------------------------------------------------
    # Layout validation
    # -----------------------------------------------------

    valid_layouts = {
        "product_right",
        "product_left",
        "centered",
        "split",
    }

    if cleaned["layout"] not in valid_layouts:
        cleaned["layout"] = "split"

    # -----------------------------------------------------
    # Badge validation
    # -----------------------------------------------------

    valid_badges = {
        "circle",
        "seal",
        "ribbon",
        "rectangle",
        "none",
    }

    if cleaned["badge_style"] not in valid_badges:
        cleaned["badge_style"] = "circle"

    # -----------------------------------------------------
    # Colors
    # -----------------------------------------------------

    cleaned["primary_color"] = _valid_hex(
        cleaned["primary_color"],
        "#24163A",
    )

    cleaned["secondary_color"] = _valid_hex(
        cleaned["secondary_color"],
        "#F5F3FF",
    )

    cleaned["accent_color"] = _valid_hex(
        cleaned["accent_color"],
        "#FFB703",
    )

    cleaned["text_color"] = _valid_hex(
        cleaned["text_color"],
        "#24163A",
    )

    # -----------------------------------------------------
    # Features
    # -----------------------------------------------------

    if not isinstance(
        cleaned["feature_points"],
        list,
    ):
        cleaned["feature_points"] = []

    cleaned["feature_points"] = [
        str(item).strip()
        for item in cleaned["feature_points"]
        if str(item).strip()
    ][:4]

    # -----------------------------------------------------
    # Discount fallback
    # -----------------------------------------------------

    if (
        not cleaned["offer_text"]
        and campaign.discount
    ):
        cleaned["offer_text"] = (
            f"FLAT {campaign.discount}% OFF"
        )

    return cleaned


# =========================================================
# FONT HELPER
# =========================================================

def _get_font(
    size: int,
    bold: bool = False,
):

    font_paths = [
        (
            "/usr/share/fonts/truetype/dejavu/"
            "DejaVuSans-Bold.ttf"
            if bold
            else
            "/usr/share/fonts/truetype/dejavu/"
            "DejaVuSans.ttf"
        ),

        (
            "C:/Windows/Fonts/arialbd.ttf"
            if bold
            else
            "C:/Windows/Fonts/arial.ttf"
        ),
    ]

    for path in font_paths:

        if os.path.exists(path):

            return ImageFont.truetype(
                path,
                size,
            )

    return ImageFont.load_default()


# =========================================================
# TEXT WRAPPER
# =========================================================

def _draw_wrapped_text(
    draw,
    text,
    xy,
    font,
    fill,
    max_width,
    line_spacing=10,
):

    x, y = xy

    words = text.split()

    lines = []
    current = ""

    for word in words:

        test = (
            f"{current} {word}".strip()
        )

        bbox = draw.textbbox(
            (0, 0),
            test,
            font=font,
        )

        width = bbox[2] - bbox[0]

        if (
            width <= max_width
            or not current
        ):
            current = test

        else:
            lines.append(current)
            current = word

    if current:
        lines.append(current)

    for line in lines:

        draw.text(
            (x, y),
            line,
            font=font,
            fill=fill,
        )

        bbox = draw.textbbox(
            (0, 0),
            line,
            font=font,
        )

        line_height = (
            bbox[3] - bbox[1]
        )

        y += line_height + line_spacing

    return y


# =========================================================
# GRADIENT BACKGROUND
# =========================================================

def _create_gradient(
    width,
    height,
    color1,
    color2,
):

    img = Image.new(
        "RGB",
        (width, height),
    )

    pixels = img.load()

    c1 = tuple(
        int(color1[i:i + 2], 16)
        for i in (1, 3, 5)
    )

    c2 = tuple(
        int(color2[i:i + 2], 16)
        for i in (1, 3, 5)
    )

    for y in range(height):

        ratio = y / max(
            height - 1,
            1,
        )

        r = int(
            c1[0] * (1 - ratio)
            + c2[0] * ratio
        )

        g = int(
            c1[1] * (1 - ratio)
            + c2[1] * ratio
        )

        b = int(
            c1[2] * (1 - ratio)
            + c2[2] * ratio
        )

        for x in range(width):
            pixels[x, y] = (
                r,
                g,
                b,
            )

    return img


# =========================================================
# DECORATIVE CIRCLES
# =========================================================

def _draw_decorations(
    draw,
    width,
    height,
    primary,
    accent,
):

    # Large soft circles

    draw.ellipse(
        (
            width - 300,
            -100,
            width + 100,
            300,
        ),
        fill=accent,
    )

    draw.ellipse(
        (
            -120,
            height - 260,
            180,
            height + 40,
        ),
        fill=primary,
    )

    # Small decorative dots

    for i in range(12):

        angle = (
            i * math.pi / 6
        )

        cx = 80 + int(
            55 * math.cos(angle)
        )

        cy = 120 + int(
            55 * math.sin(angle)
        )

        draw.ellipse(
            (
                cx - 6,
                cy - 6,
                cx + 6,
                cy + 6,
            ),
            fill=accent,
        )


# =========================================================
# OFFER BADGE
# =========================================================

def _draw_offer_badge(
    image,
    draw,
    offer_text,
    badge_style,
    accent_color,
    primary_color,
):

    if not offer_text:
        return

    badge_x = 65
    badge_y = 690
    badge_w = 340
    badge_h = 180

    if badge_style in {
        "circle",
        "seal",
    }:

        draw.ellipse(
            (
                badge_x,
                badge_y,
                badge_x + badge_w,
                badge_y + badge_h,
            ),
            fill=primary_color,
            outline=accent_color,
            width=8,
        )

    elif badge_style == "ribbon":

        draw.polygon(
            [
                (badge_x, badge_y + 25),
                (badge_x + badge_w, badge_y + 25),
                (badge_x + badge_w - 35, badge_y + 155),
                (badge_x + 35, badge_y + 155),
            ],
            fill=primary_color,
        )

    else:

        draw.rounded_rectangle(
            (
                badge_x,
                badge_y,
                badge_x + badge_w,
                badge_y + badge_h,
            ),
            radius=30,
            fill=primary_color,
            outline=accent_color,
            width=6,
        )

    font = _get_font(
        42,
        bold=True,
    )

    bbox = draw.textbbox(
        (0, 0),
        offer_text,
        font=font,
    )

    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    draw.text(
        (
            badge_x
            + (badge_w - text_w) / 2,
            badge_y
            + (badge_h - text_h) / 2,
        ),
        offer_text,
        font=font,
        fill=accent_color,
    )


# =========================================================
# PRODUCT VISUAL PLACEHOLDER
# =========================================================

def _draw_product_visual(
    image,
    draw,
    product_name,
    x1,
    y1,
    x2,
    y2,
    primary_color,
    accent_color,
):

    # Soft visual card

    draw.rounded_rectangle(
        (
            x1,
            y1,
            x2,
            y2,
        ),
        radius=45,
        fill="#FFFFFF",
    )

    # Shadow-like border

    draw.rounded_rectangle(
        (
            x1 + 8,
            y1 + 8,
            x2 - 8,
            y2 - 8,
        ),
        radius=40,
        outline=accent_color,
        width=5,
    )

    # Decorative abstract product background

    draw.ellipse(
        (
            x1 + 45,
            y1 + 60,
            x2 - 80,
            y2 - 80,
        ),
        fill=primary_color,
    )

    draw.ellipse(
        (
            x1 + 130,
            y1 + 145,
            x2 - 40,
            y2 - 30,
        ),
        fill=accent_color,
    )

    # Product initials

    initials = "".join(
        word[0]
        for word in product_name.split()
        if word
    )[:3].upper()

    font = _get_font(
        90,
        bold=True,
    )

    bbox = draw.textbbox(
        (0, 0),
        initials,
        font=font,
    )

    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    center_x = (
        x1 + x2
    ) / 2

    center_y = (
        y1 + y2
    ) / 2

    draw.text(
        (
            center_x - text_w / 2,
            center_y - text_h / 2,
        ),
        initials,
        font=font,
        fill="#FFFFFF",
    )


# =========================================================
# FEATURE STRIP
# =========================================================

def _draw_features(
    draw,
    features,
    x,
    y,
    width,
    text_color,
    accent_color,
):

    if not features:
        return

    feature_font = _get_font(
        24,
        bold=True,
    )

    small_font = _get_font(
        20,
        bold=False,
    )

    current_x = x

    usable_width = width

    item_width = (
        usable_width
        / len(features)
    )

    for feature in features:

        feature_x = current_x

        draw.ellipse(
            (
                feature_x,
                y,
                feature_x + 30,
                y + 30,
            ),
            fill=accent_color,
        )

        short_feature = feature[:32]

        _draw_wrapped_text(
            draw,
            short_feature,
            (
                feature_x + 42,
                y - 2,
            ),
            feature_font,
            text_color,
            item_width - 45,
            line_spacing=4,
        )

        current_x += item_width


# =========================================================
# CREATE DYNAMIC SOCIAL MEDIA IMAGE
# =========================================================

def _create_social_image(
    campaign: Campaign,
    day_number: int,
    platform: str,
) -> str:
    """
    Create a complete social-media poster.

    Gemini generates the design specification.
    Hugging Face generates the optional product visual.
    Pillow renders the final poster and exact marketing copy.
    If Hugging Face is unavailable, the Pillow placeholder is used.
    """

    width = 1080
    height = 1080

    # -----------------------------------------------------
    # 1. Generate AI design specification
    # -----------------------------------------------------

    design = _generate_design_spec(
        campaign=campaign,
        day_number=day_number,
        platform=platform,
    )

    # -----------------------------------------------------
    # 2. Colors
    # -----------------------------------------------------

    primary = design["primary_color"]
    secondary = design["secondary_color"]
    accent = design["accent_color"]
    text_color = design["text_color"]

    # -----------------------------------------------------
    # 3. Base poster background
    # -----------------------------------------------------

    image = _create_gradient(
        width,
        height,
        secondary,
        "#FFFFFF",
    ).convert("RGBA")

    # -----------------------------------------------------
    # 4. Try generating the AI product visual
    # -----------------------------------------------------

    ai_visual = None

    try:
        ai_visual = _generate_ai_visual(
            campaign=campaign,
            design=design,
            platform=platform,
        )

    except Exception as e:
        print(
            "Hugging Face visual generation unavailable; "
            f"using fallback product renderer: {e}"
        )

    # -----------------------------------------------------
    # 5. Drawing context
    # -----------------------------------------------------

    draw = ImageDraw.Draw(image)

    # -----------------------------------------------------
    # 6. Decorations
    # -----------------------------------------------------

    _draw_decorations(
        draw,
        width,
        height,
        primary,
        accent,
    )

    # -----------------------------------------------------
    # 7. Campaign label
    # -----------------------------------------------------

    small_font = _get_font(
        25,
        bold=True,
    )

    campaign_name = (
        campaign.campaign_name
        or "INSIGHTX CAMPAIGN"
    )

    draw.text(
        (65, 55),
        campaign_name[:35].upper(),
        font=small_font,
        fill=primary,
    )

    # -----------------------------------------------------
    # 8. Headline
    # -----------------------------------------------------

    headline_font = _get_font(
        72,
        bold=True,
    )

    _draw_wrapped_text(
        draw,
        design["headline"],
        (65, 110),
        headline_font,
        text_color,
        580,
        line_spacing=8,
    )

    # -----------------------------------------------------
    # 9. Subheadline
    # -----------------------------------------------------

    subheadline_font = _get_font(
        30,
        bold=False,
    )

    _draw_wrapped_text(
        draw,
        design["subheadline"],
        (70, 300),
        subheadline_font,
        primary,
        500,
        line_spacing=8,
    )

    # -----------------------------------------------------
    # 10. Product name
    # -----------------------------------------------------

    product_name = (
        campaign.product_label
        or "Featured Product"
    )

    product_font = _get_font(
        40,
        bold=True,
    )

    _draw_wrapped_text(
        draw,
        product_name,
        (70, 405),
        product_font,
        text_color,
        470,
        line_spacing=5,
    )

    # -----------------------------------------------------
    # 11. Product visual area
    # -----------------------------------------------------

    layout = design["layout"]

    if layout == "product_left":
        visual_box = (
            60,
            500,
            545,
            865,
        )

    elif layout == "centered":
        visual_box = (
            280,
            470,
            800,
            850,
        )

    elif layout == "split":
        visual_box = (
            585,
            170,
            1015,
            690,
        )

    else:
        visual_box = (
            585,
            170,
            1015,
            690,
        )

    # -----------------------------------------------------
    # 12. Insert AI visual or fallback placeholder
    # -----------------------------------------------------

    if ai_visual is not None:
        _paste_ai_product_visual(
            image,
            ai_visual,
            visual_box,
            accent,
        )
    else:
        _draw_product_visual(
            image,
            draw,
            product_name,
            *visual_box,
            primary,
            accent,
        )

    # Re-create the drawing object after pasting the AI image.
    draw = ImageDraw.Draw(image)

    # -----------------------------------------------------
    # 13. Readability overlay for AI visual
    # -----------------------------------------------------

    if ai_visual is not None:
        _add_readability_overlay(
            image,
            primary,
        )
        draw = ImageDraw.Draw(image)

    # -----------------------------------------------------
    # 14. Offer badge
    # -----------------------------------------------------

    _draw_offer_badge(
        image,
        draw,
        design["offer_text"],
        design["badge_style"],
        accent,
        primary,
    )

    # -----------------------------------------------------
    # 15. Feature strip
    # -----------------------------------------------------

    _draw_features(
        draw,
        design["feature_points"],
        70,
        875,
        940,
        text_color,
        accent,
    )

    # -----------------------------------------------------
    # 16. CTA
    # -----------------------------------------------------

    cta_font = _get_font(
        30,
        bold=True,
    )

    cta_text = (
        design["cta"]
        or "LEARN MORE"
    )

    cta_x1 = 700
    cta_y1 = 720
    cta_x2 = 1010
    cta_y2 = 805

    draw.rounded_rectangle(
        (
            cta_x1,
            cta_y1,
            cta_x2,
            cta_y2,
        ),
        radius=30,
        fill=primary,
    )

    bbox = draw.textbbox(
        (0, 0),
        cta_text,
        font=cta_font,
    )

    cta_w = bbox[2] - bbox[0]
    cta_h = bbox[3] - bbox[1]

    draw.text(
        (
            cta_x1
            + (cta_x2 - cta_x1 - cta_w) / 2,
            cta_y1
            + (cta_y2 - cta_y1 - cta_h) / 2,
        ),
        cta_text,
        font=cta_font,
        fill="#FFFFFF",
    )

    # -----------------------------------------------------
    # 17. Platform
    # -----------------------------------------------------

    platform_font = _get_font(
        20,
        bold=True,
    )

    draw.text(
        (70, 1010),
        str(platform).upper(),
        font=platform_font,
        fill=primary,
    )

    draw.text(
        (830, 1010),
        "InsightX",
        font=platform_font,
        fill=primary,
    )

    # -----------------------------------------------------
    # 18. Save
    # -----------------------------------------------------

    filename = f"post_{uuid.uuid4().hex}.png"

    file_path = (
        GENERATED_POSTS_DIR
        / filename
    )

    image.save(
        file_path,
        "PNG",
        optimize=True,
    )

    return f"/generated-posts/{filename}"


# =========================================================
# FETCH SAVED SOCIAL POSTS
# =========================================================

@router.get(
    "/",
    response_model=list[SocialPostResponse],
)
def get_social_posts(
    campaign_id: int | None = Query(default=None),
    day_number: int | None = Query(default=None),
    platform: str | None = Query(default=None),
    db: Session = Depends(get_db),
):
    """
    Return saved social posts.

    Optional filters allow the Flutter Post Generator page to retrieve
    the exact scheduled/generated post for the selected campaign,
    day and platform.
    """

    query = db.query(SocialPost)

    if campaign_id is not None:
        query = query.filter(
            SocialPost.campaign_id == campaign_id
        )

    if day_number is not None:
        query = query.filter(
            SocialPost.day_number == day_number
        )

    if platform:
        query = query.filter(
            SocialPost.platform == platform
        )

    return (
        query
        .order_by(SocialPost.created_at.desc())
        .all()
    )


# =========================================================
# CREATE / GENERATE SOCIAL POST
# =========================================================

@router.post(
    "/",
    response_model=SocialPostResponse,
)
def create_social_post(
    data: SocialPostCreate,
    db: Session = Depends(get_db),
):

    # -----------------------------------------------------
    # 1. Find campaign
    # -----------------------------------------------------

    campaign = (
        db.query(Campaign)
        .filter(
            Campaign.campaign_id
            == data.campaign_id
        )
        .first()
    )

    if not campaign:

        raise HTTPException(
            status_code=404,
            detail="Campaign not found",
        )

    # -----------------------------------------------------
    # 2. Validate day
    # -----------------------------------------------------

    if data.day_number < 1:

        raise HTTPException(
            status_code=400,
            detail="Day number must be at least 1.",
        )

    # -----------------------------------------------------
    # 3. Validate platform
    # -----------------------------------------------------

    channels = campaign.channels or []

    if data.platform not in channels:

        raise HTTPException(
            status_code=400,
            detail=(
                f"Platform '{data.platform}' "
                "is not selected for this campaign."
            ),
        )

    # -----------------------------------------------------
    # 4. Generate caption + image
    # -----------------------------------------------------

    try:

        content = _generate_caption(
            campaign=campaign,
            day_number=data.day_number,
            platform=data.platform,
        )

        image_url = _create_social_image(
            campaign=campaign,
            day_number=data.day_number,
            platform=data.platform,
        )

    except Exception as e:

        print(
            f"Social post generation failed: {e}"
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Failed to generate social media post."
            ),
        )

    # -----------------------------------------------------
    # 5. Save
    # -----------------------------------------------------

    post = SocialPost(
        campaign_id=data.campaign_id,
        day_number=data.day_number,
        platform=data.platform,
        content=content,
        image_url=image_url,
        status="Generated",
    )

    db.add(post)
    db.commit()
    db.refresh(post)

    return post