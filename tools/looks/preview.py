"""
.cube を読み込んでテスト画像に当て、比較シートを作る（LUTが正しく書けているかの確認も兼ねる）。
粒子・周辺減光・日付は README の目安値で簡易的に再現している。
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
LUT_DIR = os.path.join(HERE, '..', '..', 'Resources', 'LUTs')
W, H = 768, 512
rng = np.random.default_rng(7)

def test_image():
    img = np.zeros((H, W, 3), np.float32)
    y = np.linspace(0, 1, 320)[:, None]
    # 空
    sky = (1 - y[:180] / 0.5625) * np.array([127, 182, 230]) + (y[:180] / 0.5625) * np.array([207, 230, 245])
    img[:180] = (np.array([127, 182, 230]) * (1 - np.linspace(0, 1, 180)[:, None]) + np.array([207, 230, 245]) * np.linspace(0, 1, 180)[:, None])[:, None, :] / 255
    # 草地
    t = np.linspace(0, 1, 140)[:, None]
    img[180:320] = (np.array([110, 150, 60]) * (1 - t) + np.array([55, 90, 35]) * t)[:, None, :] / 255
    yy, xx = np.mgrid[0:H, 0:W]
    # 白い壁
    img[60:200, 60:180] = np.array([235, 232, 225]) / 255
    img[60:200, 160:180] = np.array([200, 196, 188]) / 255
    # 赤いボール
    d = np.sqrt((xx - 260) ** 2 + (yy - 250) ** 2)
    m = d < 45
    shade = np.clip(1 - ((xx - 245) ** 2 + (yy - 235) ** 2) / (60 ** 2), 0.35, 1)[..., None]
    img[m] = (np.array([205, 40, 40]) / 255 * shade)[m]
    # 肌（顔のつもりの円）
    d = np.sqrt((xx - 520) ** 2 + (yy - 175) ** 2)
    m = d < 72
    shade = np.clip(1.1 - ((xx - 500) ** 2 + (yy - 155) ** 2) / (95 ** 2), 0.45, 1.05)[..., None]
    img[m] = np.clip(np.array([224, 172, 140]) / 255 * shade, 0, 1)[m]
    # 日陰
    img[200:320, 640:768] *= 0.35
    # カラーチェッカー（24色）
    patches = [
        (115, 82, 68), (194, 150, 130), (98, 122, 157), (87, 108, 67), (133, 128, 177), (103, 189, 170),
        (214, 126, 44), (80, 91, 166), (193, 90, 99), (94, 60, 108), (157, 188, 64), (224, 163, 46),
        (56, 61, 150), (70, 148, 73), (175, 54, 60), (231, 199, 31), (187, 86, 149), (8, 133, 161),
        (243, 243, 242), (200, 200, 200), (160, 160, 160), (122, 122, 121), (85, 85, 85), (52, 52, 52)]
    for i, c in enumerate(patches):
        r, k = divmod(i, 6)
        img[320 + r * 48: 320 + (r + 1) * 48, k * 128:(k + 1) * 128] = np.array(c) / 255
    return np.clip(img, 0, 1)

def read_cube(path):
    n = None; vals = []
    for line in open(path):
        line = line.strip()
        if line.startswith('LUT_3D_SIZE'):
            n = int(line.split()[1])
        elif line and (line[0].isdigit() or line[0] == '-' or line[0] == '.'):
            vals.append([float(v) for v in line.split()])
    lut = np.array(vals, np.float32).reshape(n, n, n, 3)  # [b][g][r]
    return lut

def apply_lut(img, lut):
    n = lut.shape[0]
    p = np.clip(img, 0, 1) * (n - 1)
    i0 = np.floor(p).astype(int); i1 = np.minimum(i0 + 1, n - 1); f = p - i0
    r0, g0, b0 = i0[..., 0], i0[..., 1], i0[..., 2]
    r1, g1, b1 = i1[..., 0], i1[..., 1], i1[..., 2]
    fr, fg, fb = f[..., 0:1], f[..., 1:2], f[..., 2:3]
    def L(b, g, r): return lut[b, g, r]
    c00 = L(b0, g0, r0) * (1 - fr) + L(b0, g0, r1) * fr
    c01 = L(b0, g1, r0) * (1 - fr) + L(b0, g1, r1) * fr
    c10 = L(b1, g0, r0) * (1 - fr) + L(b1, g0, r1) * fr
    c11 = L(b1, g1, r0) * (1 - fr) + L(b1, g1, r1) * fr
    c0 = c00 * (1 - fg) + c01 * fg
    c1 = c10 * (1 - fg) + c11 * fg
    return c0 * (1 - fb) + c1 * fb

# README と同じ目安値
FX = {
    'SUNDAY_400': dict(grain=0.030, size=1.4, vignette=0.28),
    'NOIR_1600':  dict(grain=0.060, size=2.0, vignette=0.38),
    'SPLASH_200': dict(grain=0.020, size=1.2, vignette=0.18),
    'ALBUM_100':  dict(grain=0.016, size=1.0, vignette=0.30),
    'NITE_800':   dict(grain=0.045, size=1.7, vignette=0.42),
    'RAINY_400':  dict(grain=0.034, size=1.5, vignette=0.12),
}

def add_fx(img, grain, size, vignette, mono=False):
    h, w, _ = img.shape
    sh, sw = int(h / size), int(w / size)
    noise = rng.normal(0, 1, (sh, sw)).astype(np.float32)
    noise = np.array(Image.fromarray(noise).resize((w, h), Image.BILINEAR))
    y = img.mean(axis=2, keepdims=True)
    amp = grain * (0.6 + 0.8 * (1 - np.abs(y - 0.5) * 2))  # 中間調で粒子が目立つ
    img = img + noise[..., None] * amp
    yy, xx = np.mgrid[0:h, 0:w]
    r = np.sqrt(((xx - w / 2) / (w / 2)) ** 2 + ((yy - h / 2) / (h / 2)) ** 2) / np.sqrt(2)
    img = img * (1 - vignette * np.clip(r, 0, 1) ** 2.2)[..., None]
    return np.clip(img, 0, 1)

def date_stamp(pil):
    d = ImageDraw.Draw(pil)
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf', 22)
    text = "'26 11 08"
    x, y = pil.width - 150, pil.height - 40
    glow = Image.new('RGBA', pil.size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).text((x, y), text, font=font, fill=(255, 120, 20, 200))
    glow = glow.filter(ImageFilter.GaussianBlur(3))
    pil = Image.alpha_composite(pil.convert('RGBA'), glow)
    ImageDraw.Draw(pil).text((x, y), text, font=font, fill=(255, 150, 50, 255))
    return pil.convert('RGB')

if __name__ == '__main__':
    base = test_image()
    tiles = [('ORIGINAL', Image.fromarray((base * 255).astype(np.uint8)))]
    for name in FX:
        out = apply_lut(base, read_cube(os.path.join(LUT_DIR, f'{name}.cube')))
        out = add_fx(out, **FX[name])
        pil = date_stamp(Image.fromarray((out * 255).astype(np.uint8)))
        tiles.append((name.replace('_', ' '), pil))
    tw, th = 512, 341; pad = 24; lab = 34
    sheet = Image.new('RGB', (4 * tw + 5 * pad, 2 * (th + lab) + 3 * pad), (28, 27, 25))
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 20)
    d = ImageDraw.Draw(sheet)
    for i, (label, im) in enumerate(tiles):
        r, c = divmod(i, 4)
        x = pad + c * (tw + pad); y = pad + r * (th + lab + pad)
        d.text((x, y), label, font=font, fill=(242, 237, 228))
        sheet.paste(im.resize((tw, th), Image.LANCZOS), (x, y + lab))
    sheet.save(os.path.join(HERE, 'looks_preview.png'))
    print('ok')
