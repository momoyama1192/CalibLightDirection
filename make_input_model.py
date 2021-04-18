import math
import numpy as np
import cv2

# 設定ここから

## 画像設定
N_ROW = 128 # 画像の行 (縦方向) の数
N_COL = 128 # 画像の列 (横方向) の数
view  = [0,0,1] # 視点方向

## 球の設定
radius = 48  # 球の半径
kyu_x  = 64  # 中心のx座標
kyu_y  = 64  # 中心のy座標
K_d    = 0.2 # 球の拡散反射率
K_s    = 0.8 # 球の鏡面反射率 (0→ランバート拡散反射を仮定)
n      = 30  # 鏡面反射パラメタ

## 光源の情報
light = [0.1,0.3,0.4] # 光源方向 (自動的に1に正規化)
I     = 1;       # 光源強度

## 出力先
OUTPUT_DIR = "input/1.png"; # 球を出力する場所

# 設定ここまで


## 各種初期化
light = light / np.linalg.norm(light)
view  = view / np.linalg.norm(view)
sn = np.zeros([N_ROW, N_COL, 3])


## 球の作成
for i in range(0,N_ROW):
    for j in range(0,N_COL):
        if (i - kyu_x) ** 2 + (j - kyu_y) ** 2 <= radius ** 2:
            k = math.sqrt(radius ** 2 - (i - kyu_x) ** 2 - (j - kyu_y) ** 2)
            sn_tmp =  [i - kyu_x, j - kyu_y , k]
            sn_tmp = sn_tmp / np.linalg.norm(sn_tmp)
            sn[i,j,:] = sn_tmp


## 正しく法線が求まっているかの確認用 (普段はコメントアウト)
# check_sn = (sn + 1) * 255 / 2
# check_sn_bgr = check_sn[:, :, [2, 1, 0]] # CV2はBGRの順に認識されるため  


## 拡散反射の考慮
img_diffuse = np.zeros([N_ROW, N_COL])

for i in range(0,N_ROW):
    for j in range(0,N_COL):
        sn_tmp =  sn[i,j,:]
        if np.linalg.norm(sn_tmp) > 0:
            cos_theta = np.dot(light,sn_tmp)
            if cos_theta > 0:
                img_diffuse[i,j] = K_d * I * cos_theta * 255


## 鏡面反射の考慮
img_specular = np.zeros([N_ROW, N_COL])

for i in range(0,N_ROW):
    for j in range(0,N_COL):
        sn_tmp =  sn[i,j,:]
        if np.linalg.norm(sn_tmp) > 0:
            r = 2 * np.dot(sn_tmp,light) * sn_tmp - light
            cos_alpha = np.dot(view,r)
            if cos_alpha > 0:
                img_specular[i,j] = K_s * I * (cos_alpha ** n) * 255


## 出力
img_output = img_diffuse + img_specular
cv2.imwrite(OUTPUT_DIR, img_output)