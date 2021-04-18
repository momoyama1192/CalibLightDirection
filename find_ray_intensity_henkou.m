num_ray = 15;
debug_mode = 1; % 1の場合はカメラを使わずにすでにある画像を使用

n = 100;


% a = zeros(3,num_ray); % 光源方向を格納

I = ones(1,num_ray) * 10;
% I_e = zeros(2,num_ray);

%% カメラの設定



%% 輝度を得る


% 1セット目
for i = 1:num_ray
   img = photo(i);
   I_e(1,i) = find_i(img);
end

disp('拡散反射板の向きを変えてください。');
pause

% 2セット目
for i = 1:num_ray
   img = photo(i);
   I_e(2,i) = find_i(img);
end


%% それぞれの光源の輝度を算出
for loop = 1:n
   N1 = (I * pinv(a))';
 
    
   N1 = N1 / norm(N1);
   
   N1_result(loop,:) = N1;
   
   for i = 1:num_ray
       bright_res1(i) = I_e(1,i) / ( N1' * a(:,i));
   end
   
    %I = bright_res1;
    I = bright_res1;
   I_result(loop,:) = I;
end

hold on
for i = 1:num_ray
     plot(I_result(:,i))
end

hold off


result = I_result(n,:) / I_result(n,1) * 10

save('ray_variable/ray_I.mat','I');

function [L] = search_ray(IMAGE)
    N_ROW_start = 21; % 260
    N_COL_start = 265; % 700
    
    N_ROW = 510;  % 画像の行（縦方向）の数
    N_COL = 510;  % 画像の列（横方向）の数
    
    A = imread(IMAGE);
    for i = N_ROW_start : N_ROW + N_ROW_start
        for j = N_COL_start:N_COL + N_COL_start
            img(i-N_ROW_start + 1,j - N_COL_start + 1) = A(i,j); 
        end
    end
    N = redrow(img,N_COL,N_ROW);
    L = find_ray(N);
end


function [L] = find_ray(N)
    R = [0,0,1]';
    R = R / norm(R);
    N = N / norm(N);
    pr = R' * N;
    L = -R + 2 * pr * N;
    
    % 座標系
end


function [I] = find_i(img)
    I = img(33,1222);
end

function [img_save] = photo(l,ROW_FROM,COL_FROM,N_ROW,N_COL)
    H = figure;
    PATTERN = strcat('display_light_pattern/display',num2str(l),'.png');
    
    RGB = imread(PATTERN); 
    imshow(RGB);
    
    % ディスプレイ設定
    H.WindowState = 'fullscreen';   %WindowStateプロパティにて最大化
    H.MenuBar = 'none';   %WindowStateプロパティにて最大化
    H.ToolBar = 'none';
    H.Color = 'black';
    
    vid = videoinput('mwspinnakerimaq', 1, 'Mono8');
    vid.FramesPerTrigger = 1;
    src = getselectedsource(vid); 
    
    src.AutoExposureExposureTimeUpperLimit = 1200000;
    src.AutoExposureExposureTimeLowerLimit = 1200000;


    set(vid,'Timeout',180);
    pause(2);
    start(vid);
    img1 = getdata(vid);    
    
    % 偏光で拡散反射を抽出
    PHOTO_N_ROW = 2048;  % 撮影時の画像の大きさ（行）
    PHOTO_N_COL = 2448;  % 撮影時の画像の大きさ（列）
      

   
   
    % resize_ratio = N_ROW / PHOTO_N_ROW * 2; % 行を基準
    img_save = uint8(img1);
    
    % img_save = img_save(ROW_FROM:(ROW_FROM+N_ROW-1),COL_FROM:(COL_FROM+N_COL-1));
    
    
    SAVE_MAT = strcat('save_mat_img',num2str(l),'.pgm');
    save(SAVE_MAT, 'img_save');
    
    stop(vid);
    
    close all
    flushdata(vid,'triggers');
    
    %SAVE_IMG = strcat('kyu/photoed/save_gazo_hishatai',num2str(l),'.png');
    %imwrite(img_save,SAVE_IMG);
end


function [img1] = photo_debug(l,LOAD_IMG_DIR,ROW_FROM,COL_FROM,N_ROW,N_COL)
    img1 = imread(strcat(LOAD_IMG_DIR,num2str(l),".pgm"));    
end