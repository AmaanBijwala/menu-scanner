"""
Builds the image kit for a client's new Instagram / Facebook accounts from their logo.

  python make_kit.py --name "Ribat Inn Dormitory" --logo ribat_logo.png
                     --tagline "Clean, safe & affordable stay in Mumbai"
                     --out "C:/Users/Lenovo/OneDrive/Desktop/Social-Kits/Ribat-Inn-Dormitory"
                     [--stand Ribat-Inn-Dormitory_011_Stand_4x6.png]

Writes: profile_1080.png, fb_cover_1640x624.png, post1_welcome_1080x1350.png,
        post2_scan_qr_1080x1350.png (only with --stand)
"""
import argparse, os
from PIL import Image, ImageDraw, ImageFont, ImageOps

FONTS = "C:/Windows/Fonts/"


def font(size, bold=True):
    for f in (["segoeuib.ttf", "seguisb.ttf"] if bold else ["segoeui.ttf"]):
        try:
            return ImageFont.truetype(FONTS + f, size)
        except OSError:
            pass
    return ImageFont.load_default()


def load_logo(path):
    im = ImageOps.exif_transpose(Image.open(path)).convert("RGBA")
    # Trim plain white/transparent margins so the logo fills the space it is given
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    flat = Image.alpha_composite(bg, im).convert("RGB")
    box = ImageOps.invert(flat).getbbox()
    return im.crop(box) if box else im


def accent_colour(logo):
    """Most common strong colour in the logo, used for backgrounds and headings."""
    small = logo.convert("RGB").resize((80, 80))
    best, best_n = (30, 30, 30), 0
    for n, (r, g, b) in small.getcolors(6400) or []:
        if max(r, g, b) - min(r, g, b) < 40 or max(r, g, b) > 245 or max(r, g, b) < 25:
            continue                                    # skip white / grey / near-black
        if n > best_n:
            best, best_n = (r, g, b), n
    return best


def edge_colour(logo):
    """Colour around the logo's border (white for clean logos, the card colour for photographed ones)."""
    rgb = Image.alpha_composite(Image.new("RGBA", logo.size, "white"), logo).convert("RGB")
    w, h = rgb.size
    pts = [(x, y) for x in (2, w // 2, w - 3) for y in (2, h - 3)] + [(2, h // 2), (w - 3, h // 2)]
    px = [rgb.getpixel(p) for p in pts]
    return tuple(sorted(c[i] for c in px)[len(px) // 2] for i in range(3))


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c)


def paste_fit(canvas, logo, box):
    """Paste logo scaled to fit inside box=(x, y, w, h), centred."""
    x, y, w, h = box
    lg = logo.copy()
    lg.thumbnail((w, h), Image.LANCZOS)
    canvas.paste(lg, (x + (w - lg.width) // 2, y + (h - lg.height) // 2), lg)


def gradient(size, top, bottom):
    w, h = size
    g = Image.new("RGB", (1, h))
    for yy in range(h):
        t = yy / max(1, h - 1)
        g.putpixel((0, yy), tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return g.resize(size)


def centred_text(d, cx, y, text, f, fill, max_w):
    words, lines, cur = text.split(), [], ""
    for wd in words:
        trial = (cur + " " + wd).strip()
        if d.textlength(trial, font=f) <= max_w or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = wd
    if cur:
        lines.append(cur)
    for ln in lines:
        d.text((cx - d.textlength(ln, font=f) / 2, y), ln, font=f, fill=fill)
        y += int(f.size * 1.25)
    return y


def profile(logo, bg, out):
    # Instagram/Facebook crop the picture to a circle: keep the logo inside the middle ~70%
    im = Image.new("RGB", (1080, 1080), bg)
    paste_fit(im, logo, (170, 170, 740, 740))
    im.save(os.path.join(out, "profile_1080.png"))


def cover(logo, name, tagline, acc, bg, out):
    W, H = 1640, 624
    im = gradient((W, H), shade(acc, 0.55), shade(acc, 0.25))
    d = ImageDraw.Draw(im)
    # Phones crop the sides of the cover, so everything sits in the central ~1100px
    card = Image.new("RGBA", (300, 300), (255, 255, 255, 0))
    ImageDraw.Draw(card).rounded_rectangle((0, 0, 299, 299), 40, fill=bg)
    paste_fit(card, logo, (25, 25, 250, 250))
    im.paste(card, (300, (H - 300) // 2), card)
    y = centred_text(d, 1000, 210, name, font(64), "white", 640)
    centred_text(d, 1000, y + 10, tagline, font(34, False), (235, 235, 235), 640)
    im.save(os.path.join(out, "fb_cover_1640x624.png"))


def post_welcome(logo, name, tagline, acc, bg, out):
    W, H = 1080, 1350
    im = gradient((W, H), shade(acc, 0.6), shade(acc, 0.22))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((240, 170, 840, 770), 60, fill=bg)
    paste_fit(im, logo, (290, 220, 500, 500))
    y = centred_text(d, W // 2, 840, "We're now on Instagram!", font(66), "white", 960)
    y = centred_text(d, W // 2, y + 20, name, font(46), (255, 236, 200), 960)
    centred_text(d, W // 2, y + 20, tagline, font(36, False), (235, 235, 235), 900)
    d.text((W // 2 - d.textlength("Follow for updates & offers", font=font(34)) / 2, 1230),
           "Follow for updates & offers", font=font(34), fill="white")
    im.save(os.path.join(out, "post1_welcome_1080x1350.png"))


def post_stand(stand, out):
    # The acrylic stand image (QR + logo) on a 4:5 canvas, ready to post as "scan & join"
    s = Image.open(stand).convert("RGB")
    im = Image.new("RGB", (1080, 1350), "white")
    s.thumbnail((1000, 1300), Image.LANCZOS)
    im.paste(s, ((1080 - s.width) // 2, (1350 - s.height) // 2))
    im.save(os.path.join(out, "post2_scan_qr_1080x1350.png"))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--name", required=True)
    ap.add_argument("--logo", required=True)
    ap.add_argument("--tagline", default="")
    ap.add_argument("--out", required=True)
    ap.add_argument("--stand")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    lg = load_logo(a.logo)
    acc, bg = accent_colour(lg), edge_colour(lg)
    profile(lg, bg, a.out)
    cover(lg, a.name, a.tagline, acc, bg, a.out)
    post_welcome(lg, a.name, a.tagline, acc, bg, a.out)
    if a.stand:
        post_stand(a.stand, a.out)
    print("accent", acc, "background", bg, "->", a.out)
