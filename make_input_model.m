% 設定ここから

%% 画像の設定
N_ROW = 128; % 画像の行（縦方向）の数
N_COL = 128; % 画像の列（横方向）の数 
view = [0,0,1]'; % 視点 (鏡面反射に影響)

%% 球の設定
radius = 48;   % 球の半径
kyu_x  = 64;   % 中心のx座標
kyu_y  = 64;   % 中心のy座標
K_d    = 0.5;  % 球の拡散反射率
K_s    = 0.5;  % 球の鏡面反射率 (0→ランバート拡散反射を仮定)
n      = 30;   % 鏡面反射パラメタ

%% 光源の情報
light = [0.1,0.3,0.4]'; % 光源方向 (自動的に1に正規化)
I     = 1;        % 光源強度

%% 出力情報
OUTPUT_DIR = "input/1.png"; % 球を出力する場所

% 設定ここまで

%% 各種初期化
light = light / norm(light); % 光源ベクトル正規化
view  = view / norm(view); % 視点ベクトル正規化
sn = zeros(N_ROW,N_COL,3); 

%% 球の作成
for i = 1:N_ROW
   for j = 1:N_COL
       if (i - kyu_x) ^ 2 + (j - kyu_y) ^ 2 <= radius ^ 2
            k = sqrt(radius ^ 2 - (i - kyu_x) ^ 2 - (j - kyu_y) ^ 2);
            sn_tmp =  [i - kyu_x, j - kyu_y , k]';
            sn_tmp = sn_tmp / norm(sn_tmp);
            sn(i,j,:) = sn_tmp;
       end
   end
end

%% 法線デバッグ用 普段はコメントアウト
% check_sn = uint8((sn + 1) * 255 / 2);
% imwrite(check_sn,"true_hosen.ppm");

%% 拡散反射の考慮
img_diffuse = zeros(N_ROW,N_COL);

for i = 1:N_ROW
   for j = 1:N_COL
       sn_tmp = [sn(i,j,1) sn(i,j,2) sn(i,j,3)]';
       if norm(sn_tmp) > 0
           cos_theta = dot(light,sn_tmp);
           if cos_theta > 0
               img_diffuse(i,j) = K_d * I * cos_theta;
           end
       end
   end
end

%% 鏡面反射の考慮
img_specular = zeros(N_ROW,N_COL);

for i = 1:N_ROW
   for j = 1:N_COL
       sn_tmp = [sn(i,j,1) sn(i,j,2) sn(i,j,3)]';
       if norm(sn_tmp) > 0
           r = 2 * dot(sn_tmp,light) * sn_tmp - light; % 正規化の必要なし
           cos_alpha = dot(view,r);
           if cos_alpha > 0
               img_specular(i,j) = K_s * I * (cos_alpha ^ n);
               % img_specular(i,j) = K_s * I * specular(sn(i,j,1),sn(i,j,2),sn(i,j,3),light,view,n);
               % ライブラリ関数 specular を使ってもOK
           end
       end
   end
end

%% 出力
img_output = img_diffuse + img_specular; 
img_output(img_output > 1) = 1; % 輝度値の上限を考慮

imwrite(img_output,OUTPUT_DIR);