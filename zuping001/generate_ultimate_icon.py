import os
import math
from PIL import Image, ImageDraw, ImageFilter, ImageColor

def create_gradient_radial(width, height, inner_color, outer_color):
    """
    创建一个平滑的径向渐变作为背景基底。
    """
    image = Image.new("RGBA", (width, height))
    pixels = image.load()
    cx, cy = width / 2.0, height / 2.0
    r_max = math.sqrt(cx**2 + cy**2)
    
    r1, g1, b1 = ImageColor.getrgb(inner_color)
    r2, g2, b2 = ImageColor.getrgb(outer_color)
    
    for y in range(height):
        for x in range(width):
            dx = x - cx
            dy = y - cy
            dist = math.sqrt(dx**2 + dy**2)
            ratio = min(dist / r_max, 1.0)
            
            # 使用非线性差值使渐变更有纵深感 (S-curve)
            smooth_ratio = 3 * (ratio ** 2) - 2 * (ratio ** 3)
            
            r = int(r1 + (r2 - r1) * smooth_ratio)
            g = int(g1 + (g2 - g1) * smooth_ratio)
            b = int(b1 + (b2 - b1) * smooth_ratio)
            pixels[x, y] = (r, g, b, 255)
            
    return image

def draw_feathered_ellipse(image, box, color, blur_radius):
    """
    在图层上绘制一个带柔和高斯模糊边缘的椭圆（用于自建投影和局部柔光）。
    """
    tmp = Image.new("RGBA", image.size, (0, 0, 0, 0))
    tmp_draw = ImageDraw.Draw(tmp)
    tmp_draw.ellipse(box, fill=color)
    if blur_radius > 0:
        tmp = tmp.filter(ImageFilter.GaussianBlur(blur_radius))
    return Image.alpha_composite(image, tmp)

def draw_concentric_tech_rings(draw, cx, cy, start_r, count, gap, base_color):
    """
    在背景上绘制极隐约、具有奢华腕表质感的精细同心圈。
    """
    r_val, g_val, b_val = ImageColor.getrgb(base_color)
    for i in range(count):
        r = start_r + i * gap
        # 线条往外越淡
        alpha = int(max(40 - i * 8, 8))
        color = (r_val, g_val, b_val, alpha)
        # 用空心圈画细线
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=color, width=2)

def draw_linear_gradient_polygon(draw, points, start_col, end_col, direction=(0, 1)):
    """
    在多边形内模拟渲染精致的线性渐变金属高光
    """
    # 获取多边形的 Bounding Box
    xs = [p[0] for points_list in points for p in (points_list if isinstance(points_list, list) else [points_list])]
    ys = [p[1] for points_list in points for p in (points_list if isinstance(points_list, list) else [points_list])]
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    
    # 转换为元组列表
    poly_pts = []
    for p in points:
        if isinstance(p, (list, tuple)):
            poly_pts.append((p[0], p[1]))
    
    # 采用遮罩方法精准绘制渐变填充多边形
    w, h = draw.im.size[0], draw.im.size[1]
    mask = Image.new("L", (w, h), 0)
    m_draw = ImageDraw.Draw(mask)
    m_draw.polygon(poly_pts, fill=255)
    
    # 计算渐变走向
    grad_img = Image.new("RGBA", (w, h))
    grad_pixels = grad_img.load()
    
    r1, g1, b1 = ImageColor.getrgb(start_col)
    r2, g2, b2 = ImageColor.getrgb(end_col)
    
    dx, dy = direction
    length = math.sqrt(dx**2 + dy**2)
    dx, dy = dx / length, dy / length
    
    # 投影轴长
    proj_min = min_x * dx + min_y * dy
    proj_max = max_x * dx + max_y * dy
    proj_range = max(proj_max - proj_min, 1.0)
    
    # 我们只在多边形局部的包围盒内计算像素提升性能
    for y in range(int(min_y), int(max_y) + 1):
        if y < 0 or y >= h: continue
        for x in range(int(min_x), int(max_x) + 1):
            if x < 0 or x >= w: continue
            if mask.getpixel((x, y)) == 0: continue
            
            proj = x * dx + y * dy
            ratio = (proj - proj_min) / proj_range
            ratio = max(0.0, min(1.0, ratio))
            
            r = int(r1 + (r2 - r1) * ratio)
            g = int(g1 + (g2 - g1) * ratio)
            b = int(b1 + (b2 - b1) * ratio)
            grad_pixels[x, y] = (r, g, b, 255)
            
    # 将多边形渐变叠加回主底盘
    return mask, grad_img

def main():
    print("🚀 [Masterpiece Icon] 正在初始化超采样(3072px)极品拟物玻璃图标生成引擎...")
    
    W, H = 3072, 3072
    cx, cy = W // 2, H // 2
    
    # 1. 产生深邃的暗夜蓝黑色径向壁纸画布
    # 核心亮部: #191B24(幽暗质感蓝灰) 边缘暗部: #06070B(绝对高贵的邃黑)
    img = create_gradient_radial(W, H, "#181A22", "#06070B")
    draw = ImageDraw.Draw(img)
    
    # 2. 绘制令人叹为观止的极隐发丝纹同心环
    draw_concentric_tech_rings(draw, cx, cy, start_r=650, count=8, gap=110, base_color="#4F5D73")
    
    # 3. 绘制玻璃盘背后的幽蓝漫反射柔和发光层 (Backlight Aura)
    # 这会产生极其高级的霓虹背光，将黑色背景与玻璃盘分离
    img = draw_feathered_ellipse(img, [cx - 950, cy - 950, cx + 950, cy + 950], (41, 121, 255, 60), 160)
    img = draw_feathered_ellipse(img, [cx - 850, cy - 850, cx + 850, cy + 850], (255, 61, 127, 25), 200) # 微弱玫红逆光
    
    # 4. 绘制玻璃圆盘阴影 (Glass Drop Shadow)
    # 玻璃盘悬浮在底背景上空，投射下深度模糊的阴影
    img = draw_feathered_ellipse(img, [cx - 860, cy - 760, cx + 860, cy + 1000], (0, 0, 0, 160), 100)
    
    # 5. 渲染 3D 浮动玻璃球主体
    # 我们制作两层极细腻的圆，用渐变掩码叠加出玻璃盘。
    # 用浅白+浅粉/浅蓝的高光，制造水凝玻璃的晶莹剔透感。
    glass_mask = Image.new("L", (W, H), 0)
    gm_draw = ImageDraw.Draw(glass_mask)
    gm_draw.ellipse([cx - 850, cy - 850, cx + 850, cy + 850], fill=255)
    
    glass_base = Image.new("RGBA", (W, H))
    gb_pixels = glass_base.load()
    
    # 玻璃盘内部的细微渐变（由左上轻薄柔蓝过渡到右下朦胧深邃蓝紫）
    for y in range(cy - 850, cy + 850):
        for x in range(cx - 850, cx + 850):
            dx = x - cx
            dy = y - cy
            dist = math.sqrt(dx**2 + dy**2)
            if dist <= 850:
                # 角度
                angle = math.atan2(dy, dx) # -pi to pi
                # 归一化的斜向投影位置 (左上到右下)
                proj = (dx + dy) / (2.0 * 850.0) # approx -0.7 to 0.7
                ratio = (proj + 0.707) / 1.414
                ratio = max(0.0, min(1.0, ratio))
                
                # 玻璃盘自带超高透光的轻盈颜色
                # 左上: 极为清亮的水晶白 (255, 255, 255, 120)
                # 右下: 柔和的高贵冰川蓝 (15, 25, 45, 180)
                r = int(240 * (1 - ratio) + 12 * ratio)
                g = int(250 * (1 - ratio) + 20 * ratio)
                b = int(255 * (1 - ratio) + 40 * ratio)
                a = int(60 * (1 - ratio) + 140 * ratio) # 右下较厚重
                
                # 再叠加上一层轻微的边缘折射
                rim_ratio = dist / 850.0
                if rim_ratio > 0.94:
                    # 极窄的外边缘折射高亮
                    edge_glow = (rim_ratio - 0.94) / 0.06
                    # 左上部边缘极致晶莹白
                    if angle < 0: # 偏上
                        # 弧度偏亮
                        r = int(r * (1 - edge_glow) + 255 * edge_glow)
                        g = int(g * (1 - edge_glow) + 255 * edge_glow)
                        b = int(b * (1 - edge_glow) + 255 * edge_glow)
                        a = int(a * (1 - edge_glow) + 220 * edge_glow)
                    else:
                        # 右下部分暖色极光折射
                        r = int(r * (1 - edge_glow) + 255 * edge_glow)
                        g = int(g * (1 - edge_glow) + 80 * edge_glow)
                        b = int(b * (1 - edge_glow) + 150 * edge_glow)
                        a = int(a * (1 - edge_glow) + 160 * edge_glow)
                        
                gb_pixels[x, y] = (r, g, b, a)
                
    # 结合蒙版把玻璃盘融进主底盘
    img.paste(glass_base, (0, 0), glass_mask)
    
    # 6. 给玻璃盘增加月牙球面反光 (Specular Crescents)
    # 在玻璃盘中上方，画一个斜置的高亮椭圆，赋予真实的弧形玻璃反光效果！
    crescent_mask = Image.new("L", (W, H), 0)
    cm_draw = ImageDraw.Draw(crescent_mask)
    # 画一个大椭圆
    cm_draw.ellipse([cx - 720, cy - 810, cx + 720, cy - 200], fill=160)
    # 用另一个扣剪掉下方，形成月牙
    cm_draw.ellipse([cx - 800, cy - 730, cx + 800, cy - 100], fill=0)
    # 模糊月牙边缘，使其柔和自然
    crescent_mask = crescent_mask.filter(ImageFilter.GaussianBlur(35))
    
    crescent_color = Image.new("RGBA", (W, H), (255, 255, 255, 140))
    img.paste(crescent_color, (0, 0), crescent_mask)

    # 7. 绘制极致 3D 立体交叠 "Z" 字母 (A Monumental Beveled 'Z')
    # "Z" 的设计将由三段精密缝合、带有高档拉丝金属着色的几何棱柱拼接构成，展现出无与伦比的现代艺术感。
    # 银色部分: 太空铂金 (Platinum Silver) 由白到深灰
    # 玫瑰金部分: 温润红铜金 (Imperial Amber / Rose Gold)
    # 每一块都带有精细的 Beveled 斜边棱面受光。
    
    # 坐标定义 (完美计算的几何边缘)
    # 1) Top Bar 顶部横板 (玫瑰金 / Amber Gold)
    # 由上边缘受光面与下侧厚度暗面组成，展现 3D 棱角。
    # 顶部横板的主要多边形:
    # A (880, 1020), B (2120, 1020), C (1940, 1220), D (880, 1220)
    # E 厚度面: D (880, 1220), C (1940, 1220), F (1840, 1280), G (880, 1280)
    
    # 2) Bottom Bar 底部横板 (玫瑰金 / Amber Gold, 呼应顶部)
    # H (1140, 1780), I (2200, 1780), J (2200, 1980), K (960, 1980)
    # L 厚度面: H (1140, 1780), I (2200, 1780), M (2120, 1720), N (1140, 1720)
    
    # 3) Diagonal Ribbon 中间斜拉钢带 (太空铂金 / 闪耀钛银)
    # 构成 Z 的脊梁，从右上角深深切入到左下角。带有极其奢华的高光金属拉丝纹。
    # O (1940, 1220), P (2120, 1220), Q (1140, 1780), R (960, 1780)
    # 中斜带有左背光侧厚度: S (960, 1780), O (1940, 1220), T (1860, 1220), U (880, 1780)
    
    z_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    z_draw = ImageDraw.Draw(z_layer)
    
    # 绘制中间斜钢带 (太空铂金 Silver Gradient)
    # 渐变朝向: 斜向 (1, -0.6)
    # 棱面 1: 主受光斜轨
    mid_poly = [(1940, 1220), (2120, 1020), (1220, 1780), (960, 1780)]
    mask, grad = draw_linear_gradient_polygon(z_draw, mid_poly, "#F0F3F7", "#7A8A9E", (-1, 1))
    z_layer.paste(grad, (0, 0), mask)
    
    # 棱面 2: 厚度背光面 (深钛银)
    mid_thick_poly = [(960, 1780), (1220, 1780), (1140, 1850), (880, 1850)]
    mask, grad = draw_linear_gradient_polygon(z_draw, mid_thick_poly, "#4B5666", "#1E2430", (0, 1))
    z_layer.paste(grad, (0, 0), mask)

    # 棱面 3: 右侧反光折角
    mid_refl_poly = [(1940, 1220), (2120, 1020), (2060, 1020), (1880, 1220)]
    mask, grad = draw_linear_gradient_polygon(z_draw, mid_refl_poly, "#FFFFFF", "#9AA89C", (1, 0))
    z_layer.paste(grad, (0, 0), mask)

    # 绘制顶部横轨板 (奢华香槟红铜/玫瑰金 Amber Gold)
    # 棱面 1: 顶面板
    top_poly = [(880, 1020), (2120, 1020), (1940, 1220), (880, 1220)]
    mask, grad = draw_linear_gradient_polygon(z_draw, top_poly, "#FFE3C4", "#C6823F", (1, 1))
    z_layer.paste(grad, (0, 0), mask)
    
    # 棱面 2: 下底沿厚度面
    top_thick_poly = [(880, 1220), (1940, 1220), (1850, 1290), (880, 1290)]
    mask, grad = draw_linear_gradient_polygon(z_draw, top_thick_poly, "#B06B29", "#452408", (0, 1))
    z_layer.paste(grad, (0, 0), mask)
    
    # 棱面 3: 左侧切斜角特种受光
    top_left_poly = [(880, 1020), (960, 1020), (880, 1220)]
    mask, grad = draw_linear_gradient_polygon(z_draw, top_left_poly, "#FFF2DC", "#D0944F", (-1, 0))
    z_layer.paste(grad, (0, 0), mask)

    # 绘制底部横轨板
    # 棱面 1: 底面板
    bottom_poly = [(1140, 1780), (2200, 1780), (2020, 1980), (960, 1980)]
    mask, grad = draw_linear_gradient_polygon(z_draw, bottom_poly, "#FCDFB6", "#BE7935", (1, 1))
    z_layer.paste(grad, (0, 0), mask)
    
    # 棱面 2: 上口斜边缘受光厚度 (反差感)
    bottom_thick_poly = [(1140, 1780), (2200, 1780), (2120, 1720), (1140, 1720)]
    mask, grad = draw_linear_gradient_polygon(z_draw, bottom_thick_poly, "#A55F20", "#3E1B00", (0, -1))
    z_layer.paste(grad, (0, 0), mask)
    
    # 8. 为整个 'Z' 字母添加立体沉降阴影 (Z Inner & Drop Shadow)
    # 使 'Z' 金属体在玻璃盘上投射出清晰坚挺的叠影
    z_shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    zs_draw = ImageDraw.Draw(z_shadow)
    # 把所有Z的多边形聚合填充黑色
    for poly in [top_poly, top_thick_poly, top_left_poly, mid_poly, mid_thick_poly, mid_refl_poly, bottom_poly, bottom_thick_poly]:
        zs_draw.polygon(poly, fill=(0, 0, 0, 160))
    
    # 对阴影进行深度模糊
    z_shadow_blurred = z_shadow.filter(ImageFilter.GaussianBlur(30))
    # 轻轻向右下偏置
    shadow_offset = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    shadow_offset.paste(z_shadow_blurred, (30, 45))
    
    # 复合：主背景 -> 玻璃盘 -> 金属Z的投影 -> 金属Z
    img = Image.alpha_composite(img, shadow_offset)
    img = Image.alpha_composite(img, z_layer)
    
    # 9. 引入极致反射璀璨光芒 (Glints & Stars)
    # 在 Z 的左上角和右上拐角，手工画制极具奢侈品珠宝质感的高光星芒十字！
    star_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(star_layer)
    
    def draw_star(sd, x, y, size, core_size):
        # 环形光斑
        for i in range(12):
            alpha = int(70 - i * 5)
            r = core_size + i * 6
            sd.ellipse([x - r, y - r, x + r, y + r], fill=(255, 255, 255, alpha))
        # 十字光芒
        sd.line([x - size, y, x + size, y], fill=(255, 255, 255, 220), width=4)
        sd.line([x, y - size, x, y + size], fill=(255, 255, 255, 220), width=4)
        # 中心耀眼核
        sd.ellipse([x - core_size, y - core_size, x + core_size, y + core_size], fill=(255, 255, 255, 255))
        
    draw_star(sd, 910, 1050, 150, 15)   # 顶部拐角耀眼亮星
    draw_star(sd, 2100, 1020, 110, 10)  # 右上斜切亮星
    draw_star(sd, 1150, 1780, 80, 8)    # 底部交锁微弱亮星
    
    # 将璀璨星芒微糊后叠入
    star_layer_blur = star_layer.filter(ImageFilter.GaussianBlur(3))
    img = Image.alpha_composite(img, star_layer_blur)

    # 10. 保存生成的主体无损备份图形
    master_path = "/Users/andy/ios/zuping001/app_icon_master_3072.png"
    img.save(master_path, "PNG")
    print(f"✅ [Masterpiece Icon] 3072px 无损大师底稿生成完美：{master_path}")
    
    # 11. 高质量 Lanczos 采样：缩放分发到各自项目
    # 目标路径 1: zuping001
    zuping_icon_dir = "/Users/andy/ios/zuping001/zuping001/Assets.xcassets/AppIcon.appiconset"
    zuping_dest_path = os.path.join(zuping_icon_dir, "app_icon_1024.jpg")
    
    # 目标路径 2: zuhao001
    zuhao_icon_dir = "/Users/andy/zuhao001/zuhao001/Assets.xcassets/AppIcon.appiconset"
    zuhao_dest_path = os.path.join(zuhao_icon_dir, "app_icon_1024.jpg")
    
    # 执行 Lanczos 下采样（转换为 RGB，去除 A 通道以获得完美的 JPEG 纯度）
    rgb_img = img.convert("RGB")
    final_icon = rgb_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    
    os.makedirs(zuping_icon_dir, exist_ok=True)
    os.makedirs(zuhao_icon_dir, exist_ok=True)
    
    final_icon.save(zuping_dest_path, "JPEG", quality=98)
    print(f"✨ [Deploy] 1024px 大师级 JPEG 图标已部署至 [zuping001] -> {zuping_dest_path}")
    
    final_icon.save(zuhao_dest_path, "JPEG", quality=98)
    print(f"✨ [Deploy] 1024px 大师级 JPEG 图标已部署至 [zuhao001] -> {zuhao_dest_path}")
    
    print("\n🎉 [SUCCESS] 大师级拟物苹果商店 App 级美学图标渲染及多通道部署完美顺利完成！")

if __name__ == "__main__":
    main()
