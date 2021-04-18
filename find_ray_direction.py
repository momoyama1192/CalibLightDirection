import math
import numpy as np
import cv2
import os # ファイル数のカウントに使用


def find_n(img, radius, kyu_x, kyu_y, spec_border):
    n = [0, 0, 0]
    N_ROW, N_COL = img.shape

    cnt = 0

    for i in range(0,N_ROW):
        for j in range(0,N_ROW):
            if (i - kyu_x) ** 2 + (j - kyu_y) ** 2 <= radius ** 2:
                k = math.sqrt(radius ** 2 - (i - kyu_x) ** 2 - (j - kyu_y) ** 2)
                n_tmp =  [i - kyu_x, j - kyu_y , k]
                n_tmp = n_tmp / np.linalg.norm(n_tmp)

                if (img[i,j] >= spec_border):
                    n = n + n_tmp
                    cnt += 1

    n = n / cnt
    n = n / np.linalg.norm(n)
    
    return n
                


# 設定ここから

## 読み込みデータ・保存データ
INPUT_DIR  = "input/"  # 鏡面球の場所(ディレクトリ)
OUTPUT_DIR = "output/" # 光源方向を出力するディレクトリ
extension  = "png"     # 読み込む画像の拡張子

## 球の設定 (事前に撮影画像から確認すること)
radius = 48  # 球の半径
kyu_x  = 64  # 中心のx座標
kyu_y  = 64  # 中心のy座標

## しきい値設定
spec_border = 200  # 鏡面反射のしきい値 (画素値)

## 視点方向 (カメラの方向)
R  = [0,0,1] # 視点方向

# 設定ここまで



## 視点方向正規化
R = R / np.linalg.norm(R)

## 画像データを自動取得
# 引用元: https://qiita.com/john-rocky/items/32909820f99486afee07
pic_total = len([name for name in os.listdir(INPUT_DIR) if os.path.isfile(os.path.join(INPUT_DIR, name))])
print("画像の枚数:", pic_total)

## 光源方向初期化
L = np.zeros([pic_total, 3])


# 光源方向を自動計算
for pic in range(0,pic_total):
    dir_tmp = INPUT_DIR  + str(pic + 1) + "." + extension
    img = cv2.imread(dir_tmp, cv2.IMREAD_GRAYSCALE)

    N = find_n(img, radius, kyu_x, kyu_y, spec_border)

    L_tmp = -R + 2 * np.dot(R,N) * N
    L[pic,:] = L_tmp


# 光源方向出力・保存
print(L)
np.savetxt(OUTPUT_DIR + "direction.txt", L) # 光源方向保存