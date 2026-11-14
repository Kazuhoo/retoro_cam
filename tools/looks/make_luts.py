"""
使い捨てカメラアプリ 6台の色味のたたき台（3D LUT）を作るスクリプト。

- 出力: Resources/LUTs/<NAME>.cube（33x33x33, sRGBガンマ空間で入出力）
- 粒子・周辺減光・ハレーション・光漏れ・日付はLUTではなく別処理（README参照）。
- パラメータは LOOKS の辞書を書き換えて何度でも作り直せる。
"""
import numpy as np
from scipy.interpolate import PchipInterpolator

N = 33  # LUTの格子数

def curve(points):
    """制御点 [(in, out), ...] から単調なトーンカーブ関数を作る"""
    xs, ys = zip(*points)
    f = PchipInterpolator(xs, ys)
    return lambda x: np.clip(f(np.clip(x, 0, 1)), 0, 1)

def luma(rgb):
    return rgb[..., 0] * 0.2126 + rgb[..., 1] * 0.7152 + rgb[..., 2] * 0.0722

def saturate(rgb, s):
    y = luma(rgb)[..., None]
    return y + (rgb - y) * s

def split_tone(rgb, shadow, highlight, amount=1.0):
    """シャドウとハイライトに別々の色を足す（shadow/highlight は RGB の加算量）"""
    y = luma(rgb)[..., None]
    w_sh = np.clip(1 - y * 2, 0, 1) ** 1.5
    w_hi = np.clip(y * 2 - 1, 0, 1) ** 1.5
    return rgb + amount * (w_sh * np.array(shadow) + w_hi * np.array(highlight))

def hue_shift_greens(rgb, amount, darken):
    """黄緑〜緑を青緑側へ寄せて暗くする（ALBUM 100 用）"""
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    greenness = np.clip((g - np.maximum(r, b)) * 3, 0, 1)
    out = rgb.copy()
    out[..., 0] = r - greenness * amount * 0.6
    out[..., 2] = b + greenness * amount * 0.5
    out = out * (1 - greenness[..., None] * darken)
    return out

def soft_clip(x, knee=0.85):
    """白飛びをやわらかく丸める"""
    over = np.clip(x - knee, 0, None)
    return np.where(x > knee, knee + (1 - knee) * (1 - np.exp(-over / (1 - knee))), x)

# ------------------------------------------------------------------
# 6台の色味
# ------------------------------------------------------------------

def sunday400(rgb):
    # 90年代の写真屋プリント：あたたかい、赤と黄がよく出る、適度なコントラスト
    rgb = rgb * np.array([1.05, 1.00, 0.90])                  # 暖色寄りのホワイトバランス
    c = curve([(0, 0.035), (0.25, 0.22), (0.5, 0.52), (0.75, 0.80), (1, 0.97)])
    rgb = c(rgb)
    rgb = split_tone(rgb, shadow=[-0.01, 0.0, 0.015], highlight=[0.02, 0.01, -0.03])
    rgb = saturate(rgb, 1.12)
    return rgb

def noir1600(rgb):
    # 70年代の高感度モノクロ：赤フィルター気味の白黒変換、強いコントラスト、わずかに温黒調
    y = rgb[..., 0] * 0.42 + rgb[..., 1] * 0.48 + rgb[..., 2] * 0.10
    c = curve([(0, 0.02), (0.18, 0.08), (0.45, 0.42), (0.7, 0.76), (0.9, 0.93), (1, 0.97)])
    y = c(y)
    tone = np.array([1.00, 0.985, 0.955])                      # 印画紙の温黒調
    return y[..., None] * tone

def splash200(rgb):
    # 90年代の夏：露出オーバー気味、シアン寄り、白はやわらかく飛ぶ、コントラスト低め
    rgb = rgb * 1.18                                           # 露出 +0.25段くらい
    rgb = rgb * np.array([0.94, 1.00, 1.04])
    rgb = soft_clip(rgb, 0.82)
    c = curve([(0, 0.06), (0.3, 0.36), (0.6, 0.68), (1, 0.98)])
    rgb = c(rgb)
    rgb = split_tone(rgb, shadow=[-0.02, 0.01, 0.03], highlight=[-0.01, 0.0, 0.0])
    rgb = saturate(rgb, 0.95)
    return rgb

def album100(rgb):
    # 80年代の家族アルバム：色あせ、黒が浮く、緑が深い、全体に黄みがかったハイライト
    rgb = hue_shift_greens(rgb, amount=0.18, darken=0.12)
    c = curve([(0, 0.09), (0.3, 0.33), (0.6, 0.62), (1, 0.91)])
    rgb = c(rgb)
    rgb = split_tone(rgb, shadow=[0.0, 0.01, 0.02], highlight=[0.025, 0.015, -0.035])
    rgb = saturate(rgb, 0.80)
    return rgb

def nite800(rgb):
    # 90年代の夜とフラッシュ：黒がつぶれる、強いコントラスト、肌は赤く、影はマゼンタ寄り
    rgb = rgb * np.array([1.06, 0.98, 0.94])
    c = curve([(0, 0.0), (0.12, 0.02), (0.35, 0.28), (0.6, 0.64), (0.85, 0.90), (1, 0.98)])
    rgb = c(rgb)
    rgb = split_tone(rgb, shadow=[0.025, -0.01, 0.03], highlight=[0.03, 0.005, -0.02])
    rgb = saturate(rgb, 1.15)
    return rgb

def rainy400(rgb):
    # 90年代の雨の日と蛍光灯の部屋：青緑に寄る、色が浅い、黒が浮いたマット、ハイライトは少しクリーム色
    rgb = rgb * np.array([0.89, 1.00, 0.97])                  # 赤を引いて緑〜シアン寄りに
    c = curve([(0, 0.10), (0.25, 0.28), (0.5, 0.50), (0.75, 0.73), (1, 0.92)])
    rgb = c(rgb)
    rgb = split_tone(rgb, shadow=[-0.04, 0.025, 0.02], highlight=[0.012, 0.014, -0.012])
    rgb = saturate(rgb, 0.62)
    return rgb

LOOKS = {
    'SUNDAY_400': sunday400,
    'NOIR_1600': noir1600,
    'SPLASH_200': splash200,
    'ALBUM_100': album100,
    'NITE_800': nite800,
    'RAINY_400': rainy400,
}

def build_lut(fn, n=N):
    g = np.linspace(0, 1, n)
    # .cube の並び順は R が一番速く変わる
    b, gg, r = np.meshgrid(g, g, g, indexing='ij')
    rgb = np.stack([r, gg, b], axis=-1)
    out = np.clip(fn(rgb), 0, 1)
    return out  # shape (B, G, R, 3)

def write_cube(path, lut, title):
    n = lut.shape[0]
    with open(path, 'w') as f:
        f.write(f'TITLE "{title}"\n')
        f.write(f'LUT_3D_SIZE {n}\n')
        f.write('DOMAIN_MIN 0.0 0.0 0.0\nDOMAIN_MAX 1.0 1.0 1.0\n')
        for bi in range(n):
            for gi in range(n):
                for ri in range(n):
                    r, g, b = lut[bi, gi, ri]
                    f.write(f'{r:.6f} {g:.6f} {b:.6f}\n')

if __name__ == '__main__':
    import os
    LUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'Resources', 'LUTs')
    os.makedirs(LUT_DIR, exist_ok=True)
    for name, fn in LOOKS.items():
        lut = build_lut(fn)
        write_cube(os.path.join(LUT_DIR, f'{name}.cube'), lut, name.replace('_', ' '))
        print('wrote', name)
