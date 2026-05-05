%% 获取原始无噪声图像（从Unity TCP读取并保存）
clear; close all; clc;

% 1. 建立TCP连接（端口号需与Unity中设置一致）
Client = tcpclient('127.0.0.1', 55019);
disp('TCP连接已建立');

% 2. 从左右相机各读取一帧图像
imgL = ImageReadTCP_One(Client, 'Center');
disp('左相机图像读取完成');
imgR = ImageReadTCP_One1(Client, 'Center');
disp('右相机图像读取完成');

% 3. 保存为JPEG文件（质量100，避免压缩损失）
imwrite(imgL, 'left_orig.jpg', 'jpg', 'Quality', 100);
imwrite(imgR, 'right_orig.jpg', 'jpg', 'Quality', 100);
disp('图像已保存为 left_orig.jpg 和 right_orig.jpg');

% 4. （可选）显示图像，确认成功
figure;
subplot(1,2,1); imshow(imgL); title('左相机原始图像');
subplot(1,2,2); imshow(imgR); title('右相机原始图像');

% 5. 关闭TCP连接（可选）
clear Client;