import math
from PIL import Image, ImageDraw, ImageFilter


def create_icon():
    R = 4096
    OUT = 1024
    cx, cy = R // 2, R // 2

    # ──────────────────────────────────────────────────────
    # 1. 深蓝 → 电紫 丝滑渐变背景（bilinear resize 无色带）
    # ──────────────────────────────────────────────────────
    g = Image.new("RGB", (2, 2))
    g.putpixel((0, 0), (0,   85, 230))   # 左上：宝蓝
    g.putpixel((1, 0), (20,  55, 210))   # 右上
    g.putpixel((0, 1), (55,  20, 210))   # 左下
    g.putpixel((1, 1), (130,  0, 210))   # 右下：电光紫
    bg = g.resize((R, R), Image.Resampling.BILINEAR).convert("RGBA")

    # 左上柔和光源高光
    glow = Image.new("RGBA", (R, R), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [-R // 3, -R // 3, R * 3 // 4, R * 3 // 4],
        fill=(255, 255, 255, 38)
    )
    glow = glow.filter(ImageFilter.GaussianBlur(R // 6))
    bg = Image.alpha_composite(bg, glow)

    # ──────────────────────────────────────────────────────
    # 2. 白色手机主体（比例：宽 1760 高 3040 ≈ iPhone 9:19）
    # ──────────────────────────────────────────────────────
    pw, ph = 1760, 3040
    phone = Image.new("RGBA", (R, R), (0, 0, 0, 0))
    pd = ImageDraw.Draw(phone)

    # 外壳（纯白）
    pd.rounded_rectangle(
        [cx - pw // 2, cy - ph // 2, cx + pw // 2, cy + ph // 2],
        radius=248, fill=(255, 255, 255, 255)
    )

    # 屏幕（深夜蓝，形成高对比度层次）
    sm = 88
    pd.rounded_rectangle(
        [cx - pw // 2 + sm, cy - ph // 2 + sm + 80,
         cx + pw // 2 - sm, cy + ph // 2 - sm - 80],
        radius=180, fill=(8, 10, 45, 255)
    )

    # 灵动岛
    di_w, di_h = 300, 110
    di_y = cy - ph // 2 + sm + 130
    pd.rounded_rectangle(
        [cx - di_w // 2, di_y, cx + di_w // 2, di_y + di_h],
        radius=55, fill=(255, 255, 255, 255)
    )

    # ── 屏幕内容 ──
    img_ml = cx - pw // 2 + sm + 90
    img_mr = cx + pw // 2 - sm - 90

    # ① 大产品图卡（含半透明白边框）
    card_t = di_y + di_h + 80
    card_b = cy + 60
    pd.rounded_rectangle([img_ml, card_t, img_mr, card_b],
                         radius=110, fill=(255, 255, 255, 18))
    pd.rounded_rectangle([img_ml, card_t, img_mr, card_b],
                         radius=110, outline=(255, 255, 255, 88), width=18)

    # 卡片中央：极简手机线框（白色）
    ic_cx, ic_cy = cx, (card_t + card_b) // 2
    ic_w, ic_h = 300, 500
    pd.rounded_rectangle(
        [ic_cx - ic_w // 2, ic_cy - ic_h // 2,
         ic_cx + ic_w // 2, ic_cy + ic_h // 2],
        radius=55, outline=(255, 255, 255, 220), width=34
    )
    pd.ellipse(
        [ic_cx - 28, ic_cy - ic_h // 2 + 52,
         ic_cx + 28, ic_cy - ic_h // 2 + 108],
        fill=(255, 255, 255, 220)
    )

    # ② 文字占位线
    ty = card_b + 80
    pd.rounded_rectangle([img_ml, ty, cx + 200, ty + 72],
                         radius=36, fill=(255, 255, 255, 200))
    pd.rounded_rectangle([img_ml, ty + 120, cx - 30, ty + 184],
                         radius=30, fill=(255, 255, 255, 120))

    # ③ CTA 按钮（纯白）
    btn_h = 170
    btn_t = cy + ph // 2 - sm - 80 - btn_h
    pd.rounded_rectangle([img_ml, btn_t, img_mr, btn_t + btn_h],
                         radius=85, fill=(255, 255, 255, 255))

    # 侧边按键（增加真实感）
    bx = cx + pw // 2
    pd.rounded_rectangle([bx - 20, cy - 260, bx + 28, cy + 50],
                         radius=14, fill=(230, 230, 230, 255))

    # ── 整体旋转 -6°
    phone = phone.rotate(-6, resample=Image.Resampling.BICUBIC, center=(cx, cy))

    # ──────────────────────────────────────────────────────
    # 3. 柔和落地阴影（深蓝调，避免脏黑）
    # ──────────────────────────────────────────────────────
    shadow = Image.new("RGBA", (R, R), (0, 0, 0, 0))
    shadow.paste(
        Image.new("RGBA", (R, R), (0, 0, 80, 170)),
        mask=phone.split()[3]
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(155))
    sh_layer = Image.new("RGBA", (R, R), (0, 0, 0, 0))
    sh_layer.paste(shadow, (60, 140))

    bg = Image.alpha_composite(bg, sh_layer)
    bg = Image.alpha_composite(bg, phone)

    # ──────────────────────────────────────────────────────
    # 4. LANCZOS 超精密下采样 → 1024px JPG
    # ──────────────────────────────────────────────────────
    final = bg.convert("RGB").resize((OUT, OUT), Image.Resampling.LANCZOS)
    root = "/Users/andy/ios/zuping001/app_icon.jpg"
    assets = ("/Users/andy/ios/zuping001/zuping001/Assets.xcassets"
              "/AppIcon.appiconset/app_icon_1024.jpg")
    final.save(root,   "JPEG", quality=100, subsampling=0)
    final.save(assets, "JPEG", quality=100, subsampling=0)
    print("ICON_DONE")


if __name__ == "__main__":
    create_icon()
