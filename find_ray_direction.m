%% 読み込みデータ・保存データ
INPUT_DIR      = "input/" ;  % 鏡面球の場所(ディレクトリ)
OUTPUT_DIR     = "output/";  % 光源方向を出力するディレクトリ
extension = "png";   % 読み込む画像の拡張子 

%% 球の設定 (事前に撮影画像から確認すること)
radius      = 48;    % 球の半径
kyu_x       = 64;    % 中心のx座標
kyu_y       = 64;    % 中心のy座標

%% しきい値設定
spec_border = 200;   % 鏡面反射のしきい値（画素値）

%% 視点方向 (カメラの方向)
R = [0,0,1];

% 設定ここまで

%% 視点方向正規化
R = R / norm(R);

%% 画像データを自動取得
pic_total = numel(dir(strcat(INPUT_DIR,"*.",extension))); % ディレクトリ内のデータの枚数

%% 光源方向初期化
L = zeros(pic_total,3);

%% 光源方向を自動計算
for pic = 1:pic_total
    img = imread(strcat(INPUT_DIR,num2str(pic),".",extension));

	N = find_n(img,radius,kyu_x,kyu_y,spec_border);
    L_tmp = -R + 2 * dot(R,N) * N;
    L(pic,:) = L_tmp;
end

%% 出力
save(strcat(OUTPUT_DIR,"direction.txt"),'L','-ascii');
save(strcat(OUTPUT_DIR,"direction.mat"),'L');


function [n] = find_n(img,radius,kyu_x,kyu_y,spec_border)
    n = [0,0,0];

    data_size = size(img);
    N_ROW = data_size(1); % 画像の縦のサイズ
    N_COL = data_size(2); % 画像の横のサイズ

    cnt = 0;
    for i = 1:N_ROW
        for j = 1:N_COL
            if (i - kyu_x) ^ 2 + (j - kyu_y) ^ 2 <= radius ^ 2
                k = sqrt(radius ^ 2 - (i - kyu_x) ^ 2 - (j - kyu_y) ^ 2);
                n_tmp = [i - kyu_x, j - kyu_y , k];
                n_tmp = n_tmp / norm(n_tmp); %  [N_ROW- i,N_COL-j,k]
                if (img(i,j) >= spec_border)
                    n = n + n_tmp;
                    cnt = cnt + 1;
                end
            end
        end
    end
    n = n / cnt;
    n = n / norm(n);
end


